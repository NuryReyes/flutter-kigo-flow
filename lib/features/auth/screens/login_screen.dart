import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kigo_app/core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _privacyAccepted = false;

  bool get _canSubmit => _privacyAccepted && _phoneController.text.length == 10;

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
            // Card
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
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Phone input
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFDDDDDD)),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.phone_android,
                                color: Color(0xFF999999),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '+52',
                                style: TextStyle(
                                  color: Color(0xFFFF6B00),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
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
                                      color: Color(0xFF999999),
                                    ),
                                    border: InputBorder.none,
                                    counterText: '',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Privacy policy toggle
                        Row(
                          children: [
                            Switch(
                              value: _privacyAccepted,
                              onChanged: (val) =>
                                  setState(() => _privacyAccepted = val),
                              activeThumbColor: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.grey700,
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
                        const SizedBox(height: 24),

                        // CTA Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _canSubmit
                                ? () {
                                    // TODO: navigate to OTP
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _canSubmit
                                  ? const Color(0xFFFF6B00)
                                  : const Color(0xFF999999),
                              disabledBackgroundColor: const Color(0xFF999999),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Recibir código por SMS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.chevron_right, color: Colors.white),
                              ],
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

            // Footer outside card
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
