import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:kigo_app/features/auth/stores/auth_store.dart';
import 'package:kigo_app/core/theme/app_theme.dart';
import 'package:kigo_app/core/di/injection.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthStore _authStore = getIt<AuthStore>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Image.asset(
                            'assets/images/logo_kigo_orange.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        const Text(
                          'Ingresa con tu número celular',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Phone input
                        Container(
                          color: AppColors.white,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.phone_android,
                                color: AppColors.greyUnactive,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '+52',
                                style: TextStyle(
                                  color: AppColors.lightBlue,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 10,
                                  decoration: const InputDecoration(
                                    hintText: 'Teléfono celular',
                                    hintStyle: TextStyle(
                                      color: AppColors.greyUnactive,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    filled: true,
                                    fillColor: AppColors.white,
                                    counterText: '',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (val) =>
                                      _authStore.setPhoneNumber(val),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.greyUnactive,
                        ),
                        const SizedBox(height: 24),

                        // Privacy toggle
                        Observer(
                          builder: (_) => Row(
                            children: [
                              Transform.scale(
                                scale: 0.72,
                                alignment: Alignment.centerLeft,
                                child: CupertinoSwitch(
                                  value: _authStore.privacyAccepted,
                                  onChanged: _authStore.togglePrivacy,
                                  activeTrackColor: AppColors.primary,
                                  inactiveTrackColor: AppColors.greyUnactive,
                                  thumbColor: AppColors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.greyUnactive,
                                    ),
                                    children: [
                                      TextSpan(text: 'Acepto '),
                                      TextSpan(
                                        text:
                                            'Política de privacidad, términos y condiciones',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // CTA button
                        Observer(
                          builder: (_) => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _authStore.canSubmit
                                  ? () async {
                                      await _authStore.requestOtp();
                                      if (_authStore.errorMessage != null ||
                                          !context.mounted) {
                                        return;
                                      }
                                      context.go(
                                        '/otp',
                                        extra: _authStore.phoneNumber,
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _authStore.canSubmit
                                    ? AppColors.primary
                                    : AppColors.greyUnactive,
                                disabledBackgroundColor: AppColors.greyUnactive,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _authStore.isLoading
                                  ? const CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2,
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          'Recibir código por SMS',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w600,
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

                        // Error message
                        Observer(
                          builder: (_) => _authStore.errorMessage != null
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    _authStore.errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.redAlert,
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        // Help link
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            '¿Necesitas ayuda?',
                            style: TextStyle(
                              color: AppColors.blue,
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
