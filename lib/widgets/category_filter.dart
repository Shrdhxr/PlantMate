import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantmate/models/plant.dart';
import 'package:plantmate/providers/plants_provider.dart';

class CategoryFilter extends ConsumerWidget {
  const CategoryFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedCategory == null,
            onSelected: (selected) {
              if (selected) {
                ref.read(selectedCategoryProvider.notifier).state = null;
              }
            },
          ),
          const SizedBox(width: 8),
          ...PlantCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(Plant.categoryToString(category)),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  ref.read(selectedCategoryProvider.notifier).state = 
                      selected ? category : null;
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
