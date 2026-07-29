import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../../domain/models/meal_plan.dart';
import '../../domain/models/meal.dart';
import '../../domain/models/meal_sort_option.dart';
import '../../application/services/meal_selection_engine.dart';
import '../../providers.dart';

class AutoPopulateConfigBottomSheet extends StatefulWidget {
  const AutoPopulateConfigBottomSheet({super.key});

  @override
  State<AutoPopulateConfigBottomSheet> createState() => _AutoPopulateConfigBottomSheetState();
}

class _AutoPopulateConfigBottomSheetState extends State<AutoPopulateConfigBottomSheet> {
  bool _useRecency = true;
  bool _useVaryProtein = true;
  int _consecutiveDays = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Auto-Fill Options', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Penalize Recent Meals'),
            subtitle: const Text('Avoid meals eaten recently or scheduled soon.'),
            value: _useRecency,
            onChanged: (val) => setState(() => _useRecency = val),
          ),
          SwitchListTile(
            title: const Text('Vary Protein Source'),
            subtitle: const Text('Avoid meals sharing the same protein source as recent meals.'),
            value: _useVaryProtein,
            onChanged: (val) => setState(() => _useVaryProtein = val),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Consecutive Days per Meal:', style: TextStyle(fontSize: 16)),
                DropdownButton<int>(
                  value: _consecutiveDays,
                  items: List.generate(7, (index) => index + 1)
                      .map((val) => DropdownMenuItem(value: val, child: Text(val.toString())))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _consecutiveDays = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'useRecency': _useRecency, 
              'useVaryProtein': _useVaryProtein,
              'consecutiveDays': _consecutiveDays
            }),
            child: const Text('Auto-Fill Now'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  Future<void> _startPlanCreationFlow(BuildContext context, WidgetRef ref) async {
    final currentPlans = ref.read(plansStreamProvider).value ?? [];
    Set<DateTime> usedDates = {};
    for (final plan in currentPlans) {
      DateTime currentDate = DateTime(plan.startDate.year, plan.startDate.month, plan.startDate.day);
      final endDate = DateTime(plan.endDate.year, plan.endDate.month, plan.endDate.day);
      while (!currentDate.isAfter(endDate)) {
        usedDates.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    final values = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        dayBuilder: ({
          required date,
          textStyle,
          decoration,
          isSelected,
          isDisabled,
          isToday,
        }) {
          final isUsed = usedDates.contains(DateTime(date.year, date.month, date.day));
          return Container(
            decoration: decoration,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  date.day.toString(),
                  style: textStyle,
                ),
                if (isUsed && (isSelected == null || !isSelected))
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      dialogSize: const Size(325, 400),
      value: [],
      borderRadius: BorderRadius.circular(15),
    );

    if (values == null || values.isEmpty) return;
    
    // Normalize date (remove time)
    final startDate = DateTime(values.first!.year, values.first!.month, values.first!.day);
    final endDate = values.length > 1 && values.last != null 
        ? DateTime(values.last!.year, values.last!.month, values.last!.day)
        : startDate;
    
    final dbId = ref.read(activeDatabaseIdStreamProvider).value;
    if (dbId == null) return;
    
    // T2: Overlap Detection Logic
    final overlappingPlans = currentPlans.where((p) => p.overlapsWithRange(startDate, endDate)).toList();
    
    Map<int, String> initialMeals = {};
    List<MealPlan> plansToDelete = [];
    List<MealPlan> plansToAdd = [];
    
    if (overlappingPlans.isNotEmpty) {
      if (!context.mounted) return;
      final confirm = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Overlap Detected'),
          content: const Text('The selected dates overlap with existing meal plans. What would you like to do?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, 'cancel'), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, 'allow'), child: const Text('Allow')),
            TextButton(onPressed: () => Navigator.pop(ctx, 'truncate'), child: const Text('Truncate Old')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, 'merge'), child: const Text('Delete Old')),
          ],
        )
      );
      
      if (confirm == null || confirm == 'cancel') return;
      
      if (confirm == 'merge' || confirm == 'allow' || confirm == 'truncate') {
        // T3: Conflict Resolution Implementation
        for (final plan in overlappingPlans) {
          final planDuration = endDate.difference(startDate).inDays;
          for (int i = 0; i <= planDuration; i++) {
            final targetDate = startDate.add(Duration(days: i));
            if (plan.coversDate(targetDate)) {
               final mealId = plan.getMealIdForDate(targetDate);
               if (mealId != null) {
                 initialMeals[i] = mealId;
               }
            }
          }
          if (confirm == 'merge') {
            plansToDelete.add(plan);
          } else if (confirm == 'truncate') {
            plansToDelete.add(plan);
            
            final normOldStart = DateTime(plan.startDate.year, plan.startDate.month, plan.startDate.day);
            final normOldEnd = DateTime(plan.endDate.year, plan.endDate.month, plan.endDate.day);
            final normNewStart = DateTime(startDate.year, startDate.month, startDate.day);
            final normNewEnd = DateTime(endDate.year, endDate.month, endDate.day);

            // Segment 1: before the overlap
            final seg1End = normNewStart.subtract(const Duration(days: 1));
            if (!normOldStart.isAfter(seg1End)) {
               Map<int, String> seg1Meals = {};
               for (int i = 0; i <= seg1End.difference(normOldStart).inDays; i++) {
                 final date = normOldStart.add(Duration(days: i));
                 final mealId = plan.getMealIdForDate(date);
                 if (mealId != null) seg1Meals[i] = mealId;
               }
               plansToAdd.add(MealPlan(
                 id: '${plan.id}_seg1',
                 startDate: normOldStart,
                 endDate: seg1End,
                 mealIdsByDay: seg1Meals,
               ));
            }

            // Segment 2: after the overlap
            final seg2Start = normNewEnd.add(const Duration(days: 1));
            if (!seg2Start.isAfter(normOldEnd)) {
               Map<int, String> seg2Meals = {};
               for (int i = 0; i <= normOldEnd.difference(seg2Start).inDays; i++) {
                 final date = seg2Start.add(Duration(days: i));
                 final mealId = plan.getMealIdForDate(date);
                 if (mealId != null) seg2Meals[i] = mealId;
               }
               plansToAdd.add(MealPlan(
                 id: '${plan.id}_seg2',
                 startDate: seg2Start,
                 endDate: normOldEnd,
                 mealIdsByDay: seg2Meals,
               ));
            }
          }
        }
      }
    }
    
    final newPlan = MealPlan(
      id: '${dbId}_${startDate.millisecondsSinceEpoch}',
      startDate: startDate,
      endDate: endDate,
      mealIdsByDay: initialMeals,
    );
    
    final repo = ref.read(mealSyncServiceProvider);
    for (final p in plansToDelete) {
      await repo.deletePlan(dbId, p.id);
    }
    for (final p in plansToAdd) {
      await repo.savePlan(dbId, p);
    }
    await repo.savePlan(dbId, newPlan);
  }

  void _openPlanDetail(BuildContext context, WidgetRef ref, MealPlan plan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MealPlanDetailScreen(plan: plan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(plansStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plans'),
      ),
      body: plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return const Center(child: Text('No meal plans yet.'));
          }
          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(MealPlan.formatDateRange(plan.startDate, plan.endDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${plan.mealIdsByDay.length} meals planned'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openPlanDetail(context, ref, plan),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startPlanCreationFlow(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MealPlanDetailScreen extends ConsumerWidget {
  final MealPlan plan;
  
  const MealPlanDetailScreen({super.key, required this.plan});

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Future<void> _assignMeal(BuildContext context, WidgetRef ref, MealPlan currentPlan, int dayIndex, List<Meal> allMeals) async {
    final sortOption = ref.read(mealSortProvider);
    final sortedMeals = allMeals.applySort(sortOption);

    final Meal? selectedMeal = await showDialog<Meal>(
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
              child: const Text('Clear Day'),
            ),
          ],
        );
      },
    );

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
      if (selectedMeal != null) {
        newMealIds[pTargetOffset] = selectedMeal.id;
      } else {
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
              final config = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                builder: (context) => const AutoPopulateConfigBottomSheet(),
              );
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No empty slots to fill!')));
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
                    content: const Text('Some meals would overflow the available empty days (e.g., at the end of the week). Do you want to fill what it can, or leave the remaining days empty?'),
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
                )
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
          )
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
