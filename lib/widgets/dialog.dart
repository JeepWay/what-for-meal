import 'package:flutter/material.dart';

import '../widgets/widgets.dart';
import '../firebase/firebase_service.dart';


class ResetPasswordDialog extends StatefulWidget {
  const ResetPasswordDialog({super.key});

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _resetEmailController = TextEditingController();

  String _errorMessage = '';

  @override
  void dispose() {
    _resetEmailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  Future<void> _resetPassword() async {
    setState(() {
      _errorMessage = '';
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final response = await FirebaseService.resetPasswordWithEmail(
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
      setState(() {
        _errorMessage = response.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Center(
        child: Text('重置密碼', style: theme.textTheme.titleLarge)
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('請輸入註冊時所使用的電子郵件', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: '電子郵件',
                labelStyle: theme.textTheme.titleMedium,
                prefixIcon: const Icon(Icons.email),
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
          const SizedBox(height: 3),

          if (_errorMessage.isNotEmpty) 
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _errorMessage,
                style: theme.textTheme.titleSmall!.copyWith(
                  color: theme.colorScheme.error
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
        ),
      ],
    );
  }
}


class AddPersonalListDialog extends StatefulWidget {
  const AddPersonalListDialog({super.key});

  @override
  State<AddPersonalListDialog> createState() => _AddPersonalListDialogState();
}

class _AddPersonalListDialogState extends State<AddPersonalListDialog> {
  final _formKey = GlobalKey<FormState>();
  final _listTitleController = TextEditingController();

  String _errorMessage = '';

  @override
  void dispose() {
    _listTitleController.dispose();
    super.dispose();
  }

  Future<void> _addList() async {
    setState(() {
      _errorMessage = '';
    });
    
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final response = await FirebaseService.addNewList(
      title: _listTitleController.text.trim(),
    );

    if (response.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message,
              textAlign: TextAlign.center,
            ),
            duration: Duration (seconds: 3),
            showCloseIcon: true,
          ),
        );
        _listTitleController.clear();
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        _errorMessage = response.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Center(
        child: Text('新增清單', style: theme.textTheme.titleLarge)
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('請輸入欲新增清單的標題', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _listTitleController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: '清單標題',
                    labelStyle: theme.textTheme.titleMedium,
                    prefixIcon: const Icon(Icons.list_alt),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入清單標題';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 3),

                if (_errorMessage.isNotEmpty) 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage,
                      style: theme.textTheme.titleSmall!.copyWith(
                        color: theme.colorScheme.error
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WhiteElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _listTitleController.clear();
              },
              label: const Text('取消'),
            ),
            PrimaryElevatedButton(
              onPressed: _addList,
              label: const Text('確定'),
            ),
          ],
        ),
      ],
    );
  }
}
