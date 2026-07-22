import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import 'meal_detail_screen.dart';

class MealsListScreen extends ConsumerWidget {
  const MealsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsyncValue = ref.watch(mealsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals Database'),
      ),
      body: mealsAsyncValue.when(
        data: (meals) {
          if (meals.isEmpty) {
            return const Center(child: Text('No meals found. Add some!'));
          }
          return ListView.builder(
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              final subtitleParts = <String>[];
              if (meal.proteinSource != null && meal.proteinSource!.isNotEmpty) {
                subtitleParts.add(meal.proteinSource!);
              }
              subtitleParts.addAll(meal.ingredients);

              return ListTile(
                title: Text(meal.name),
                subtitle: subtitleParts.isNotEmpty ? Text(subtitleParts.join(', ')) : null,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal)));
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
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MealDetailScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
