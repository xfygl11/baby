import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/constants/app_enums.dart';

class BabyProfileEditPage extends StatefulWidget {
  const BabyProfileEditPage({super.key});

  @override
  State<BabyProfileEditPage> createState() => _BabyProfileEditPageState();
}

class _BabyProfileEditPageState extends State<BabyProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController(text: '萱萱');
  BabyGender _gender = BabyGender.female;
  DateTime _birthDate = DateTime(2024, 1, 15);
  TimeOfDay _birthTime = const TimeOfDay(hour: 8, minute: 30);

  final TextEditingController _birthWeightController = TextEditingController(text: '3.5');
  final TextEditingController _birthHeightController = TextEditingController(text: '50');
  String? _bloodType;

  final TextEditingController _fatherHeightController = TextEditingController(text: '175');
  final TextEditingController _motherHeightController = TextEditingController(text: '162');

  final List<String> _bloodTypes = ['A', 'B', 'AB', 'O'];

  @override
  void dispose() {
    _nameController.dispose();
    _birthWeightController.dispose();
    _birthHeightController.dispose();
    _fatherHeightController.dispose();
    _motherHeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑宝宝资料'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(theme.spacingLg),
          children: [
            _buildAvatarSection(theme),
            SizedBox(height: theme.spacingXl),
            _buildBasicInfoSection(theme),
            SizedBox(height: theme.spacingXl),
            _buildBirthInfoSection(theme),
            SizedBox(height: theme.spacingXl),
            _buildOptionalInfoSection(theme),
            SizedBox(height: theme.spacingXxl),
            _buildSaveButton(theme),
            SizedBox(height: theme.spacingXxl),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(AppTheme theme) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.stageAccent.withOpacity(0.1),
                child: Text(
                  _nameController.text.isNotEmpty ? _nameController.text[0] : '宝',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: theme.stageAccent,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.stageAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.paper, width: 3),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.camera_alt, color: theme.onAccent, size: 20),
                    onPressed: () {},
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacingSm),
          Text(
            '点击更换头像',
            style: TextStyle(
              fontSize: 13,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, '基本信息'),
        SizedBox(height: theme.spacingMd),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.all(theme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '宝宝姓名',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.textPrimary,
                  ),
                ),
                SizedBox(height: theme.spacingSm),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: '请输入宝宝姓名',
                    prefixIcon: Icon(Icons.child_care),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入宝宝姓名';
                    }
                    if (value.trim().length > 20) {
                      return '姓名不能超过20个字符';
                    }
                    return null;
                  },
                ),
                SizedBox(height: theme.spacingLg),
                Text(
                  '性别',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.textPrimary,
                  ),
                ),
                SizedBox(height: theme.spacingSm),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenderOption(
                        theme,
                        gender: BabyGender.female,
                        label: '女宝',
                        icon: Icons.female,
                      ),
                    ),
                    SizedBox(width: theme.spacingMd),
                    Expanded(
                      child: _buildGenderOption(
                        theme,
                        gender: BabyGender.male,
                        label: '男宝',
                        icon: Icons.male,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(
    AppTheme theme, {
    required BabyGender gender,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _gender == gender;
    return InkWell(
      onTap: () {
        setState(() {
          _gender = gender;
        });
      },
      borderRadius: BorderRadius.circular(theme.radiusMd),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? theme.stageAccent.withOpacity(0.1) : theme.stageBg,
          borderRadius: BorderRadius.circular(theme.radiusMd),
          border: Border.all(
            color: isSelected ? theme.stageAccent : theme.stageBg,
            width: 2,
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: theme.spacingMd),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? theme.stageAccent : theme.textSecondary,
            ),
            SizedBox(height: theme.spacingXs),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? theme.stageAccent : theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthInfoSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, '出生信息'),
        SizedBox(height: theme.spacingMd),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildDatePickerTile(
                theme,
                icon: Icons.cake_outlined,
                title: '出生日期',
                value: DateTimeUtils.formatDateCn(_birthDate),
                onTap: _selectBirthDate,
              ),
              Padding(
                padding: EdgeInsets.only(left: theme.spacingMd + 40 + theme.spacingMd),
                child: Divider(height: 1, color: theme.stageBg),
              ),
              _buildTimePickerTile(
                theme,
                icon: Icons.access_time,
                title: '出生时间',
                value: _birthTime.format(context),
                onTap: _selectBirthTime,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionalInfoSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, '更多信息（选填）'),
        SizedBox(height: theme.spacingMd),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.all(theme.spacingMd),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _birthWeightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: '出生体重',
                          hintText: 'kg',
                          prefixIcon: Icon(Icons.fitness_center),
                          suffixText: 'kg',
                        ),
                      ),
                    ),
                    SizedBox(width: theme.spacingMd),
                    Expanded(
                      child: TextFormField(
                        controller: _birthHeightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: '出生身高',
                          hintText: 'cm',
                          prefixIcon: Icon(Icons.straighten),
                          suffixText: 'cm',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: theme.spacingLg),
                _buildBloodTypeDropdown(theme),
                SizedBox(height: theme.spacingLg),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _fatherHeightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: '父亲身高',
                          hintText: 'cm',
                          prefixIcon: Icon(Icons.man),
                          suffixText: 'cm',
                        ),
                      ),
                    ),
                    SizedBox(width: theme.spacingMd),
                    Expanded(
                      child: TextFormField(
                        controller: _motherHeightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: '母亲身高',
                          hintText: 'cm',
                          prefixIcon: Icon(Icons.woman),
                          suffixText: 'cm',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTypeDropdown(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '血型',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.textPrimary,
          ),
        ),
        SizedBox(height: theme.spacingSm),
        Wrap(
          spacing: theme.spacingSm,
          children: _bloodTypes.map((type) {
            final isSelected = _bloodType == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _bloodType = selected ? type : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePickerTile(
    AppTheme theme, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacingMd,
          vertical: theme.spacingMd,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.stageAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(theme.radiusMd),
              ),
              child: Icon(
                icon,
                color: theme.stageAccent,
                size: 22,
              ),
            ),
            SizedBox(width: theme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today,
              size: 20,
              color: theme.stageAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerTile(
    AppTheme theme, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacingMd,
          vertical: theme.spacingMd,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.stageAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(theme.radiusMd),
              ),
              child: Icon(
                icon,
                color: theme.stageAccent,
                size: 22,
              ),
            ),
            SizedBox(width: theme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.access_time,
              size: 20,
              color: theme.stageAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(AppTheme theme, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: theme.spacingSm),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: theme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppTheme theme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _saveProfile,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.radiusPill),
          ),
        ),
        child: const Text(
          '保存',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('zh', 'CN'),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _selectBirthTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _birthTime,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('zh', 'CN'),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthTime = picked;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
      Navigator.of(context).pop();
    }
  }
}
