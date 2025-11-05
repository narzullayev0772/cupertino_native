import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Glass container
class CNContainer extends StatelessWidget {
  final Widget? child;  // Ichki kontent (masalan, Text yoki Button)
  final double? width, height;  // O'lchamlar
  final BorderRadius? borderRadius;  // Burchaklar (default: 12)
  final GlassStyle style;  // Effekt stili: regular, prominent, ultraThin
  final bool isInteractive;  // Bosishda animatsiya

  /// Konstruktor
  const CNContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.style = GlassStyle.regular,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    // Platforma tekshiruvi (iOS uchun native)
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return _buildNativeGlass();  // Native Liquid Glass
    } else {
      return _buildFallbackGlass();  // Flutter fallback
    }
  }

  // Native iOS: cupertino_native dan foydalanib (yoki PlatformView)
  Widget _buildNativeGlass() {
    // cupertino_native da tayyor CNContainer yo'q, shuning uchun custom PlatformView
    // (Agar paket rivojlansa, undan foydalaning; hozircha oddiy UiKitView)
    return SizedBox(
      width: width,
      height: height,
      child: UiKitView(
        viewType: 'CupertinoNativeContainer',  // iOS da ro'yxatdan o'tkazilgan
        creationParams: {
          'style': style.toString().split('.').last,  // 'regular' yoki 'prominent'
          'radius': borderRadius?.resolve(TextDirection.ltr).topLeft.x ?? 12,
          'interactive': isInteractive,
        },
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }

  // Fallback: Standart Flutter BackdropFilter
  Widget _buildFallbackGlass() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.1),  // Shaffoflik
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),  // Blur effekti
          child: child,
        ),
      ),
    );
  }
}

// Enum stili (Apple dokumentatsiyasiga asoslanib)
enum GlassStyle { regular, prominent, ultraThin }