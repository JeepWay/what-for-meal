import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';
import '../widgets/widgets.dart';
import '../widgets/menu.dart';
import '../firebase/firebase_service.dart';
import '../firebase/model.dart';
import '../firebase/constants.dart';
import '../utils/geolocation_utils.dart';
import '../logging/logging.dart';

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
                    items: typeDropdownMenu,
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
                    items: priceDropdownMenu,
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
      backgroundColor: theme.colorScheme.surface,
      title: Center(
        child: Text('編輯清單', style: theme.textTheme.titleLarge)
      ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WhiteElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              label: const Text('取消'),
            ),
            PrimaryElevatedButton(
              onPressed: _updateList,
              label: const Text('儲存'),
            ),
          ],
        ),
      ],
    );
  }
}
class DoubleCheckDismissDialog extends StatelessWidget {
  const DoubleCheckDismissDialog({super.key, required this.displayText, this.titleText = '確認刪除'});
  final String titleText;
  final String displayText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Center(
        child: Text(titleText, style: theme.textTheme.titleLarge)
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          displayText,
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

class ShowRestaurantDialog extends StatelessWidget {
  final Restaurant restaurant;
  const ShowRestaurantDialog({
    required this.restaurant,
    super.key
  });

  void _launchGoogleMap(String name, String address) {
    final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$name $address')}';
    launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Center(
        child: Text(restaurant.name, style: theme.textTheme.titleLarge)
      ),
      content: Padding(
        padding: EdgeInsets.all(8),
        child: Wrap(
          spacing: 2,
          runSpacing: 24,
          alignment: WrapAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_sharp),
                const SizedBox(width: 10,),
                Flexible(
                  child: GestureDetector(
                    onTap: () => _launchGoogleMap(restaurant.name, restaurant.address),
                    child: Text(
                      restaurant.address,
                      softWrap: true,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.description),
                const SizedBox(width: 10,),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 180,
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        restaurant.description,
                        softWrap: true,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.restaurant_menu),
                const SizedBox(width: 10,),
                Text(restaurant.type, style: theme.textTheme.titleMedium)
              ],
            ),
            Row(
              children: [
                Icon(Icons.attach_money),
                const SizedBox(width: 10,),
                Text(restaurant.price, style: theme.textTheme.titleMedium)
              ],
            ),
            Row(
              children: [
                Icon(Icons.ac_unit),
                const SizedBox(width: 10,),
                Text(restaurant.hasAC ? '有冷氣' : '沒有冷氣', style: theme.textTheme.titleMedium)
              ],
            ),
          ],
        ),
      ),
      actions: [
        PrimaryElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          label: Text('關閉'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}



class EditRestaurantDialog extends StatefulWidget {
  const EditRestaurantDialog({
    required this.restaurant,
    super.key
  });

  final Restaurant restaurant;

  @override
  State<EditRestaurantDialog> createState() => _EditRestaurantDialogState();
}

class _EditRestaurantDialogState extends State<EditRestaurantDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;

  String? _selectedType;
  String? _selectedPrice;
  bool _hasAC = false;

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.restaurant.name);
    _addressController = TextEditingController(text: widget.restaurant.address);
    _descriptionController = TextEditingController(text: widget.restaurant.description);
    _selectedType = widget.restaurant.type;
    _selectedPrice = widget.restaurant.price;
    _hasAC = widget.restaurant.hasAC;
  }

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

  Future<void> _editRestaurant() async {
    setState(() {
      _errorMessage = '';
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final response = await FirebaseService.updateRestaurant(
      restaurantID: widget.restaurant.restaurantID,
      listID: widget.restaurant.listID,
      updates: {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType!,
        'price': _selectedPrice!,
        'hasAC': _hasAC,
      },
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
        child: Text('編輯餐廳', style: theme.textTheme.titleLarge)
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('請修改餐廳資訊', style: theme.textTheme.titleMedium),
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
                    items: typeDropdownMenu,
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
                    items: priceDropdownMenu,
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
              onPressed: _editRestaurant,
              label: const Text('確定'),
            ),
          ],
        ),
      ],
    );
  }
}

class EditFilterInMainDialog extends StatefulWidget {
  const EditFilterInMainDialog({super.key});

  @override
  State<EditFilterInMainDialog> createState() => _EditFilterInMainDialogState();
}

class _EditFilterInMainDialogState extends State<EditFilterInMainDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedType;
  String? _selectedPrice;
  bool? _hasAC;

  @override
  void initState() {
    super.initState();
    _selectedType = Provider.of<AppState>(context, listen: false).selectedFilterTypeInMain;
    _selectedPrice = Provider.of<AppState>(context, listen: false).selectedFilterPriceInMain;
    _hasAC = Provider.of<AppState>(context, listen: false).selectedFilterHasACInMain;
    logger.d("現在篩選條件: $_selectedType, $_selectedPrice, $_hasAC");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Center(
        child: Text('設定篩選條件', style: theme.textTheme.titleLarge)
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: '類型',
                      labelStyle: theme.textTheme.titleMedium,
                      prefixIcon: const Icon(Icons.restaurant_menu),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('不限制')),
                      ...typeDropdownMenu,
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
                    items: [
                      const DropdownMenuItem(value: null, child: Text('不限制')),
                      ...priceDropdownMenu,
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

                  DropdownButtonFormField<bool?>(
                    value: _hasAC,
                    decoration: InputDecoration(
                      labelText: '有無冷氣',
                      labelStyle: theme.textTheme.titleMedium,
                      prefixIcon: const Icon(Icons.ac_unit),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('不限制')),
                      DropdownMenuItem(value: true, child: Text('有冷氣')),
                      DropdownMenuItem(value: false, child: Text('無冷氣')),
                    ],
                    onChanged: (bool? value) {
                      setState(() {
                        _hasAC = value; // 允許 null, true, false
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return '請選擇冷氣條件';
                      }
                      return null;
                    },
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
              onPressed: () => Navigator.of(context).pop(),
              label: const Text('取消'),
            ),
            PrimaryElevatedButton(
              onPressed: () {
                Provider.of<AppState>(context, listen: false)
                  .setFilterInMain(
                    type: _selectedType,
                    price: _selectedPrice,
                    hasAC: _hasAC,
                  );
                Navigator.of(context).pop();
              },
              label: const Text('確定'),
            ),
          ],
        ),
      ],
    );
  }
}

/// 收藏餐廳功能：顯示要把餐廳加到哪個清單中
class SelectListDialog extends StatefulWidget {
  const SelectListDialog({super.key, required this.onListSelected});
  final Function? onListSelected;
  
  @override
  State<SelectListDialog> createState() => _SelectListDialogState();
}

class _SelectListDialogState extends State<SelectListDialog> {
  late final List<PersonalList> personalLists;

  @override
  void initState() {
    personalLists =  Provider.of<AppState>(context, listen: false).personalLists;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Center(child: Text('選擇要加入的清單', style: theme.textTheme.titleLarge)),
      content: SizedBox(
        width: double.minPositive,
        child: personalLists.isEmpty
            ? const Text('尚未建立任何清單', textAlign: TextAlign.center,)
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: personalLists.length,
                itemBuilder: (context, index) {
                  final list = personalLists[index];
                  return ListTile(
                    leading: Icon(Icons.list_alt),
                    title: Text(list.title),
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onListSelected!.call(list);
                    },
                  );
                },
              ),
      ),
      actions: [
        PrimaryElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          label: Text('關閉'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center
    );
  }
}

class SetShareWithUsersDialog extends StatefulWidget {
  const SetShareWithUsersDialog({
    required this.list,
    super.key,
  });

  final PersonalList list;

  @override
  State<SetShareWithUsersDialog> createState() => _SetShareWithUsersDialogState();
}

class _SetShareWithUsersDialogState extends State<SetShareWithUsersDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  List<Map<String, dynamic>> _sharedUsers = [];

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSharedUsers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  Future<void> _loadSharedUsers() async {
    final response = await FirebaseService.getSharedUser(
      listID: widget.list.listID,
    );

    setState(() {
      _sharedUsers = response.usersList!;
    });
  }

  Future<void> _addSharedUserByEmail() async {
    setState(() {
      _errorMessage = '';
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final response = await FirebaseService.addSharedUserByEmail(
      listID: widget.list.listID,
      email: _emailController.text.trim(),
    );

    setState(() {
      if (response.success) {
        _emailController.clear();
        _loadSharedUsers();
      } else {
        _errorMessage = response.message;
        _loadSharedUsers();
      }
    });
  }

  Future<void> _removeSharedUserByID(String userID) async {
    setState(() {
      _errorMessage = '';
    });

    final response = await FirebaseService.removeSharedUser(
      listID: widget.list.listID,
      userID: userID,
    );

    setState(() {
      if (response.success) {
        _loadSharedUsers();
      } else {
        _errorMessage = response.message;
        _loadSharedUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Center(
        child: Text('設定共享使用者', style: theme.textTheme.titleLarge)
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('請輸入欲共享的使用者的電子郵件', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: '電子郵件',
                        labelStyle: Theme.of(context).textTheme.titleMedium,
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
                ),
                const SizedBox(width: 5),
                PrimaryElevatedButton(
                  onPressed: _addSharedUserByEmail,
                  label: const Text('新增'),
                ),
              ],
            ),
            const SizedBox(height: 5),
      
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 20),
      
            Center(
              child: Text('目前已共享的使用者：', style: theme.textTheme.titleMedium)
            ),
            const SizedBox(height: 10),

            if (_sharedUsers.isEmpty)
              const Text('尚未共享給任何使用者')
            else ...[
              Container(
                color: theme.colorScheme.secondary,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _sharedUsers.length,
                  itemBuilder: (context, index) {
                    final user = _sharedUsers[index];
                    return ListTile(
                      leading: Icon(Icons.person),
                      title: Text(user[UserFileds.userName]),
                      subtitle: Text(user[UserFileds.email]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: theme.colorScheme.error),
                        onPressed: () => {
                          _removeSharedUserByID(
                            user[PersonalListFields.userID],
                          ),
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        PrimaryElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          label: const Text('關閉'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}
/// 顯示活動的 detail
class EventDetailDialog extends StatelessWidget {
  const EventDetailDialog({super.key, required this.event});
  final Event event;

  void _launchGoogleMap(String name, String address) {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$name $address')}';
    launchUrl(Uri.parse(url));
  }

  String _getCountdownText(DateTime eventTime) {
    final now = DateTime.now();
    final diff = eventTime.difference(now);

    if (diff.isNegative) return '已開始';
    if (diff.inDays > 0) return '剩 ${diff.inDays} 天';
    if (diff.inHours > 0) return '剩 ${diff.inHours} 小時';
    if (diff.inMinutes > 0) return '剩 ${diff.inMinutes} 分';
    return '即將開始';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countdownText = _getCountdownText(event.dateTime.toDate());
    final creator = event.participantNames.isNotEmpty
        ? event.participantNames.first
        : '未知';

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Row(
        children: [
          Icon(Icons.event, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.title,
              style: theme.textTheme.headlineSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItem(
                context,
                icon: Icons.flag,
                label: '活動目的',
                value: event.goal,
              ),
              _buildItemWithButton(
                context,
                icon: Icons.place,
                label: '活動地點',
                value: '餐廳: ${event.restoName}\n地址: ${event.address}',
                buttonLabel: '查看地圖',
                onPressed: () => _launchGoogleMap(event.restoName, event.address),
              ),
              _buildItem(
                context,
                icon: Icons.access_time_filled,
                label: '活動時間',
                value: '${event.formattedDate} ${event.formattedTime}',
              ),
              _buildItem(
                context,
                icon: Icons.timer,
                label: '倒數時間',
                value: countdownText,
              ),
              _buildItem(
                context,
                icon: Icons.person_pin,
                label: '創建者',
                value: creator,
              ),
              _buildItem(
                context,
                icon: Icons.man_rounded,
                label: '人數限制',
                value: '${event.participantNames.length} / ${event.numberOfPeople}',
              ),
              _buildItem(
                context,
                icon: Icons.description,
                label: '活動細節',
                value: event.description,
              ),
              _buildItem(
                context,
                icon: Icons.people,
                label: '參加人員',
                value: event.participantNames,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required dynamic value,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    final displayText = value is List<String>
        ? value.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')
        : value.toString();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$label:',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayText,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemWithButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(buttonLabel),
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}