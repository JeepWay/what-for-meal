import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:what_for_meal/utils/geolocation_utils.dart';
import 'package:what_for_meal/widgets/widgets.dart';
import '../firebase/model.dart';
import '../firebase/firebase_service.dart';

/// 功能：新增/編輯活動的表單
class EventFormPage extends StatefulWidget {
  /// 如果傳入 event, 就是編輯
  final Event? event;

  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl, _descCtrl, _numCtrl,
                                  _restoCtrl, _addressCtrl, _dateCtrl, _timeCtrl;
  String? _goal;
  bool _loading = false;
  String? _errorMessage;

  bool get isEdit => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _numCtrl = TextEditingController(text: e?.numberOfPeople.toString() ?? '');
    _restoCtrl = TextEditingController(text: e?.restoName ?? '');
    _addressCtrl = TextEditingController(text: e?.address ?? '');
    _goal = e?.goal;
    if (e != null) {
      final dt = e.dateTime.toDate();
      _dateCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(dt));
      _timeCtrl = TextEditingController(text: DateFormat('HH:mm').format(dt));
    } else {
      _dateCtrl = TextEditingController();
      _timeCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl,
      _descCtrl,
      _numCtrl,
      _restoCtrl,
      _addressCtrl,
      _dateCtrl,
      _timeCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _launchGoogleMap() async {
    final name = _restoCtrl.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = '請輸入餐廳名稱以開啟 Google Map 查詢餐廳地址';
      });
      return;
    }

    final url = generateGoogleMapLink(name);
    await launchUrl(Uri.parse(url),); // 用 ios18.4 會跑不出來==
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final e = widget.event;
    final d = await showDatePicker(
      context: context,
      initialDate: e?.dateTime.toDate() ?? now,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (d != null) _dateCtrl.text = DateFormat('yyyy-MM-dd').format(d);
  }

  Future<void> _pickTime() async {
    final e = widget.event;
    final t0 = e == null
        ? TimeOfDay.now()
        : TimeOfDay.fromDateTime(e.dateTime.toDate());
    final t = await showTimePicker(context: context, initialTime: t0);
    if (t != null && mounted) _timeCtrl.text = t.format(context);
  }

  Future<void> _submit() async {  // 按下打勾勾的 icon 會呼叫這個 function
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    // 合併日期+時間
    final date = DateFormat('yyyy-MM-dd').parse(_dateCtrl.text);
    final time = DateFormat('HH:mm').parse(_timeCtrl.text);
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    // 檢查是否在編輯時人數限制 < 當前參加人數
    final newLimit = int.parse(_numCtrl.text.trim());
    final currentParticipants = widget.event?.participants ?? [];

    if (isEdit && newLimit < currentParticipants.length) {
      setState(() {
        _loading = false;
        _errorMessage = '目前已有 ${currentParticipants.length} 人參加，無法將上限改為 $newLimit 人';
      });
      return;
    }

    // 建好 Event instance, 把這個傳到後端
    final e = Event(
      id: widget.event?.id ?? '',
      title: _titleCtrl.text.trim(),
      goal: _goal!,
      description: _descCtrl.text.trim(),
      dateTime: Timestamp.fromDate(dt),
      numberOfPeople: int.parse(_numCtrl.text.trim()),
      restoName: _restoCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      participants: widget.event?.participants ?? [],
      participantNames: widget.event?.participantNames ?? [],
    );

    final res = isEdit
        ? await FirebaseService.editEvent(e)
        : await FirebaseService.addNewEvent(e);

    if (mounted) {
      setState(() => _loading = false);
      if (res.success) {
        Navigator.of(context).pop(true); // 回傳 true 表示成功
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message), duration: Duration(seconds: 3)),
        );
      } else {
        setState(() => _errorMessage = res.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        automaticallyImplyLeading: false, // 不要自動加回上一頁的小箭頭
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(isEdit ? '編輯活動' : '新增活動'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: theme.colorScheme.onPrimary),
            onPressed: _submit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      // 活動標題
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: InputDecoration(labelText: '活動標題'),
                        maxLength: 15,  // 最多只能輸入 15 字, 不然太長會和 icon 打架
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                        ],
                        validator: (v) {
                            if (v == null || v.isEmpty) return '請輸入活動標題';
                            if (v.length > 15) return '最多 15 字';
                            return null;
                        }
                      ),
                      const SizedBox(height: 12),
                      // 目的下拉
                      DropdownButtonFormField<String>(
                        value: _goal,
                        decoration: InputDecoration(labelText: '活動目的'),
                        items: const [
                          DropdownMenuItem(value: '興趣同好聚', child: Text('興趣同好聚')),
                          DropdownMenuItem(value: '揪團湊優惠', child: Text('揪團湊優惠')),
                          DropdownMenuItem(value: '語言交互飯局', child: Text('語言交互飯局')),
                          DropdownMenuItem(value: '毛孩友善聚餐', child: Text('毛孩友善聚餐')),
                          DropdownMenuItem(value: '其他', child: Text('其他')),
                        ],
                        onChanged: (v) => setState(() => _goal = v),
                        validator: (v) => v == null ? '請選活動目的' : null,
                      ),
                      const SizedBox(height: 12),
                      // 餐廳名稱
                      TextFormField(
                        controller: _restoCtrl,
                        decoration: InputDecoration(labelText: '餐廳名稱'),
                        validator: (v) =>
                            v!.isEmpty ? '請輸入餐廳名稱' : null,
                      ),
                      const SizedBox(height: 3),

                      TransparentTextButton(
                        onPressed: _launchGoogleMap,
                        label: Text('開啟 Google Map 查地址'),
                        icon: Icon(Icons.near_me, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 3),

                      // 地址
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: InputDecoration(labelText: '餐廳地址'),
                        validator: (v) => v!.isEmpty ? '請輸入地址' : null,
                      ),
                      const SizedBox(height: 12),
                      // 人數限制
                      TextFormField(
                        controller: _numCtrl,
                        decoration: InputDecoration(labelText: '人數限制'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty
                            ? '請輸入人數'
                            : int.tryParse(v) == null
                                ? '必須是數字'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                           // 日期
                          Expanded(
                            child: TextFormField(
                              controller: _dateCtrl,
                              decoration: InputDecoration(
                                  labelText: '活動日期',
                                  suffixIcon: Icon(Icons.calendar_month)),
                              readOnly: true,
                              onTap: _pickDate,
                              validator: (v) => v!.isEmpty ? '請選日期' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 時間
                          Expanded(
                            child: TextFormField(
                              controller: _timeCtrl,
                              decoration: InputDecoration(
                                  labelText: '活動時間',
                                  suffixIcon: Icon(Icons.access_time)),
                              readOnly: true,
                              onTap: _pickTime,
                              validator: (v) => v!.isEmpty ? '請選時間' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 細節
                      TextFormField(
                        controller: _descCtrl,
                        decoration: InputDecoration(labelText: '活動細節'),
                        maxLines: 3,
                        validator: (v) =>
                            v!.isEmpty ? '請輸入活動細節' : null,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(_errorMessage!,
                            style: TextStyle(color: theme.colorScheme.error)),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
