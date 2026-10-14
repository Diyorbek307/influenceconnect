import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Круглый аватар с загрузкой из сети и аккуратным запасным вариантом
/// (инициалы на фирменном градиенте), если картинка не загрузилась.
class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final String initials;
  final double size;
  final Color? ringColor;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    required this.initials,
    this.size = 48,
    this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.brandGradient,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
        ),
      ),
    );

    Widget avatar;
    if (imageUrl.isEmpty) {
      avatar = fallback;
    } else {
      avatar = ClipOval(
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => fallback,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: size,
              height: size,
              color: AppColors.lightBorder,
              alignment: Alignment.center,
              child: SizedBox(
                width: size * 0.3,
                height: size * 0.3,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      );
    }

    if (ringColor == null) return avatar;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor!, width: 2),
      ),
      child: avatar,
    );
  }
}
