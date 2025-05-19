import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/widgets.dart';
import '../firebase/firebase_service.dart';
import 'reset_passward.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final response = await FirebaseService.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (response.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            duration: Duration(seconds: 2),
          ),
        );
        context.go('/home');
      }
    } else {
      setState(() {
        _errorMessage = response.message;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final response = await FirebaseService.signInWithGoogle();

    if (response.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            duration: Duration(seconds: 2),
          ),
        );
        context.go('/home');
      }
    } else {
      setState(() {
        _errorMessage = response.message;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo 和標題
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '這餐吃什麼',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 8),
                  
                  Text(
                    '登入你的帳號',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // 電子郵件輸入框
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: '電子郵件',
                      labelStyle: theme.textTheme.titleMedium,
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入電子郵件';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 密碼輸入框
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: '密碼',
                      labelStyle: theme.textTheme.titleMedium,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入密碼';
                      }
                      return null;
                    },
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TransparentTextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ResetPasswordDialog();
                            }
                          );
                        },
                        label: const Text('忘記密碼？'),
                      ),
                    ]
                  ),
                  
                  // 錯誤信息
                  if (_errorMessage.isNotEmpty) 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // 登入按鈕
                  SizedBox(
                    height: 56,
                    child: PrimaryOutlinedButton(
                      onPressed: _isLoading ? null : _signInWithEmail,
                      label: _isLoading
                          ? CircularProgressIndicator(color: theme.colorScheme.onPrimary)
                          : const Text('登入'),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 註冊選項
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '還沒有帳號 ？', 
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      TransparentTextButton(
                        onPressed: () => context.go('/register'),
                        label: const Text('註冊'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Divider(thickness: 1.5)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '以其他帳號登入',
                          style: theme.textTheme.titleSmall!.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(thickness: 1.5)),
                    ],
                  ),

                  const SizedBox(height: 16),
                  
                  SizedBox(
                    height: 56,
                    child: WhiteOutlinedButton(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      icon: Image.asset("assets/google-icon.png"),
                      label: _isLoading
                        ? const Text('Google 帳號登入中，請稍後')
                        : const Text('Google 帳號登入'),
                    ),
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