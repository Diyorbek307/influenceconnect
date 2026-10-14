import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'common.dart';

enum SwipeAction { like, dislike, save }

/// Переиспользуемая свайп-колода (как в Tinder).
///
/// Поддерживает перетаскивание карточки и кнопки. Верхняя карточка реагирует
/// на жесты, следующая видна позади. Коллбэки сообщают выбор наружу.
class SwipeDeck<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) cardBuilder;
  final void Function(T item, SwipeAction action) onSwipe;
  final bool saveEnabled;
  final Widget emptyState;

  const SwipeDeck({
    super.key,
    required this.items,
    required this.cardBuilder,
    required this.onSwipe,
    required this.emptyState,
    this.saveEnabled = true,
  });

  @override
  State<SwipeDeck<T>> createState() => _SwipeDeckState<T>();
}

class _SwipeDeckState<T> extends State<SwipeDeck<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _drag = Offset.zero;
  int _index = 0;
  bool _animatingOut = false;
  Offset _animStart = Offset.zero;
  Offset _animEnd = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addListener(_onTick);
  }

  @override
  void didUpdateWidget(covariant SwipeDeck<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Если список обновился и индекс вышел за пределы — сбросим.
    if (_index >= widget.items.length) {
      _index = 0;
      _drag = Offset.zero;
    }
  }

  void _onTick() {
    final t = Curves.easeOut.transform(_controller.value);
    setState(() {
      _drag = Offset.lerp(_animStart, _animEnd, t) ?? _drag;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  T? get _currentItem =>
      _index < widget.items.length ? widget.items[_index] : null;

  void _completeSwipe(SwipeAction action) {
    final item = _currentItem;
    if (item == null) return;
    setState(() {
      _animatingOut = false;
      _drag = Offset.zero;
      _index++;
    });
    widget.onSwipe(item, action);
  }

  void _flingOut(SwipeAction action) {
    if (_animatingOut || _currentItem == null) return;
    final size = context.size ?? const Size(400, 600);
    final dx = switch (action) {
      SwipeAction.like => size.width * 1.5,
      SwipeAction.dislike => -size.width * 1.5,
      SwipeAction.save => 0.0,
    };
    final dy = action == SwipeAction.save ? -size.height : _drag.dy;
    _animatingOut = true;
    _animStart = _drag;
    _animEnd = Offset(dx, dy);
    _controller.duration = const Duration(milliseconds: 280);
    _controller.forward(from: 0).whenComplete(() {
      _controller.reset();
      _completeSwipe(action);
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_animatingOut) return;
    setState(() => _drag += d.delta);
  }

  void _animateBack() {
    _animatingOut = false;
    _animStart = _drag;
    _animEnd = Offset.zero;
    _controller.duration = const Duration(milliseconds: 220);
    _controller.forward(from: 0).whenComplete(_controller.reset);
  }

  void _onPanEnd(DragEndDetails d) {
    if (_animatingOut) return;
    const threshold = 110.0;
    if (_drag.dx > threshold) {
      _flingOut(SwipeAction.like);
    } else if (_drag.dx < -threshold) {
      _flingOut(SwipeAction.dislike);
    } else if (widget.saveEnabled && _drag.dy < -threshold) {
      _flingOut(SwipeAction.save);
    } else {
      _animateBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty || _index >= widget.items.length) {
      return widget.emptyState;
    }

    final current = widget.items[_index];
    final hasNext = _index + 1 < widget.items.length;
    final angle = (_drag.dx / 360).clamp(-0.4, 0.4);
    final likeOpacity = (_drag.dx / 120).clamp(0.0, 1.0);
    final dislikeOpacity = (-_drag.dx / 120).clamp(0.0, 1.0);
    final saveOpacity =
        widget.saveEnabled ? (-_drag.dy / 120).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Карточка позади.
              if (hasNext)
                Transform.scale(
                  scale: 0.94,
                  child: Opacity(
                    opacity: 0.6,
                    child: _CardFrame(
                      child: widget.cardBuilder(
                          context, widget.items[_index + 1]),
                    ),
                  ),
                ),
              // Верхняя карточка.
              Transform.translate(
                offset: _drag,
                child: Transform.rotate(
                  angle: angle,
                  child: GestureDetector(
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Stack(
                      children: [
                        _CardFrame(
                          child: widget.cardBuilder(context, current),
                        ),
                        _stamp('НРАВИТСЯ', AppColors.like, likeOpacity,
                            Alignment.topLeft, -0.3),
                        _stamp('ПРОПУСК', AppColors.dislike, dislikeOpacity,
                            Alignment.topRight, 0.3),
                        if (widget.saveEnabled)
                          _stamp('СОХРАНИТЬ', AppColors.save, saveOpacity,
                              Alignment.bottomCenter, 0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ActionBar(
          saveEnabled: widget.saveEnabled,
          onDislike: () => _flingOut(SwipeAction.dislike),
          onSave: () => _flingOut(SwipeAction.save),
          onLike: () => _flingOut(SwipeAction.like),
        ),
      ],
    );
  }

  Widget _stamp(String text, Color color, double opacity, Alignment align,
      double angle) {
    return Positioned.fill(
      child: Align(
        alignment: align,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: angle,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardFrame extends StatelessWidget {
  final Widget child;
  const _CardFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final bool saveEnabled;
  final VoidCallback onDislike;
  final VoidCallback onSave;
  final VoidCallback onLike;

  const _ActionBar({
    required this.saveEnabled,
    required this.onDislike,
    required this.onSave,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleButton(
            Icons.close_rounded, AppColors.dislike, 64, onDislike),
        if (saveEnabled) ...[
          const SizedBox(width: 20),
          _circleButton(
              Icons.bookmark_add_rounded, AppColors.save, 52, onSave),
        ],
        const SizedBox(width: 20),
        _circleButton(Icons.favorite_rounded, AppColors.like, 64, onLike),
      ],
    );
  }

  Widget _circleButton(
      IconData icon, Color color, double size, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: color.withValues(alpha: 0.4),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: color, size: size * 0.5),
        ),
      ),
    );
  }
}

/// Фоновый вспомогательный виджет: показывает пустую колоду.
class DeckEmpty extends StatelessWidget {
  final String title;
  final String subtitle;
  const DeckEmpty({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.check_circle_outline_rounded,
      title: title,
      subtitle: subtitle,
    );
  }
}

