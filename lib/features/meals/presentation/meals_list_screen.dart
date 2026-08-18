import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/meal_sort_notifier.dart';
import '../data/meals_repository.dart';
import '../domain/meal_sort_option.dart';
import 'meal_detail_screen.dart';

class MealsListScreen extends ConsumerWidget {
  const MealsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsyncValue = ref.watch(mealsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals Database'),
        actions: [
          PopupMenuButton<MealSortOption>(
            icon: const Icon(Icons.sort),
            initialValue: ref.watch(mealSortProvider),
            onSelected: (option) {
              ref.read(mealSortProvider.notifier).setSortOption(option);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: MealSortOption.alphabetical,
                child: Text('Alphabetical'),
              ),
            ],
          ),
        ],
      ),
      body: mealsAsyncValue.when(
        data: (meals) {
          final sortOption = ref.watch(mealSortProvider);
          final sortedMeals = meals.applySort(sortOption);

          if (sortedMeals.isEmpty) {
            return const Center(child: Text('No meals found. Add some!'));
          }
          return ListView.builder(
            itemCount: sortedMeals.length,
            itemBuilder: (context, index) {
              final meal = sortedMeals[index];
              final subtitleParts = <String>[];
              if (meal.proteinSource != null && meal.proteinSource!.isNotEmpty) {
                subtitleParts.add(meal.proteinSource!);
              }
              subtitleParts.addAll(meal.ingredients);

              return ListTile(
                title: Text(meal.name),
                subtitle: subtitleParts.isNotEmpty ? Text(subtitleParts.join(', ')) : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal)),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading meals: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MealDetailScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
