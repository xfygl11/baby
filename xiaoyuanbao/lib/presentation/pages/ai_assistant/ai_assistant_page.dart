import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_enums.dart';
import '../../../data/drift/app_database.dart';
import '../../../services/ai/ai_service.dart';
import '../../../services/speech/speech_service.dart';
import '../../providers/app_providers.dart';

class ChatMessageItem {
  final String id;
  final int role;
  final String content;
  final AiIntent? intent;
  final String? relatedRecordId;
  final DateTime timestamp;
  final bool isError;
  final Map<String, dynamic>? data;

  ChatMessageItem({
    required this.id,
    required this.role,
    required this.content,
    this.intent,
    this.relatedRecordId,
    required this.timestamp,
    this.isError = false,
    this.data,
  });
}

class AiAssistantPage extends ConsumerStatefulWidget {
  const AiAssistantPage({super.key});

  @override
  ConsumerState<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends ConsumerState<AiAssistantPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessageItem> _messages = [];
  bool _isFirstTime = true;
  bool _isListening = false;
  bool _speechInitialized = false;

  final List<String> _quickActions = [
    '📊 今日总结',
    '💉 疫苗提醒',
    '📈 生长曲线',
    '💡 育儿建议',
  ];

  final List<String> _examplePrompts = [
    '喂了120ml奶粉',
    '宝宝睡着了',
    '今天打了乙肝疫苗',
    '宝宝会翻身了',
    '今天总结一下',
  ];

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    _loadChatHistory();
    _initSpeech();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    final speechService = ref.read(speechServiceProvider);
    _speechInitialized = await speechService.initialize();
    setState(() {});
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _scrollToBottom(withKeyboardDelay: true);
    }
  }

  Future<void> _loadChatHistory() async {
    final aiService = ref.read(aiServiceProvider);
    final history = await aiService.getChatHistory();

    if (history.isNotEmpty) {
      setState(() {
        _isFirstTime = false;
        _messages.addAll(history.map((m) => ChatMessageItem(
              id: m.id,
              role: m.role,
              content: m.content,
              intent: _parseIntent(m.intent),
              relatedRecordId: m.relatedRecordIds?.split(',').first,
              timestamp: m.createdAt,
              isError: m.messageType == 'error',
            )));
      });
      _scrollToBottom();
    }
  }

  AiIntent? _parseIntent(String? intentStr) {
    if (intentStr == null) return null;
    try {
      return AiIntent.values.firstWhere((e) => e.name == intentStr);
    } catch (_) {
      return null;
    }
  }

  void _scrollToBottom({bool withKeyboardDelay = false}) {
    final delay = withKeyboardDelay ? const Duration(milliseconds: 300) : Duration.zero;
    Future.delayed(delay, () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final trimmed = text.trim();
    _textController.clear();

    setState(() {
      _isFirstTime = false;
      _messages.add(ChatMessageItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 0,
        content: trimmed,
        timestamp: DateTime.now(),
      ));
    });

    _scrollToBottom();

    final aiService = ref.read(aiServiceProvider);
    final response = await aiService.processMessage(trimmed);

    setState(() {
      _messages.add(ChatMessageItem(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        role: 1,
        content: response.text,
        intent: response.intent,
        relatedRecordId: response.createdRecordIds?.first,
        timestamp: DateTime.now(),
        isError: response.isError,
        data: response.data,
      ));
    });

    _scrollToBottom();
  }

  bool _isRecordIntent(AiIntent? intent) {
    if (intent == null) return false;
    const recordIntents = {
      AiIntent.recordFeeding,
      AiIntent.recordBreastfeeding,
      AiIntent.recordSolidFood,
      AiIntent.recordSleepStart,
      AiIntent.recordSleepEnd,
      AiIntent.recordDiaper,
      AiIntent.recordTemperature,
      AiIntent.recordMedication,
      AiIntent.recordMilestone,
      AiIntent.recordVaccine,
      AiIntent.recordGrowth,
      AiIntent.recordDiary,
    };
    return recordIntents.contains(intent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isProcessing = ref.watch(aiServiceProvider).isProcessing;

    return Scaffold(
      backgroundColor: theme.stageBg,
      appBar: AppBar(
        title: const Text('萱萱助手'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear') {
                _showClearDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('清空对话'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildQuickActions(theme),
            Expanded(
              child: _isFirstTime && _messages.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildMessageList(theme, isProcessing),
            ),
            _buildInputArea(theme, isProcessing),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(AppTheme theme) {
    return Container(
      height: 44,
      margin: EdgeInsets.symmetric(vertical: theme.spacingSm),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: theme.spacingLg),
        itemCount: _quickActions.length,
        separatorBuilder: (_, __) => SizedBox(width: theme.spacingSm),
        itemBuilder: (context, index) {
          final action = _quickActions[index];
          return OutlinedButton(
            onPressed: () => _sendMessage(action),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: theme.spacingMd),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(theme.radiusPill),
              ),
            ),
            child: Text(action, style: const TextStyle(fontSize: 13)),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppTheme theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.spacingXl),
      child: Column(
        children: [
          SizedBox(height: theme.spacingXl),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.stageAccent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              color: theme.onAccent,
              size: 40,
            ),
          ),
          SizedBox(height: theme.spacingLg),
          Text(
            '嗨！我是萱萱的 AI 助手',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: theme.spacingSm),
          Text(
            '你可以这样对我说：',
            style: TextStyle(color: theme.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: theme.spacingXl),
          Wrap(
            spacing: theme.spacingSm,
            runSpacing: theme.spacingSm,
            alignment: WrapAlignment.center,
            children: _examplePrompts.map((prompt) {
              return InkWell(
                onTap: () => _sendMessage(prompt),
                borderRadius: BorderRadius.circular(theme.radiusPill),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacingMd,
                    vertical: theme.spacingSm + 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.stageSurface,
                    borderRadius: BorderRadius.circular(theme.radiusPill),
                    border: Border.all(
                      color: theme.stageAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    prompt,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(AppTheme theme, bool isProcessing) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacingLg,
        vertical: theme.spacingMd,
      ),
      itemCount: _messages.length + (isProcessing ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && isProcessing) {
          return _buildTypingIndicator(theme);
        }

        final msg = _messages[index];
        final isUser = msg.role == 0;

        if (!isUser && _isRecordIntent(msg.intent) && !msg.isError) {
          return _buildRecordConfirmation(theme, msg);
        }

        return _buildMessageBubble(theme, msg);
      },
    );
  }

  Widget _buildMessageBubble(AppTheme theme, ChatMessageItem msg) {
    final isUser = msg.role == 0;

    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacingSm),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: EdgeInsets.only(right: theme.spacingSm),
              decoration: BoxDecoration(
                color: theme.stageAccent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                color: theme.onAccent,
                size: 18,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacingMd,
                vertical: theme.spacingSm + 2,
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isUser ? theme.stageAccent : theme.stageSurface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(theme.radiusMd),
                  topRight: Radius.circular(theme.radiusMd),
                  bottomLeft: Radius.circular(isUser ? theme.radiusMd : 4),
                  bottomRight: Radius.circular(isUser ? 4 : theme.radiusMd),
                ),
              ),
              child: Text(
                msg.content,
                style: TextStyle(
                  color: isUser ? theme.onAccent : theme.textPrimary,
                  fontSize: 15,
                  height: 1.4,
                  fontStyle: isUser ? FontStyle.normal : FontStyle.italic,
                  fontFamily: isUser ? null : 'NotoSerifSC',
                ),
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: theme.spacingSm),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordConfirmation(AppTheme theme, ChatMessageItem msg) {
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: EdgeInsets.only(right: theme.spacingSm),
            decoration: BoxDecoration(
              color: theme.stageAccent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              color: theme.onAccent,
              size: 18,
            ),
          ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: theme.stageSurface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(theme.radiusMd),
                  topRight: Radius.circular(theme.radiusMd),
                  bottomLeft: const Radius.circular(4),
                  bottomRight: Radius.circular(theme.radiusMd),
                ),
                border: Border.all(color: theme.milestoneGold, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.spacingMd,
                      vertical: theme.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: theme.milestoneGold.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(theme.radiusMd - 1.5),
                        topRight: Radius.circular(theme.radiusMd - 1.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: theme.milestoneGold, size: 18),
                        SizedBox(width: theme.spacingXs),
                        Text(
                          '已记录',
                          style: TextStyle(
                            color: theme.milestoneGold,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(theme.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.content,
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 15,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'NotoSerifSC',
                          ),
                        ),
                        if (msg.intent != null) ...[
                          SizedBox(height: theme.spacingMd),
                          Row(
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 14,
                                color: theme.textSecondary,
                              ),
                              SizedBox(width: theme.spacingXs),
                              Text(
                                _getIntentLabel(msg.intent!),
                                style: TextStyle(
                                  color: theme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: theme.spacingMd),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(theme.radiusPill),
                                  ),
                                ),
                                child: const Text('记录详情'),
                              ),
                            ),
                            SizedBox(width: theme.spacingSm),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {},
                                style: FilledButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: const Text('好的'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getIntentLabel(AiIntent intent) {
    return switch (intent) {
      AiIntent.recordFeeding ||
      AiIntent.recordBreastfeeding ||
      AiIntent.recordSolidFood =>
        '喂养记录',
      AiIntent.recordSleepStart || AiIntent.recordSleepEnd => '睡眠记录',
      AiIntent.recordDiaper => '尿布记录',
      AiIntent.recordTemperature => '体温记录',
      AiIntent.recordMedication => '用药记录',
      AiIntent.recordMilestone => '里程碑',
      AiIntent.recordVaccine => '疫苗记录',
      AiIntent.recordGrowth => '生长记录',
      AiIntent.recordDiary => '日记',
      _ => '记录',
    };
  }

  Widget _buildTypingIndicator(AppTheme theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacingSm),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: EdgeInsets.only(right: theme.spacingSm),
            decoration: BoxDecoration(
              color: theme.stageAccent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              color: theme.onAccent,
              size: 18,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacingMd,
              vertical: theme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: theme.stageSurface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(theme.radiusMd),
                topRight: Radius.circular(theme.radiusMd),
                bottomLeft: const Radius.circular(4),
                bottomRight: Radius.circular(theme.radiusMd),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BouncingDot(delay: 0),
                SizedBox(width: theme.spacingXs),
                _BouncingDot(delay: 150),
                SizedBox(width: theme.spacingXs),
                _BouncingDot(delay: 300),
                SizedBox(width: theme.spacingSm),
                Text(
                  '正在理解你说的话…',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(AppTheme theme, bool isProcessing) {
    final speechService = ref.watch(speechServiceProvider);

    return Container(
      padding: EdgeInsets.fromLTRB(
        theme.spacingMd,
        theme.spacingSm,
        theme.spacingMd,
        theme.spacingMd + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.stageSurface,
        border: Border(
          top: BorderSide(color: theme.textTertiary.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          if (_isListening)
            Padding(
              padding: EdgeInsets.symmetric(vertical: theme.spacingSm),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacingMd,
                  vertical: theme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: theme.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                  border: Border.all(color: theme.danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.mic, color: theme.danger, size: 18),
                    SizedBox(width: theme.spacingSm),
                    Expanded(
                      child: Text(
                        speechService.recognizedText.isNotEmpty
                            ? speechService.recognizedText
                            : '正在听...',
                        style: TextStyle(color: theme.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: theme.spacingSm),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Semantics(
                label: _isListening ? '停止语音输入' : '语音输入',
                button: true,
                enabled: !isProcessing,
                child: InkWell(
                  onTap: isProcessing ? null : _toggleSpeech,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isListening ? theme.danger : theme.stageAccent,
                      shape: BoxShape.circle,
                      boxShadow: _isListening
                          ? [
                              BoxShadow(
                                color: theme.danger.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: theme.onAccent,
                      size: 24,
                    ),
                  ),
                ),
              ),
              SizedBox(width: theme.spacingSm),
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  enabled: !isProcessing && !_isListening,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _sendMessage(value);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: _isListening ? '正在听你说话...' : '输入消息...',
                    hintStyle: TextStyle(color: theme.textTertiary),
                    filled: true,
                    fillColor: theme.paper,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: theme.spacingMd,
                      vertical: theme.spacingSm + 4,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(theme.radiusPill),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(theme.radiusPill),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(theme.radiusPill),
                      borderSide: BorderSide(color: theme.stageAccent, width: 1.5),
                    ),
                  ),
                ),
              ),
              if (_textController.text.isNotEmpty || isProcessing) ...[
                SizedBox(width: theme.spacingSm),
                InkWell(
                  onTap: isProcessing
                      ? null
                      : () {
                          if (_textController.text.trim().isNotEmpty) {
                            _sendMessage(_textController.text);
                          }
                        },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isProcessing ? theme.stageAccentLight : theme.stageAccent,
                      shape: BoxShape.circle,
                    ),
                    child: isProcessing
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(theme.onAccent),
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: theme.onAccent,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleSpeech() async {
    final speechService = ref.read(speechServiceProvider);

    if (_isListening) {
      await speechService.stopListening(
        onResult: (text) {
          if (text.isNotEmpty) {
            _textController.text = text;
            _sendMessage(text);
          }
        },
      );
      setState(() => _isListening = false);
    } else {
      if (!_speechInitialized) {
        _speechInitialized = await speechService.initialize();
        if (!_speechInitialized) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('语音识别初始化失败')),
          );
          return;
        }
      }

      _textController.clear();
      setState(() => _isListening = true);

      await speechService.startListening(
        onResult: (text) {
          setState(() {});
        },
      );
    }
  }

  void _showClearDialog() {
    final theme = AppTheme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.paper,
        title: const Text('清空对话'),
        content: const Text('确定要清空所有对话记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final aiService = ref.read(aiServiceProvider);
              await aiService.clearChatHistory();
              setState(() {
                _messages.clear();
                _isFirstTime = true;
              });
            },
            style: TextButton.styleFrom(foregroundColor: theme.danger),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final int delay;

  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -4 * _controller.value),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
