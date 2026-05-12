import 'package:flutter/material.dart';
import 'package:mobile/features/auth/auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageHeight = size.height * 0.38;
    final imagePath = 'assets/images/headers/login_header.jpg';

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                AuthHeader(
                  imageHeight: imageHeight,
                  imagePath: imagePath,
                  title: 'AppAcademica',
                  description:
                      'Gestiona el progreso académico de tu institución.',
                ),
                Transform.translate(
                  offset: const Offset(0, -48),
                  child: const _LoginContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  const _LoginContent();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_LoginWelcomeSection(), SizedBox(height: 25), LoginForm()],
      ),
    );
  }
}

class _LoginWelcomeSection extends StatelessWidget {
  const _LoginWelcomeSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Inicia Sesión!',
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF111827),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text('Por favor ingresa tus datos.', style: textTheme.bodyMedium),
      ],
    );
  }
}
