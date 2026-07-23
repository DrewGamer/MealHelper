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
    final selectedWeek = ref.watch(selectedWeekDateProvider);
    final selectedPlanAsync = ref.watch(selectedWeeklyPlanProvider);
    final mealsAsync = ref.watch(mealsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Plan History',
            onPressed: () => _showHistoryBottomSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildWeekNavigationBar(context, ref, selectedWeek),
          Expanded(
            child: selectedPlanAsync.when(
              data: (plan) {
                if (plan == null) {
                  return _buildEmptyState(context, ref, selectedWeek);
                }
                return _buildPlanView(context, ref, plan, mealsAsync.value ?? []);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekNavigationBar(BuildContext context, WidgetRef ref, DateTime selectedWeek) {
    final currentWeekStart = WeeklyPlan.normalizeToStartOfWeek(DateTime.now());
    final isCurrentWeek = WeeklyPlan.normalizeToStartOfWeek(selectedWeek) == currentWeekStart;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous Week',
              onPressed: () {
                ref.read(selectedWeekDateProvider.notifier).set(
                      selectedWeek.subtract(const Duration(days: 7)),
                    );
              },
            ),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  WeeklyPlan.formatDateRange(selectedWeek),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedWeek,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    helpText: 'Select Week',
                  );
                  if (picked != null) {
                    ref.read(selectedWeekDateProvider.notifier).set(picked);
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next Week',
              onPressed: () {
                ref.read(selectedWeekDateProvider.notifier).set(
                      selectedWeek.add(const Duration(days: 7)),
                    );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.today,
                color: isCurrentWeek ? Colors.grey : Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'Current Week',
              onPressed: isCurrentWeek
                  ? null
                  : () {
                      ref.read(selectedWeekDateProvider.notifier).set(DateTime.now());
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, DateTime selectedWeek) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No plan exists for this week',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              WeeklyPlan.formatDateRange(selectedWeek),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Plan for this Week'),
              onPressed: () => _createPlanForSelectedWeek(context, ref, selectedWeek),
            ),
          ],
        ),
      ),
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

  Future<void> _createPlanForSelectedWeek(BuildContext context, WidgetRef ref, DateTime weekStart) async {
    final dbId = ref.read(activeDatabaseIdStreamProvider).value;
    if (dbId == null) return;

    final normalizedStart = WeeklyPlan.normalizeToStartOfWeek(weekStart);
    final newPlan = WeeklyPlan(
      id: '${dbId}_${normalizedStart.millisecondsSinceEpoch}',
      startDate: normalizedStart,
      mealIdsByDay: {},
    );
    await ref.read(planRepositoryProvider).savePlan(dbId, newPlan);
  }

  void _showHistoryBottomSheet(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.read(plansStreamProvider);
    final plans = plansAsync.value ?? [];
    final sortedPlans = List<WeeklyPlan>.from(plans)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Meal Plan History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              if (sortedPlans.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('No meal plans created yet.')),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: sortedPlans.length,
                    itemBuilder: (context, index) {
                      final plan = sortedPlans[index];
                      final isSelected = plan.isSameWeek(ref.read(selectedWeekDateProvider));
                      return ListTile(
                        leading: Icon(
                          Icons.calendar_month,
                          color: isSelected ? Theme.of(context).colorScheme.primary : null,
                        ),
                        title: Text(
                          WeeklyPlan.formatDateRange(plan.startDate),
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Theme.of(context).colorScheme.primary : null,
                          ),
                        ),
                        subtitle: Text('${plan.mealIdsByDay.length} meals planned'),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: () {
                          ref.read(selectedWeekDateProvider.notifier).set(plan.startDate);
                          Navigator.pop(sheetContext);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
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
