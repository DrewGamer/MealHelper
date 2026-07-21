import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../domain/models/weekly_plan.dart';
import '../../domain/models/meal.dart';

class WeeklyPlanScreen extends ConsumerStatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  ConsumerState<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends ConsumerState<WeeklyPlanScreen> {
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(plansStreamProvider);
    final mealsAsync = ref.watch(mealsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Plan'),
      ),
      body: plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: () => _createNewPlan(context, ref),
                child: const Text('Create New Plan'),
              ),
            );
          }
          final plan = plans.first; // Most recent plan
          return _buildPlanView(context, ref, plan, mealsAsync.value ?? []);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: (plansAsync.value?.isNotEmpty == true)
          ? FloatingActionButton(
              onPressed: () => _createNewPlan(context, ref),
              tooltip: 'New Week',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildPlanView(BuildContext context, WidgetRef ref, WeeklyPlan plan, List<Meal> allMeals) {
    return ListView.builder(
      itemCount: 7,
      itemBuilder: (context, index) {
        final dayDate = plan.startDate.add(Duration(days: index));
        final weekday = _weekdays[dayDate.weekday - 1];
        final dayName = '$weekday, ${dayDate.month}/${dayDate.day}';
        
        final mealId = plan.mealIdsByDay[index];
        final meal = allMeals.where((m) => m.id == mealId).firstOrNull;

        return ListTile(
          title: Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(meal != null ? meal.name : 'No meal assigned'),
          trailing: const Icon(Icons.edit),
          onTap: () => _assignMeal(context, ref, plan, index, allMeals),
        );
      },
    );
  }

  Future<void> _createNewPlan(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select Start Date for Week',
    );
    if (picked != null) {
      final dbId = ref.read(activeDatabaseIdStreamProvider).value;
      if (dbId == null) return;
      
      // Zero out time for consistency
      final start = DateTime(picked.year, picked.month, picked.day);
      
      final newPlan = WeeklyPlan(
        id: '${dbId}_${start.millisecondsSinceEpoch}',
        startDate: start,
        mealIdsByDay: {},
      );
      await ref.read(planRepositoryProvider).savePlan(dbId, newPlan);
    }
  }

  Future<void> _assignMeal(BuildContext context, WidgetRef ref, WeeklyPlan plan, int dayIndex, List<Meal> allMeals) async {
    final Meal? selectedMeal = await showDialog<Meal>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Meal'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allMeals.length,
              itemBuilder: (context, i) {
                final meal = allMeals[i];
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

    final newMealIds = Map<int, String>.from(plan.mealIdsByDay);
    if (selectedMeal != null) {
      newMealIds[dayIndex] = selectedMeal.id;
    } else {
      newMealIds.remove(dayIndex);
    }

    final updatedPlan = plan.copyWith(mealIdsByDay: newMealIds);
    await ref.read(planRepositoryProvider).updatePlan(dbId, updatedPlan);
  }
}
