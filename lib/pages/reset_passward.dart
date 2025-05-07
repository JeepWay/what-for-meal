import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';
import '../states/response.dart';
import '../widgets/widgets.dart';

class ResetPasswordDialog extends StatefulWidget {
  const ResetPasswordDialog({super.key});

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _resetEmailController = TextEditingController();

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);

    ResetPasswordWithEmailResponse response = await appState.resetPasswordWithEmail(
      email: _resetEmailController.text.trim(),
    );

    if (response.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
        _resetEmailController.clear();
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Column(
        crossAxisAlignment : CrossAxisAlignment.start,
        children: [
          Text('重置密碼', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('請輸入註冊時所使用的電子郵件', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
        ],
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _resetEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: '電子郵件',
            labelStyle: theme.textTheme.titleMedium,
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '請輸入電子郵件';
            }
            if (!_isValidEmail(value)) {
              return '請輸入有效的電子郵件地址';
            }
            return null;
          },
        ),
      ),
      actions: [
        WhiteElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _resetEmailController.clear();
          },
          label: const Text('取消'),
        ),
        PrimaryElevatedButton(
          onPressed: _resetPassword,
          label: const Text('發送'),
        ),
      ],
    );
  }
}