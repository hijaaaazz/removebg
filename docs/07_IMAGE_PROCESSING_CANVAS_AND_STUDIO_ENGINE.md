# 07. Image Processing, Canvas & Studio Engine

The **Studio Canvas** is the core interactive workspace of RemoveIt. It gives users immediate visual feedback, edge inspection, background styling, and high-fidelity photo exports.

---

## 1. Studio Canvas Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                        InteractiveViewer (Pan & Zoom)                  │
│                                                                        │
│   ┌────────────────────────────────────────────────────────────────┐   │
│   │                     Backdrop Layer                             │   │
│   │   (Checkerboard / Solid Color / Gradient / Custom Photo / Blur)│   │
│   └────────────────────────────────┬───────────────────────────────┘   │
│                                    │                                   │
│   ┌────────────────────────────────▼───────────────────────────────┐   │
│   │               Subject Foreground Layer (Alpha Mask)            │   │
│   │         (Cutout subject rendered with transparent alpha)       │   │
│   └────────────────────────────────┬───────────────────────────────┘   │
│                                    │                                   │
│   ┌────────────────────────────────▼───────────────────────────────┐   │
│   │                Split Comparison Overlay (ClipRect)             │   │
│   │     (Original un-edited photo clipped to slider percentage)    │   │
│   └────────────────────────────────┬───────────────────────────────┘   │
│                                    │                                   │
│   ┌────────────────────────────────▼───────────────────────────────┐   │
│   │             Vertical Divider Bar & Circular Thumb              │   │
│   │             (Draggable handle with haptic feedback ticks)      │   │
│   └────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Interactive Split Comparison Slider Implementation

```dart
// lib/core/widgets/canvas/comparison_slider.dart
import 'package:flutter/material.dart';
import 'package:removeit_app/core/services/haptic_service.dart';

class ComparisonSlider extends StatefulWidget {
  final Widget originalImage;
  final Widget processedImage;
  final double initialPosition;

  const ComparisonSlider({
    super.key,
    required this.originalImage,
    required this.processedImage,
    this.initialPosition = 0.5,
  });

  @override
  State<ComparisonSlider> createState() => _ComparisonSliderState();
}

class _ComparisonSliderState extends State<ComparisonSlider> {
  late double _sliderPosition;

  @override
  void initState() {
    super.initState();
    _sliderPosition = widget.initialPosition;
  }

  void _updatePosition(double localDx, double width) {
    final newPos = (localDx / width).clamp(0.0, 1.0);
    // Trigger subtle haptic click when passing exact center
    if ((_sliderPosition < 0.5 && newPos >= 0.5) || (_sliderPosition > 0.5 && newPos <= 0.5)) {
      HapticService.selection();
    }
    setState(() => _sliderPosition = newPos);
  }

  void _resetToCenter() {
    HapticService.light();
    setState(() => _sliderPosition = 0.5);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return GestureDetector(
          onDoubleTap: _resetToCenter,
          onHorizontalDragUpdate: (details) => _updatePosition(details.localPosition.dx, width),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Processed Layer (Cutout with active backdrop)
              widget.processedImage,

              // 2. Original Layer clipped to slider position
              ClipRect(
                clipper: _SliderClipper(_sliderPosition),
                child: widget.originalImage,
              ),

              // 3. Divider Line
              Positioned(
                left: (width * _sliderPosition) - 1.5,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),

              // 4. Thumb Handle
              Positioned(
                left: (width * _sliderPosition) - 20,
                top: (height / 2) - 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.compare_arrows_rounded, color: Colors.black87, size: 22),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliderClipper extends CustomClipper<Rect> {
  final double fraction;
  _SliderClipper(this.fraction);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * fraction, size.height);
  }

  @override
  bool shouldReclip(_SliderClipper oldClipper) => oldClipper.fraction != fraction;
}
```

---

## 3. Dynamic Backdrop Styling System

RemoveIt provides five backdrop modes that users can apply instantly without re-running AI inference:

### 3.1 Mode 1: Transparent Checkerboard
- Default mode for PNG graphic designers and e-commerce sellers.
- Painted with high-contrast studio squares (`#1A202C` and `#2D3748`).

### 3.2 Mode 2: Studio Solid Colors
- Clean solid backdrops for passport photos, Amazon/Shopify product listings, and ID badges.
- Presets: Pure White (`#FFFFFF`), Studio Pitch Black (`#000000`), E-Commerce Off-White (`#F8FAFC`), Soft Pastel Blue, Cyber Mint.

### 3.3 Mode 3: Studio Gradients
- Radial and linear studio lighting backdrops (e.g., Spotlight Violet, Soft Sunset, Clean Apple Studio Gray).

### 3.4 Mode 4: Custom Image Replacement
- Allows user to choose a replacement background photo from their device (e.g. Paris Eiffel Tower, office interior, tropical beach).

### 3.5 Mode 5: Bokeh Background Blur
- Uses the original unsegmented photo, applies real-time Gaussian blur (`ImageFilter.blur(sigmaX: 18, sigmaY: 18)`), and composites the crisp cutout on top for a DSLR portrait mode look.

---

## 4. High-Resolution Compositing & Export Pipeline

When the user taps **"Save to Camera Roll"** or **"Share"**, the composite image must be generated at full target resolution:

```dart
// lib/core/services/gallery_saver_service.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class GallerySaverService {
  /// Renders the composite subject + backdrop at target dimensions and writes to Camera Roll
  static Future<bool> saveToGallery({
    required ui.Image subjectImage,
    Color? solidColor,
    ui.Image? backdropImage,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, subjectImage.width.toDouble(), subjectImage.height.toDouble()));

    final size = Size(subjectImage.width.toDouble(), subjectImage.height.toDouble());

    // 1. Draw Backdrop
    if (solidColor != null) {
      canvas.drawRect(Offset.zero & size, Paint()..color = solidColor);
    } else if (backdropImage != null) {
      paintImage(
        canvas: canvas,
        rect: Offset.zero & size,
        image: backdropImage,
        fit: BoxFit.cover,
      );
    }

    // 2. Draw Transparent Cutout Subject
    canvas.drawImage(subjectImage, Offset.zero, Paint());

    final picture = recorder.endRecording();
    final composite = await picture.toImage(subjectImage.width, subjectImage.height);
    final byteData = await composite.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return false;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/cutout_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    // Save to native Photos / Gallery with permissions handled
    await Gal.putImage(file.path);
    return true;
  }
}
```

---

## 5. Free vs. Pro Resolution Tiers

| Resolution Tier | Free Tier (Claimed with Daily Quota or Ad) | Pro Tier (Active Subscription) |
| :--- | :--- | :--- |
| **Export Dimensions** | Clamped to **1080p** (max edge = 1920px) | **100% Native Sensor** (e.g. 4032x3024 / 48MP) |
| **Output Format** | Optimized 8-bit PNG or JPEG | 32-bit Lossless PNG |
| **Watermark** | None (clean output once claimed) | None |
| **Compression** | Standard web optimization | Lossless Studio Master |
