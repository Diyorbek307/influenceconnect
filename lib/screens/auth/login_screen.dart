import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../data/seed_data.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../nav_helper.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AppRepository.instance.login(
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      AppNav.goHome(context);
    } on AppException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fill(String email, String pass) {
    _email.text = email;
    _password.text = pass;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.hub_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                Text(tr('welcome_back'),
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(tr('login_sub'),
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Введите email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: tr('password'),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Введите пароль' : null,
                ),
                const SizedBox(height: 24),
                GradientButton(
                  label: tr('login'),
                  icon: Icons.login_rounded,
                  loading: _loading,
                  onPressed: _login,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tr('no_account'),
                        style: Theme.of(context).textTheme.bodySmall),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: Text(tr('register')),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DemoAccounts(onPick: _fill),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Быстрый вход в демо-аккаунты (для проверки всех ролей).
class _DemoAccounts extends StatelessWidget {
  final void Function(String email, String pass) onPick;
  const _DemoAccounts({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Быстрый вход (демо)',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Нажмите, чтобы подставить данные, затем «Войти».',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(context, 'Админ', AppColors.warning,
                  () => onPick(SeedData.adminEmail, SeedData.adminPassword)),
              _chip(context, 'Бренд', AppColors.primary,
                  () => onPick('glow@demo.app', SeedData.demoPassword)),
              _chip(context, 'Блогер', AppColors.secondary,
                  () => onPick('anna@demo.app', SeedData.demoPassword)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }
}
