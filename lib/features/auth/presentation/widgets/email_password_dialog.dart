import 'package:flutter/material.dart';

class EmailPasswordResult {
  final String email;
  final String password;

  const EmailPasswordResult({
    required this.email,
    required this.password,
  });
}

class EmailPasswordDialog extends StatefulWidget {
  final String title;
  final String actionText;
  final String? initialEmail;

  const EmailPasswordDialog({
    super.key,
    required this.title,
    required this.actionText,
    this.initialEmail,
  });

  static Future<EmailPasswordResult?> show(
    BuildContext context, {
    required String title,
    required String actionText,
    String? initialEmail,
  }) {
    return showDialog<EmailPasswordResult>(
      context: context,
      builder: (ctx) => EmailPasswordDialog(
        title: title,
        actionText: actionText,
        initialEmail: initialEmail,
      ),
    );
  }

  @override
  State<EmailPasswordDialog> createState() => _EmailPasswordDialogState();
}

class _EmailPasswordDialogState extends State<EmailPasswordDialog> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final email = _emailController.text.trim();
            final password = _passwordController.text;
            Navigator.pop(
              context,
              EmailPasswordResult(email: email, password: password),
            );
          },
          child: Text(widget.actionText),
        ),
      ],
    );
  }
}
