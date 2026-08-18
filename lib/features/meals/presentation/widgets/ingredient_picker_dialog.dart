import 'package:flutter/material.dart';
import '../../../../core/utils/string_extensions.dart';

class IngredientPickerDialog extends StatefulWidget {
  final List<String> availableIngredients;
  final List<String> initialSelectedIngredients;

  const IngredientPickerDialog({
    super.key,
    required this.availableIngredients,
    required this.initialSelectedIngredients,
  });

  static Future<List<String>?> show(
    BuildContext context, {
    required List<String> availableIngredients,
    required List<String> initialSelectedIngredients,
  }) {
    return showDialog<List<String>>(
      context: context,
      builder: (context) => IngredientPickerDialog(
        availableIngredients: availableIngredients,
        initialSelectedIngredients: initialSelectedIngredients,
      ),
    );
  }

  @override
  State<IngredientPickerDialog> createState() => _IngredientPickerDialogState();
}

class _IngredientPickerDialogState extends State<IngredientPickerDialog> {
  late final List<String> _selectedIngredients;

  @override
  void initState() {
    super.initState();
    _selectedIngredients = List.from(widget.initialSelectedIngredients);
  }

  @override
  Widget build(BuildContext context) {
    final sortedAvailable = widget.availableIngredients.sortedAlphabetically();

    return AlertDialog(
      title: const Text('Select Ingredients'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: sortedAvailable.map((ingredient) {
            final isChecked = _selectedIngredients.contains(ingredient);
            return CheckboxListTile(
              title: Text(ingredient),
              value: isChecked,
              onChanged: (bool? checked) {
                setState(() {
                  if (checked == true) {
                    if (!_selectedIngredients.contains(ingredient)) {
                      _selectedIngredients.add(ingredient);
                    }
                  } else {
                    _selectedIngredients.remove(ingredient);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedIngredients),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
