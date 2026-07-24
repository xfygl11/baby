import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/drift/app_database.dart';
import '../../providers/app_providers.dart';
import '../ai_assistant/ai_assistant_page.dart';

class EditRecordPage extends ConsumerStatefulWidget {
  final String? recordId;
  final RecordCategory? category;

  const EditRecordPage({
    super.key,
    this.recordId,
    this.category,
  });

  @override
  ConsumerState<EditRecordPage> createState() => _EditRecordPageState();
}

class _EditRecordPageState extends ConsumerState<EditRecordPage> {
  final Map<String, dynamic> _formData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recordId != null) {
      _loadRecord();
    } else {
      _initFormData();
    }
  }

  void _initFormData() {
    _formData['title'] = '';
    _formData['content'] = '';
    _formData['recordDate'] = DateTime.now();
    _formData['category'] = widget.category?.name ?? RecordCategory.diary.name;
  }

  Future<void> _loadRecord() async {
    setState(() => _isLoading = true);
    try {
      final recordRepo = ref.read(recordRepositoryProvider);
      final record = await recordRepo.getRecordById(widget.recordId!);
      if (record != null) {
        _formData['title'] = record.title;
        _formData['content'] = record.content;
        _formData['recordDate'] = record.recordDate;
        _formData['category'] = record.category;
      }
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveRecord() async {
    if (_formData['title'] == null || (_formData['title'] as String).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入标题')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final recordRepo = ref.read(recordRepositoryProvider);
      final category = RecordCategory.values.firstWhere(
        (c) => c.name == _formData['category'],
        orElse: () => RecordCategory.diary,
      );

      if (widget.recordId != null) {
        await recordRepo.updateRecord(
          id: widget.recordId!,
          title: _formData['title'],
          content: _formData['content'],
          recordDate: _formData['recordDate'],
          category: category,
        );
      } else {
        await recordRepo.addRecord(
          title: _formData['title'],
          content: _formData['content'],
          recordDate: _formData['recordDate'],
          category: category,
          babyId: '',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.recordId != null ? '修改成功' : '保存成功'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCategorySelector() {
    final theme = AppTheme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.stageSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(theme.spacingLg),
            child: Text(
              '选择记录类型',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: RecordCategory.values.map((cat) {
                final selected = _formData['category'] == cat.name;
                return ListTile(
                  leading: Text(_getCategoryIcon(cat)),
                  title: Text(_getCategoryLabel(cat)),
                  trailing: selected
                      ? Icon(Icons.check, color: theme.stageAccent)
                      : null,
                  onTap: () {
                    setState(() => _formData['category'] = cat.name);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryIcon(RecordCategory cat) {
    return switch (cat) {
      RecordCategory.feeding => '🍼',
      RecordCategory.sleep => '😴',
      RecordCategory.diaper => '👶',
      RecordCategory.temperature => '🌡️',
      RecordCategory.medication => '💊',
      RecordCategory.stool => '💩',
      RecordCategory.skin => '👕',
      RecordCategory.allergy => '🤧',
      RecordCategory.doctorVisit => '👩‍⚕️',
      RecordCategory.teeth => '🦷',
      RecordCategory.vision => '👁️',
      RecordCategory.milestone => '🏆',
      RecordCategory.vaccine => '💉',
      RecordCategory.growth => '📏',
      RecordCategory.diary => '📝',
      RecordCategory.quote => '💬',
      RecordCategory.activity => '🤹',
      RecordCategory.school => '🏫',
      RecordCategory.exam => '📚',
      RecordCategory.homework => '📖',
      RecordCategory.award => '🏅',
      RecordCategory.interest => '🎨',
      RecordCategory.parentMeeting => '👨‍👩‍👧',
      RecordCategory.personality => '🎭',
      RecordCategory.emotion => '😊',
      RecordCategory.festival => '🎉',
      RecordCategory.expense => '💰',
      RecordCategory.photo => '📷',
      RecordCategory.video => '🎬',
      RecordCategory.audio => '🎙️',
      RecordCategory.capsule => '📮',
      RecordCategory.word => '📝',
    };
  }

  String _getCategoryLabel(RecordCategory cat) {
    return switch (cat) {
      RecordCategory.feeding => '喂养',
      RecordCategory.sleep => '睡眠',
      RecordCategory.diaper => '尿布',
      RecordCategory.temperature => '体温',
      RecordCategory.medication => '用药',
      RecordCategory.stool => '便便',
      RecordCategory.skin => '皮肤',
      RecordCategory.allergy => '过敏',
      RecordCategory.doctorVisit => '就医',
      RecordCategory.teeth => '牙齿',
      RecordCategory.vision => '视力',
      RecordCategory.milestone => '里程碑',
      RecordCategory.vaccine => '疫苗',
      RecordCategory.growth => '生长',
      RecordCategory.diary => '日记',
      RecordCategory.quote => '语录',
      RecordCategory.activity => '互动',
      RecordCategory.school => '学校',
      RecordCategory.exam => '考试',
      RecordCategory.homework => '作业',
      RecordCategory.award => '获奖',
      RecordCategory.interest => '兴趣',
      RecordCategory.parentMeeting => '家长会',
      RecordCategory.personality => '性格',
      RecordCategory.emotion => '情绪',
      RecordCategory.festival => '节日',
      RecordCategory.expense => '费用',
      RecordCategory.photo => '照片',
      RecordCategory.video => '视频',
      RecordCategory.audio => '音频',
      RecordCategory.capsule => '时间胶囊',
      RecordCategory.word => '词汇',
    };
  }

  void _showDatePicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _formData['recordDate'] ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() => _formData['recordDate'] = selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.stageBg,
      appBar: AppBar(
        title: Text(widget.recordId != null ? '编辑记录' : '新建记录'),
        actions: [
          if (widget.recordId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: theme.paper,
                    title: const Text('删除记录'),
                    content: const Text('确定要删除这条记录吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final recordRepo = ref.read(recordRepositoryProvider);
                          await recordRepo.deleteRecord(widget.recordId!);
                          if (mounted) {
                            Navigator.pop(context, true);
                          }
                        },
                        style: TextButton.styleFrom(foregroundColor: theme.danger),
                        child: const Text('删除'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: theme.stageAccent),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(theme.spacingLg),
              child: Column(
                children: [
                  InkWell(
                    onTap: _showCategorySelector,
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(theme.spacingMd),
                      decoration: BoxDecoration(
                        color: theme.stageSurface,
                        borderRadius: BorderRadius.circular(theme.radiusMd),
                        border: Border.all(color: theme.textTertiary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _getCategoryIcon(
                              RecordCategory.values.firstWhere(
                                (c) => c.name == _formData['category'],
                                orElse: () => RecordCategory.diary,
                              ),
                            ),
                            style: const TextStyle(fontSize: 24),
                          ),
                          SizedBox(width: theme.spacingMd),
                          Expanded(
                            child: Text(
                              _getCategoryLabel(
                                RecordCategory.values.firstWhere(
                                  (c) => c.name == _formData['category'],
                                  orElse: () => RecordCategory.diary,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.textPrimary,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: theme.textTertiary),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: theme.spacingLg),
                  TextField(
                    decoration: InputDecoration(
                      labelText: '标题',
                      hintText: '输入记录标题',
                      filled: true,
                      fillColor: theme.stageSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(theme.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => _formData['title'] = value,
                    controller: TextEditingController(
                      text: _formData['title'] as String?,
                    ),
                  ),
                  SizedBox(height: theme.spacingMd),
                  InkWell(
                    onTap: _showDatePicker,
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(theme.spacingMd),
                      decoration: BoxDecoration(
                        color: theme.stageSurface,
                        borderRadius: BorderRadius.circular(theme.radiusMd),
                        border: Border.all(color: theme.textTertiary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: theme.textTertiary),
                          SizedBox(width: theme.spacingMd),
                          Text(
                            DateTimeUtils.formatDateCn(_formData['recordDate'] ?? DateTime.now()),
                            style: TextStyle(fontSize: 16, color: theme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: theme.spacingMd),
                  TextField(
                    decoration: InputDecoration(
                      labelText: '内容',
                      hintText: '输入详细内容...',
                      filled: true,
                      fillColor: theme.stageSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(theme.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 8,
                    minLines: 4,
                    onChanged: (value) => _formData['content'] = value,
                    controller: TextEditingController(
                      text: _formData['content'] as String?,
                    ),
                  ),
                  SizedBox(height: theme.spacingXl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saveRecord,
                      child: const Text('保存'),
                    ),
                  ),
                  SizedBox(height: theme.spacingMd),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AiAssistantPage()),
                        );
                      },
                      child: const Text('使用AI助手'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}