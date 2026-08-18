import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../collaboration/data/workspace_repository.dart';
import '../../meals/data/meal_sort_notifier.dart';
import '../../meals/data/meals_repository.dart';
import '../../meals/domain/meal.dart';
import '../../meals/domain/meal_sort_option.dart';
import '../application/meal_selection_engine.dart';
import '../application/meal_sync_service.dart';
import '../data/plan_repository.dart';
import '../domain/meal_plan.dart';
import 'widgets/auto_populate_bottom_sheet.dart';

class MealPlanDetailScreen extends ConsumerWidget {
  final MealPlan plan;
  
  const MealPlanDetailScreen({super.key, required this.plan});

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Future<void> _assignMeal(BuildContext context, WidgetRef ref, MealPlan currentPlan, int dayIndex, List<Meal> allMeals) async {
    final sortOption = ref.read(mealSortProvider);
    final sortedMeals = allMeals.applySort(sortOption);

    final Object? result = await showDialog<Object?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Meal'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sortedMeals.length,
              itemBuilder: (context, i) {
                final meal = sortedMeals[i];
                return ListTile(
                  title: Text(meal.name),
                  onTap: () => Navigator.pop(context, meal),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'CLEAR'),
              child: const Text('Clear Day'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    final dbId = ref.read(activeDatabaseIdStreamProvider).value;
    if (dbId == null) return;

    final targetDate = DateTime(
      currentPlan.startDate.year,
      currentPlan.startDate.month,
      currentPlan.startDate.day,
    ).add(Duration(days: dayIndex));

    final currentPlans = ref.read(plansStreamProvider).value ?? [];
    final plansToUpdate = currentPlans.where((p) => p.coversDate(targetDate)).toList();

    for (final p in plansToUpdate) {
      final pTargetOffset = targetDate.difference(DateTime(p.startDate.year, p.startDate.month, p.startDate.day)).inDays;
      final newMealIds = Map<int, String>.from(p.mealIdsByDay);
      if (result is Meal) {
        newMealIds[pTargetOffset] = result.id;
      } else if (result == 'CLEAR') {
        newMealIds.remove(pTargetOffset);
      }
      final updatedPlan = p.copyWith(mealIdsByDay: newMealIds);
      await ref.read(mealSyncServiceProvider).updatePlan(dbId, updatedPlan);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We listen to the plans stream to keep the detail screen updated
    final plansAsync = ref.watch(plansStreamProvider);
    final mealsAsync = ref.watch(mealsStreamProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(MealPlan.formatDateRange(plan.startDate, plan.endDate)),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () async {
              final config = await AutoPopulateConfigBottomSheet.show(context);
              if (config == null) return;
              
              final allMeals = ref.read(mealsStreamProvider).value ?? [];
              final currentPlans = ref.read(plansStreamProvider).value ?? [];
              final currentPlan = currentPlans.firstWhere((p) => p.id == plan.id, orElse: () => plan);
              
              final duration = currentPlan.endDate.difference(currentPlan.startDate).inDays + 1;
              List<DateTime> emptySlots = [];
              for (int i = 0; i < duration; i++) {
                if (currentPlan.mealIdsByDay[i] == null) {
                  emptySlots.add(currentPlan.startDate.add(Duration(days: i)));
                }
              }
              
              if (emptySlots.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No empty slots to fill!')),
                  );
                }
                return;
              }
              
              int consecutiveDays = config['consecutiveDays'] ?? 1;
              bool fillPartial = true;

              emptySlots.sort();
              List<List<DateTime>> contiguousSequences = [];
              List<DateTime> currentSeq = [emptySlots.first];

              for (int i = 1; i < emptySlots.length; i++) {
                final prev = emptySlots[i - 1];
                final curr = emptySlots[i];
                final prevDay = DateTime(prev.year, prev.month, prev.day);
                final currDay = DateTime(curr.year, curr.month, curr.day);

                if (currDay.difference(prevDay).inDays == 1) {
                  currentSeq.add(curr);
                } else {
                  contiguousSequences.add(currentSeq);
                  currentSeq = [curr];
                }
              }
              contiguousSequences.add(currentSeq);

              bool hasPartialFills = false;
              for (var seq in contiguousSequences) {
                if (seq.length % consecutiveDays > 0) {
                  hasPartialFills = true;
                  break;
                }
              }

              if (hasPartialFills) {
                if (!context.mounted) return;
                final result = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Partial Meal Placement'),
                    content: const Text(
                      'Some meals would overflow the available empty days (e.g., at the end of the week). Do you want to fill what it can, or leave the remaining days empty?',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Leave Empty')),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Fill What It Can')),
                    ],
                  ),
                );
                
                if (result == null) return;
                fillPartial = result;
              }

              final engineConfig = EngineConfig(
                useRecency: config['useRecency'] == true,
                useVaryProtein: config['useVaryProtein'] == true,
              );
              final engine = ref.read(mealSelectionEngineProvider(engineConfig));
              
              final assignments = engine.populateSlots(
                emptySlots, 
                allMeals,
                consecutiveDays: consecutiveDays,
                fillPartial: fillPartial,
              );
              
              final newMealIds = Map<int, String>.from(currentPlan.mealIdsByDay);
              assignments.forEach((date, meal) {
                final offset = date.difference(currentPlan.startDate).inDays;
                newMealIds[offset] = meal.id;
              });
              
              final updatedPlan = currentPlan.copyWith(mealIdsByDay: newMealIds);
              final dbId = ref.read(activeDatabaseIdStreamProvider).value;
              if (dbId != null) {
                await ref.read(mealSyncServiceProvider).updatePlan(dbId, updatedPlan);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Plan'),
                  content: const Text('Are you sure you want to delete this meal plan?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirm == true) {
                final dbId = ref.read(activeDatabaseIdStreamProvider).value;
                if (dbId != null) {
                  await ref.read(mealSyncServiceProvider).deletePlan(dbId, plan.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              }
            },
          ),
        ],
      ),
      body: plansAsync.when(
        data: (plans) {
          final currentPlan = plans.firstWhere((p) => p.id == plan.id, orElse: () => plan);
          final allMeals = mealsAsync.value ?? [];
          
          final duration = currentPlan.endDate.difference(currentPlan.startDate).inDays + 1;
          return ListView.builder(
            itemCount: duration,
            itemBuilder: (context, index) {
              final dayDate = currentPlan.startDate.add(Duration(days: index));
              final weekday = _weekdays[dayDate.weekday - 1];
              final dayName = '$weekday, ${dayDate.month}/${dayDate.day}';

              final mealId = currentPlan.mealIdsByDay[index];
              final meal = allMeals.where((m) => m.id == mealId).firstOrNull;

              return ListTile(
                title: Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(meal != null ? meal.name : 'No meal assigned'),
                trailing: const Icon(Icons.edit),
                onTap: () => _assignMeal(context, ref, currentPlan, index, allMeals),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
