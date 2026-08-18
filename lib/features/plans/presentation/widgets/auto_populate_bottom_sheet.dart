import 'package:flutter/material.dart';

class AutoPopulateConfigBottomSheet extends StatefulWidget {
  const AutoPopulateConfigBottomSheet({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AutoPopulateConfigBottomSheet(),
    );
  }

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
          const Text(
            'Auto-Fill Options',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
              'consecutiveDays': _consecutiveDays,
            }),
            child: const Text('Auto-Fill Now'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
