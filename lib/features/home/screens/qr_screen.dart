import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kigo_app/features/home/stores/home_store.dart';
import 'package:kigo_app/core/di/injection.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kigo_app/core/theme/app_theme.dart';

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
          backgroundColor: const Color(0xFF4CAF50),
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
      backgroundColor: Colors.black,
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
                        color: Colors.white,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B00),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Image.asset(
                      'assets/images/logo_kigo_white.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(
                        Icons.location_on_outlined,
                        size: 28,
                        color: Colors.white,
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.chat_outlined, size: 28, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Camera viewfinder area
          Expanded(
            flex: 5,
            child: Stack(
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
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // Flash toggle
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => _cameraController.toggleTorch(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
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
                            backgroundColor: const Color(0xFFFF6B00),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'Escanear QR',
                            style: TextStyle(
                              color: Colors.white,
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
                            backgroundColor: const Color(0xFFCC5500),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(
                            Icons.qr_code,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'Mostrar mi QR',
                            style: TextStyle(
                              color: Colors.white,
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
            ),
          ),

          // Bottom info panel
          Container(
            color: Colors.white,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _homeStore.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _homeStore.loadCardInfo(),
                            child: const Text(
                              'Reintentar',
                              style: TextStyle(
                                color: Color(0xFFFF6B00),
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
                              color: Color(0xFF999999),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }

                    final card = _homeStore.cardInfo!;
                    return Row(
                      children: [
                        // Country selector
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFDDDDDD),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  card.countryFlag,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Cambiar país',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: Color(0xFF555555),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Active card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFDDDDDD),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.credit_card,
                                      size: 18,
                                      color: Color(0xFF555555),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Tarjeta activa',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF555555),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '-\$${card.balance.abs().toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF6B00),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Feature buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Parquímetro',
                          style: TextStyle(
                            color: Colors.white,
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
                          backgroundColor: const Color(0xFFFF6B00),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Estatus',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
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
    const cutoutSize = 220.0;
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutoutSize,
      height: cutoutSize,
    );

    // Dark overlay
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw overlay with hole
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, overlayPaint);

    // Draw orange corner brackets
    final bracketPaint = Paint()
      ..color = const Color(0xFFFF6B00)
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
