import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:kigo_app/features/auth/stores/otp_store.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());
  final OtpStore _otpStore = OtpStore();

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitEntered(String value, int index) {
    _otpStore.setDigit(index, value);
    if (value.isNotEmpty && index < 4) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _clearControllers() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B00),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Image.asset(
                            'assets/images/logo_kigo_orange.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        const Text(
                          'Ingresa el código enviado a:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Phone number in green
                        const Text(
                          '555 - 564 - 9712',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 5 digit inputs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            return SizedBox(
                              width: 60,
                              height: 60,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFDDDDDD),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFF6B00),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (val) => _onDigitEntered(val, index),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),

                        // Resend link
                        Observer(
                          builder: (_) => TextButton(
                            onPressed: _otpStore.isResending
                                ? null
                                : () async {
                                    await _otpStore.resendCode();
                                    _clearControllers();
                                  },
                            child: _otpStore.isResending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFFF6B00),
                                    ),
                                  )
                                : const Text(
                                    'Reenviar código',
                                    style: TextStyle(
                                      color: Color(0xFFFF6B00),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Error message
                        Observer(
                          builder: (_) => _otpStore.errorMessage != null
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    _otpStore.errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        // Continuar button
                        Observer(
                          builder: (_) => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _otpStore.canSubmit
                                  ? () async {
                                      await _otpStore.verifyOtp();
                                      if (_otpStore.errorMessage == null &&
                                          mounted) {
                                        context.go('/home/qr');
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _otpStore.canSubmit
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF999999),
                                disabledBackgroundColor: const Color(
                                  0xFF999999,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _otpStore.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          'Continuar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Help link
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            '¿Necesitas ayuda?',
                            style: TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  const Text(
                    '¡Que nada te detenga!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2023 Kigo - Parkimovil\nTodos los derechos reservados',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
