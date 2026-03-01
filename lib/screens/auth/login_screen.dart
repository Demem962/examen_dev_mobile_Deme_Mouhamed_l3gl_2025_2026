import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authProvider = AuthProvider();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Valider le formulaire
    if (!_formKey.currentState!.validate()) return;

    final success = await _authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // Naviguer vers HomeScreen et supprimer tout l'historique
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    } else {
      // Afficher l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authProvider.error ?? 'Erreur de connexion'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              // Logo
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.task_alt,
                    size: 45,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Titre
              const Text(
                'Connexion',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bienvenue ! Connectez-vous pour continuer',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // Formulaire
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: AppStrings.email,
                      controller: _emailController,
                      hint: 'exemple@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.emailRequired;
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return AppStrings.invalidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: AppStrings.password,
                      controller: _passwordController,
                      hint: '••••••',
                      obscureText: true,
                      prefixIcon: Icons.lock_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.passwordRequired;
                        }
                        if (value.length < 6) {
                          return AppStrings.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Bouton connexion
                    ListenableBuilder(
                      listenable: _authProvider,
                      builder: (context, _) {
                        return CustomButton(
                          text: AppStrings.login,
                          isLoading: _authProvider.isLoading,
                          onPressed: _login,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Lien inscription
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Pas de compte ? ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      "S'inscrire",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}