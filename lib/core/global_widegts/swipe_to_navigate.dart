import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a tile so the user can swipe left **or** right to open it.
///
/// Uses Flutter's built-in [Dismissible] for physics-based gesture handling:
/// the tile slides to reveal a coloured chevron strip, then springs back while
/// the [onOpen] callback navigates to the target screen.
class SwipeToNavigate extends StatelessWidget {
  final Widget child;

  /// Called when the swipe threshold is reached. May be sync or async.
  final void Function() onOpen;

  /// Unique key that identifies this tile in the widget tree.
  final Object dismissKey;

  /// Accent colour used for the chevron indicator strip.
  final Color color;

  /// Corner radius of the indicator strip (should match the tile's radius).
  final double borderRadius;

  const SwipeToNavigate({
    super.key,
    required this.child,
    required this.onOpen,
    required this.dismissKey,
    this.color = const Color(0xFF4CAF50),
    this.borderRadius = 10.0,
  });

  Widget _bg({required bool isLeft}) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [color.withValues(alpha: 0.04), color.withValues(alpha: 0.20)],
        begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Icon(
      isLeft ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
      color: color,
      size: 30,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(dismissKey),
      direction: DismissDirection.horizontal,
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        onOpen();
        return false; // spring back – tile stays in the list
      },
      background: _bg(isLeft: true),
      secondaryBackground: _bg(isLeft: false),
      child: child,
    );
  }
}
