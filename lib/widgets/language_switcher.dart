import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

/// Переключатель языка (UZ / RU / EN).
class LanguageSwitcher extends StatelessWidget {
  final bool onDark;
  const LanguageSwitcher({super.key, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: L10n.instance,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: onDark
                ? Colors.white.withValues(alpha: 0.15)
                : Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(999),
            border: onDark
                ? null
                : Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: L10n.codes.map((code) {
              final active = L10n.instance.code == code;
              return GestureDetector(
                onTap: () => L10n.instance.setCode(code),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: active ? AppColors.brandGradient : null,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    code.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: active
                          ? Colors.white
                          : (onDark
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
