import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../../collaboration/data/workspace_repository.dart';
import '../application/meal_sync_service.dart';
import '../data/plan_repository.dart';
import '../domain/meal_plan.dart';
import 'meal_plan_detail_screen.dart';

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
    
    // Overlap Detection Logic
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
        ),
      );
      
      if (confirm == null || confirm == 'cancel') return;
      
      if (confirm == 'merge' || confirm == 'allow' || confirm == 'truncate') {
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
                  title: Text(
                    MealPlan.formatDateRange(plan.startDate, plan.endDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
