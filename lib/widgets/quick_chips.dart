import 'package:flutter/material.dart';

class QuickChips extends StatelessWidget {
  final List<String> chips;
  final bool isLoading;
  final ValueChanged<String> onChipSelected;

  const QuickChips({
    super.key,
    required this.chips,
    required this.isLoading,
    required this.onChipSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final text = chips[index];
          return ActionChip(
            label: Text(text, style: const TextStyle(fontSize: 13)),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            onPressed: isLoading ? null : () => onChipSelected(text),
          );
        },
      ),
    );
  }
}
