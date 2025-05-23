import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/widgets.dart';
import '../firebase/firebase_service.dart';
import '../firebase/model.dart';
import '../utils/geolocation_utils.dart';

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


class AddRestaurantDialog extends StatefulWidget {
  const AddRestaurantDialog({
    required this.listID,
    super.key
  });

  final String listID;

  @override
  State<AddRestaurantDialog> createState() => _AddRestaurantDialogState();
}

class _AddRestaurantDialogState extends State<AddRestaurantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedType;
  String? _selectedPrice;
  bool _hasAC = false;

  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _launchGoogleMap() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = '請輸入餐廳名稱以開啟 Google Map 查詢餐廳地址';
      });
      return;
    }

    final url = generateGoogleMapLink(name);
    launchUrl(Uri.parse(url));
  }

  Future<void> _addRestaurant() async {
    setState(() {
      _errorMessage = '';
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final response = await FirebaseService.addNewRestaurant(
      listID: widget.listID,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType!,
      price: _selectedPrice!,
      hasAC: _hasAC,
    );

    if (response.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
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
        child: Text('新增餐廳', style: theme.textTheme.titleLarge)
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('請輸入餐廳資訊', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: '名稱',
                      labelStyle: theme.textTheme.titleMedium,
                      prefixIcon: const Icon(Icons.storefront),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入餐廳名稱';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),

                  TransparentTextButton(
                    onPressed: _launchGoogleMap,
                    label: Text('開啟 Google Map 查地址'),
                    icon: Icon(Icons.near_me, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 6),

                  TextFormField(
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    decoration: InputDecoration(
                      labelText: '地址',
                      labelStyle: theme.textTheme.titleMedium,
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入餐廳地址\n或開啟 Google Map 來查詢';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),

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

                  TextFormField(
                    controller: _descriptionController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: '描述',
                      labelStyle: theme.textTheme.titleMedium,
                      prefixIcon: const Icon(Icons.description),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入餐廳描述';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),

                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: '類型',
                      labelStyle: theme.textTheme.titleMedium,
                      prefixIcon: const Icon(Icons.restaurant_menu),
                    ),
                    items: const [
                      DropdownMenuItem(value: '中式', child: Text('中式')),
                      DropdownMenuItem(value: '西式', child: Text('西式')),
                      DropdownMenuItem(value: '日式', child: Text('日式')),
                      DropdownMenuItem(value: '台式', child: Text('台式')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return '請選擇餐廳類型';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),

                  DropdownButtonFormField<String>(
                    value: _selectedPrice,
                    decoration: InputDecoration(
                      labelText: '價格範圍',
                      labelStyle: theme.textTheme.titleMedium,
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    items: const [
                      DropdownMenuItem(value: '1-99', child: Text('1-99')),
                      DropdownMenuItem(value: '100-199', child: Text('100-199')),
                      DropdownMenuItem(value: '200-299', child: Text('200-299')),
                      DropdownMenuItem(value: '300以上', child: Text('300以上')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPrice = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return '請選擇價格範圍';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),

                  CheckboxListTile(
                    title: Text(
                      '是否有冷氣',
                      style: theme.textTheme.titleMedium,
                    ),
                    value: _hasAC,
                    onChanged: (value) {
                      setState(() {
                        _hasAC = value ?? false; // ensure value isn't null
                      });
                    },
                    secondary: const Icon(Icons.ac_unit),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WhiteElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              label: const Text('取消'),
            ),
            PrimaryElevatedButton(
              onPressed: _addRestaurant,
              label: const Text('確定'),
            ),
          ],
        ),
      ],
    );
  }
}


class PublicizePersonalListDialog extends StatefulWidget {
  const PublicizePersonalListDialog({
    required this.list,
    super.key,
  });

  final PersonalList list;

  @override
  State<PublicizePersonalListDialog> createState() => _PublicizePersonalListDialogState();
}

class _PublicizePersonalListDialogState extends State<PublicizePersonalListDialog> {
  bool _isPublic = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _isPublic = widget.list.isPublic;
  }

  Future<void> _updateList() async {
    setState(() {
      _errorMessage = '';
    });

    final response = await FirebaseService.updateList(
      listID: widget.list.listID,
      updates: {
        'isPublic': _isPublic,
      },
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
        child: Text('公開 ${widget.list.title} 清單', style: theme.textTheme.titleLarge)
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '是否要公開當前清單內容，讓所有使用者皆可看到該清單，但其他使用者不能修改內容。\n\n'
          '當前清單狀態: ${widget.list.isPublic ? '公開' : '不公開'}'
          , style: theme.textTheme.titleMedium
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WhiteElevatedButton(
              label: Text('不公開'),
              onPressed: () {
                setState(() {
                  _isPublic = false;
                });
              },
              style:ElevatedButton.styleFrom(
                backgroundColor: !_isPublic
                    ? theme.colorScheme.primary
                    : Colors.white,
                foregroundColor: !_isPublic
                    ? theme.colorScheme.onPrimary
                    : Colors.grey,
                textStyle: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 10),
            WhiteElevatedButton(
              label: Text('公開'),
              onPressed: () {
                setState(() {
                  _isPublic = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPublic
                    ? theme.colorScheme.primary
                    : Colors.white,
                foregroundColor: _isPublic
                    ? theme.colorScheme.onPrimary
                    : Colors.grey,
                textStyle: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

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

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WhiteElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              label: const Text('取消'),
            ),
            PrimaryElevatedButton(
              onPressed: _updateList,
              label: const Text('確定'),
            ),
          ],
        ),
      ],
    );
  }
}


class EditListDialog extends StatefulWidget {
  const EditListDialog({super.key, required this.list});

  final PersonalList list;

  @override
  State<EditListDialog> createState() => _EditListDialogState();
}

class _EditListDialogState extends State<EditListDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.list.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _updateList() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final response = await FirebaseService.updateList(
      listID: widget.list.listID,
      updates: {
        'title': _titleController.text.trim(),
      },
    );

    if (response.success) {
      if (mounted) {
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
      title: Text('編輯清單', style: theme.textTheme.titleLarge),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '清單標題',
                labelStyle: theme.textTheme.titleMedium,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '請輸入清單標題';
                }
                return null;
              },
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _updateList,
          child: const Text('儲存'),
        ),
      ],
    );
  }
}


class DoubleCheckDismissDialog extends StatelessWidget {
  const DoubleCheckDismissDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Center(
        child: Text('確認刪除', style: theme.textTheme.titleLarge)
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '確定要刪除這個清單/餐廳嗎？', 
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WhiteElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              label: const Text('取消'),
            ),
            PrimaryElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              label: const Text('確定'),
            ),
          ],
        ),
      ],
    );
  }
}