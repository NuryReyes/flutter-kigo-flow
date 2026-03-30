import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kigo_app/features/home/stores/home_store.dart';
import 'package:kigo_app/core/di/injection.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kigo_app/core/theme/app_theme.dart';

const double _scannerCutoutSize = 220;

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final HomeStore _homeStore = getIt<HomeStore>();
  final MobileScannerController _cameraController = MobileScannerController();
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _homeStore.loadCardInfo();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      _hasScanned = true;
      // TODO: handle scanned value via repository
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR detectado: ${barcode!.rawValue}'),
          backgroundColor: AppColors.green,
        ),
      );
      // Reset after 3 seconds so user can scan again
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _hasScanned = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          // Top app bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        size: 28,
                        color: AppColors.white,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 133,
                    child: Image.asset(
                      'assets/images/logo_kigo_white.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const Icon(
                    Icons.chat_outlined,
                    size: 28,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ),

          // Camera viewfinder area
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final cutoutHalf = _scannerCutoutSize / 2;
                final cutoutRight = w / 2 + cutoutHalf;
                final cutoutTop = h / 2 - cutoutHalf;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Live camera feed
                    MobileScanner(
                      controller: _cameraController,
                      onDetect: _onDetect,
                    ),

                    // Dark overlay with cutout
                    CustomPaint(
                      painter: _ScannerOverlayPainter(),
                      child: const SizedBox.expand(),
                    ),

                    // Title
                    const Positioned(
                      top: 24,
                      left: 0,
                      right: 0,
                      child: Text(
                        'Escanea el código QR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // Flash toggle
                    Positioned(
                      top: cutoutTop,
                      right: w - cutoutRight,
                      child: IconButton(
                        onPressed: () => _cameraController.toggleTorch(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.all(8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: const Size(44, 44),
                        ),
                        icon: const Icon(Icons.flash_on, size: 22),
                      ),
                    ),

                    // Bottom buttons
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(
                                Icons.qr_code_scanner,
                                color: AppColors.white,
                                size: 20,
                              ),
                              label: const Text(
                                'Escanear QR',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.unactive,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(
                                Icons.qr_code,
                                color: AppColors.white,
                                size: 20,
                              ),
                              label: const Text(
                                'Mostrar mi QR',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom info panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // Country selector + active card row
                  Observer(
                    builder: (_) {
                      if (_homeStore.isLoading) {
                        return const SizedBox(
                          height: 48,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }

                      if (_homeStore.errorMessage != null) {
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                _homeStore.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.redAlert,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _homeStore.loadCardInfo(),
                              child: const Text(
                                'Reintentar',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      if (!_homeStore.hasData) {
                        return const SizedBox(
                          height: 48,
                          child: Center(
                            child: Text(
                              'No hay tarjeta activa',
                              style: TextStyle(
                                color: AppColors.greyUnactive,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }

                      final card = _homeStore.cardInfo!;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Country selector
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 8,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            card.countryFlag,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 25,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 16,
                                          color: AppColors.greyUnactive,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Cambiar país',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.greyUnactive,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Active / inactive card
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 8,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.credit_card,
                                      size: 25,
                                      color: card.isActive
                                          ? AppColors.green
                                          : AppColors.greyUnactive,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      card.isActive
                                          ? 'Tarjeta activa'
                                          : 'Tarjeta inactiva',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.greyUnactive,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Card balance
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 8,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.account_balance_wallet_outlined,
                                      size: 25,
                                      color: AppColors.greyUnactive,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '\$${card.balance.toStringAsFixed(2)}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Feature buttons
          Padding(
            padding: const EdgeInsets.only(
              top: 15,
              left: 24,
              right: 24,
              bottom: 25,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.unactive,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    icon: const Icon(
                      Icons.location_on,
                      color: AppColors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'Parquímetro',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.unactive,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    icon: const Icon(
                      Icons.access_time,
                      color: AppColors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'Estatus',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the scanner overlay with cutout
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cutoutSize = _scannerCutoutSize;
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutoutSize,
      height: cutoutSize,
    );

    // Dark overlay
    final overlayPaint = Paint()
      ..color = AppColors.black.withValues(alpha: 0.6);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw overlay with hole
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, overlayPaint);

    // Draw orange corner brackets
    final bracketPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const bracketLength = 24.0;
    const r = 12.0;

    // Top-left
    canvas.drawLine(
      Offset(cutoutRect.left + r, cutoutRect.top),
      Offset(cutoutRect.left + r + bracketLength, cutoutRect.top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(cutoutRect.left, cutoutRect.top + r),
      Offset(cutoutRect.left, cutoutRect.top + r + bracketLength),
      bracketPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(cutoutRect.right - r, cutoutRect.top),
      Offset(cutoutRect.right - r - bracketLength, cutoutRect.top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(cutoutRect.right, cutoutRect.top + r),
      Offset(cutoutRect.right, cutoutRect.top + r + bracketLength),
      bracketPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(cutoutRect.left + r, cutoutRect.bottom),
      Offset(cutoutRect.left + r + bracketLength, cutoutRect.bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(cutoutRect.left, cutoutRect.bottom - r),
      Offset(cutoutRect.left, cutoutRect.bottom - r - bracketLength),
      bracketPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(cutoutRect.right - r, cutoutRect.bottom),
      Offset(cutoutRect.right - r - bracketLength, cutoutRect.bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(cutoutRect.right, cutoutRect.bottom - r),
      Offset(cutoutRect.right, cutoutRect.bottom - r - bracketLength),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
