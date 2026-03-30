import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:kigo_app/core/di/injection.dart';
import 'package:kigo_app/core/theme/app_theme.dart';
import 'package:kigo_app/features/auth/stores/otp_store.dart';
import 'package:kigo_app/features/auth/repositories/auth_repository.dart';

String _formatPhone10(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 10) return raw;
  final ten = digits.length > 10
      ? digits.substring(digits.length - 10)
      : digits;
  return '${ten.substring(0, 3)} - ${ten.substring(3, 6)} - ${ten.substring(6, 10)}';
}

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());
  late final OtpStore _otpStore;

  @override
  void initState() {
    super.initState();
    _otpStore = OtpStore(getIt<AuthRepository>(), widget.phoneNumber);
  }

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
      backgroundColor: AppColors.primary,
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
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        SizedBox(
                          width: 124,
                          child: Image.asset(
                            'assets/images/logo_kigo_orange.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 34),

                        // Title
                        const Text(
                          'Ingresa el código enviado a:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Phone number in green
                        Text(
                          _formatPhone10(widget.phoneNumber),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 5 digit inputs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            return SizedBox(
                              width: 52,
                              height: 54,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.greyUnactive,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
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
                                      color: AppColors.primary,
                                    ),
                                  )
                                : const Text(
                                    'Reenviar código',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 100),

                        // Error message
                        Observer(
                          builder: (_) => _otpStore.errorMessage != null
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    _otpStore.errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.redAlert,
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
                                      if (_otpStore.errorMessage != null ||
                                          !context.mounted) {
                                        return;
                                      }
                                      context.go('/home/qr');
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _otpStore.canSubmit
                                    ? AppColors.green
                                    : AppColors.greyUnactive,
                                disabledBackgroundColor: AppColors.greyUnactive,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _otpStore.isLoading
                                  ? const CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2,
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          'Continuar',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.chevron_right,
                                          color: AppColors.white,
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
                              color: AppColors.greyUnactive,
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
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2023 Kigo - Parkimovil\nTodos los derechos reservados',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
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
