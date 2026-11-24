import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final codeController = TextEditingController();
  bool loading = false;
  String error = '';

  Future<void> verifyCode() async {
    final code = codeController.text.trim();

    if (!RegExp(r'^\d{4}$').hasMatch(code)) {
      setState(() => error = 'Please enter a valid 4-digit code.');
      return;
    }

    setState(() {
      loading = true;
      error = '';
    });

    try {
      await ApiService.login(widget.email, code);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> resendCode() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      await ApiService.sendCode(widget.email);
      if (!mounted) return;

      codeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New verification code sent!')),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 85,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Check your email',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We sent a 4-digit verification code to\n${widget.email}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 4,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: const TextStyle(
                      fontSize: 28,
                      letterSpacing: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0000',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: loading ? null : verifyCode,
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Verify and continue'),
                  ),
                  const SizedBox(height: 20),
                  const Text("Didn't receive the code?"),
                  TextButton(
                    onPressed: loading ? null : resendCode,
                    child: const Text('Resend code'),
                  ),
                  TextButton(
                    onPressed: loading
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Change email address'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}