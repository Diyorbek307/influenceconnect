import 'package:flutter/material.dart';

import '../data/constants.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

/// Горизонтальная лента чипов-категорий для фильтрации лент.
class CategoryFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const CategoryFilter({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final items = ['Все', ...AppConst.categories];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = items[i];
          final active = c == selected;
          return GestureDetector(
            onTap: () => onSelect(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: active ? AppColors.brandGradient : null,
                color: active ? null : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: active
                        ? Colors.transparent
                        : Theme.of(context).dividerColor),
              ),
              child: Text(
                c == 'Все' ? tr('all') : c,
                style: TextStyle(
                  color: active
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
