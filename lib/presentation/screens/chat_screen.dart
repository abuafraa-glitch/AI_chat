import 'package:ai_chat/core/extensions/build_context_extension.dart';
import 'package:ai_chat/core/widgets/app_scaffold.dart';
import 'package:ai_chat/core/widgets/empty_state.dart';
import 'package:ai_chat/core/widgets/error_view.dart';
import 'package:ai_chat/core/widgets/loaders/loading_indicator.dart';
import 'package:ai_chat/data/models/message_model.dart';
import 'package:ai_chat/presentation/animations/fade_in_slide.dart';
import 'package:ai_chat/presentation/blocs/chat_cubit.dart';
import 'package:ai_chat/presentation/blocs/conversations_cubit.dart';
import 'package:ai_chat/core/di/injection.dart';
import 'package:ai_chat/core/services/permission_service.dart';
import 'package:ai_chat/presentation/blocs/data_sources.dart';
import 'package:ai_chat/presentation/blocs/models_cubit.dart';
import 'package:ai_chat/presentation/widgets/chat_input_field.dart';
import 'package:ai_chat/presentation/widgets/localized_text.dart';
import 'package:ai_chat/presentation/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';
import 'package:go_router/go_router.dart';

/// Launch payload carried through the conversation route.
///
/// When [message] is non-empty the chat sends it on arrival; otherwise
/// the screen simply loads the (empty) thread. [modelId] defaults to
/// the user's current selection when omitted.
class ChatLaunchData {
  /// Creates [ChatLaunchData] for a new conversation.
  const ChatLaunchData({this.message = '', this.modelId});

  /// Initial user message to send on arrival.
  final String message;

  /// Model that should answer the initial message, or `null` to use
  /// the current selection.
  final String? modelId;
}

/// Renders a single conversation.
///
/// This screen is a self-contained route: it provides its own [ChatCubit]
/// (per-conversation state) but shares the application-wide [ModelsCubit]
/// singleton from the DI container via [BlocProvider.value], so the
/// model selection stays consistent with the main shell. It observes
/// [ChatState] and renders the four UI phases — loading, error, empty
/// and streaming — without containing any business logic.
class ChatScreen extends StatelessWidget {
  /// Identifier of the conversation to display.
  final String conversationId;

  /// Creates a [ChatScreen] for [conversationId].
  const ChatScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<ChatCubit>(
          create: (context) => ChatCubit(repository: buildMessageRepository()),
        ),
        BlocProvider<ModelsCubit>.value(value: sl<ModelsCubit>()),
      ],
      child: _ChatView(conversationId: conversationId),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({required this.conversationId});

  final String conversationId;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  late final ScrollController _scrollController;
  ChatLaunchData? _launchData;
  bool _didLaunch = false;
  int _previousLength = 0;
  final List<MessageAttachment> _pendingAttachments = <MessageAttachment>[];
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLaunch) {
      return;
    }
    _didLaunch = true;
    final extra = GoRouterState.of(context).extra;
    if (extra is ChatLaunchData) {
      _launchData = extra;
      final modelId = _modelId(context);
      if (extra.message.isNotEmpty && modelId != null) {
        _send(extra.message, modelId);
        return;
      }
    }
    context.read<ChatCubit>().loadMessages(widget.conversationId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  String? _modelId(BuildContext context) {
    final launchModel = _launchData?.modelId;
    if (launchModel != null && launchModel.isNotEmpty) {
      return launchModel;
    }
    return context.read<ModelsCubit>().ensureDefaultSelection();
  }

  void _send(String content, String modelId) {
    context
        .read<ChatCubit>()
        .sendMessage(
          conversationId: widget.conversationId,
          content: content,
          modelId: modelId,
          attachments: List<MessageAttachment>.from(_pendingAttachments),
        )
        .whenComplete(() {
          if (mounted) {
            context.read<ConversationsCubit>().loadConversations();
          }
        });
    _pendingAttachments.clear();
  }

  void _onSendPressed(String content) {
    final state = context.read<ChatCubit>().state;
    if (state.isLoading) {
      context.showSnackBar(
        localizedTextRead(
          context,
          'Waiting for the response…',
          'بانتظار الرد…',
        ),
      );
      return;
    }
    final modelId = _modelId(context);
    if (modelId == null) {
      context.showSnackBar(
        localizedTextRead(
          context,
          'Please select a model first',
          'الرجاء اختيار نموذج أولاً',
        ),
      );
      return;
    }
    _send(content, modelId);
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final recordedPath = await _audioRecorder.stop();
      if (!mounted) return;
      setState(() => _isRecording = false);
      if (recordedPath == null || recordedPath.isEmpty) return;
      try {
        final uploaded = await buildFileRepository().uploadFile(filePath: recordedPath, fileFieldName: 'file');
        setState(() {
          _pendingAttachments.add(MessageAttachment(
            id: uploaded.id,
            name: uploaded.name,
            type: AttachmentType.audio,
            url: uploaded.url ?? '',
            size: uploaded.size,
            mimeType: uploaded.mimeType,
          ));
        });
        context.showSnackBar(localizedTextRead(context, 'Audio ready to send', 'تم تجهيز التسجيل للإرسال'));
      } on Exception {
        if (mounted) context.showErrorSnackBar(localizedTextRead(context, 'Audio upload failed', 'فشل رفع التسجيل الصوتي'));
      }
      return;
    }

    final permission = await sl<PermissionService>().requestMicrophone();
    if (!mounted) return;
    if (permission != PermissionOutcome.granted && permission != PermissionOutcome.limited) {
      context.showErrorSnackBar(localizedTextRead(context, 'Microphone permission is required', 'يلزم السماح باستخدام الميكروفون'));
      return;
    }
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/hajeen_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _audioRecorder.start(const RecordConfig(), path: path);
    if (mounted) setState(() => _isRecording = true);
  }

  Future<void> _openAttachmentMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: Text(
                  localizedTextRead(sheetContext, 'Attach file', 'إرفاق ملف'),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickAttachment();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: Text(
                  localizedTextRead(
                    sheetContext,
                    'Choose image or video',
                    'اختيار صورة أو فيديو',
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickAttachment();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: false,
      type: FileType.any,
    );
    final selected = result?.files.single;
    if (selected == null || selected.path == null || !mounted) {
      return;
    }
    try {
      final uploaded = await buildFileRepository().uploadFile(
        filePath: selected.path!,
        fileFieldName: 'file',
      );
      final mime = uploaded.mimeType ?? 'application/octet-stream';
      final type = mime.startsWith('image/')
          ? AttachmentType.image
          : mime.startsWith('video/')
          ? AttachmentType.video
          : mime.startsWith('audio/')
          ? AttachmentType.audio
          : AttachmentType.file;
      setState(() {
        _pendingAttachments.add(
          MessageAttachment(
            id: uploaded.id,
            name: uploaded.name,
            type: type,
            url: uploaded.url ?? '',
            size: uploaded.size,
            mimeType: uploaded.mimeType,
          ),
        );
      });
      context.showSnackBar(
        localizedTextRead(
          context,
          'Attachment ready',
          'تم تجهيز المرفق للإرسال',
        ),
      );
    } on Exception catch (error) {
      if (mounted) {
        context.showErrorSnackBar(
          '${localizedTextRead(context, 'Upload failed', 'فشل رفع المرفق')}: $error',
        );
      }
    }
  }

  void _onConversationMenuSelected(String action) {
    switch (action) {
      case 'save':
        _saveConversation();
      case 'rename':
        _renameConversation();
      case 'delete':
        _deleteConversation();
    }
  }

  Future<void> _saveConversation() async {
    try {
      await context.read<ConversationsCubit>().saveConversation(widget.conversationId);
      if (mounted) context.showSnackBar(localizedTextRead(context, 'Conversation saved', 'تم حفظ المحادثة'));
    } on Exception {
      if (mounted) context.showErrorSnackBar(localizedTextRead(context, 'Could not save conversation', 'تعذر حفظ المحادثة'));
    }
  }

  Future<void> _renameConversation() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizedTextRead(dialogContext, 'Rename conversation', 'إعادة تسمية المحادثة')),
        content: TextField(controller: controller, autofocus: true, textDirection: TextDirection.rtl),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(localizedTextRead(dialogContext, 'Cancel', 'إلغاء'))),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text), child: Text(localizedTextRead(dialogContext, 'Save', 'حفظ'))),
        ],
      ),
    );
    controller.dispose();
    if (title == null || title.trim().isEmpty || !mounted) return;
    try {
      await context.read<ConversationsCubit>().renameConversation(id: widget.conversationId, title: title);
      if (mounted) context.showSnackBar(localizedTextRead(context, 'Conversation renamed', 'تمت إعادة تسمية المحادثة'));
    } on Exception {
      if (mounted) context.showErrorSnackBar(localizedTextRead(context, 'Could not rename conversation', 'تعذرت إعادة تسمية المحادثة'));
    }
  }

  Future<void> _deleteConversation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizedTextRead(dialogContext, 'Delete conversation?', 'حذف المحادثة؟')),
        content: Text(localizedTextRead(dialogContext, 'This action cannot be undone.', 'لا يمكن التراجع عن هذا الإجراء.')),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(localizedTextRead(dialogContext, 'Cancel', 'إلغاء'))),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(localizedTextRead(dialogContext, 'Delete', 'حذف'))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<ConversationsCubit>().deleteConversation(widget.conversationId);
      if (mounted) Navigator.maybePop(context);
    } on Exception {
      if (mounted) context.showErrorSnackBar(localizedTextRead(context, 'Could not delete conversation', 'تعذر حذف المحادثة'));
    }
  }

  Future<void> _copyMessage(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (!mounted) {
      return;
    }
    context.showSnackBar(
      localizedTextRead(context, 'Copied to clipboard', 'تم النسخ إلى الحافظة'),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        final error = state.error;
        if (error != null && error.isNotEmpty) {
          context.showErrorSnackBar(
            localizedTextRead(context, 'Something went wrong', 'حدث خطأ ما'),
          );
        }
        if (state.messages.length != _previousLength) {
          _previousLength = state.messages.length;
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        return Theme(
          data: Theme.of(context).copyWith(scaffoldBackgroundColor: const Color(0xFF06142F)),
          child: AppScaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF06142F),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.maybePop(context),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(colors: <Color>[Color(0xFF0C79D0), Color(0xFF713FF0)]),
                    ),
                    child: Text(localizedText(context, 'Hajeen Quick', 'هجين السريع'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Flexible(child: Text(localizedText(context, 'Hajeen AI Chat', 'شرح الذكاء الاصطناعي'), overflow: TextOverflow.ellipsis)),
                ],
              ),
              actions: <Widget>[
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: _onConversationMenuSelected,
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(value: 'save', child: Text(localizedText(context, 'Save conversation', 'حفظ المحادثة'))),
                    PopupMenuItem<String>(value: 'rename', child: Text(localizedText(context, 'Rename conversation', 'إعادة تسمية المحادثة'))),
                    PopupMenuItem<String>(value: 'delete', child: Text(localizedText(context, 'Delete conversation', 'حذف المحادثة'))),
                  ],
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                Expanded(child: _buildBody(context, state)),
                ChatInputField(
                  onRecordAudio: _toggleRecording,
                  isRecording: _isRecording,
                  hintText: localizedText(
                    context,
                    'Ask anything…',
                    'اسأل أي شيء…',
                  ),
                  onSendMessage: _onSendPressed,
                  onOpenAttachments: _openAttachmentMenu,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ChatState state) {
    if (state.isLoading && state.messages.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    if (state.error != null && state.messages.isEmpty) {
      return ErrorView(
        description: state.error,
        onRetry: () =>
            context.read<ChatCubit>().loadMessages(widget.conversationId),
      );
    }

    if (state.messages.isEmpty) {
      return const EmptyState(variant: EmptyStateVariant.noData);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        return FadeInSlide(
          child: MessageBubble(
            message: message,
            onCopy: () => _copyMessage(message.content),
            onRegenerate: message.role == MessageRole.assistant
                ? () {
                    final modelId = _modelId(context);
                    if (modelId != null) {
                      context.read<ChatCubit>().regenerate(
                        conversationId: widget.conversationId,
                        modelId: modelId,
                      );
                    }
                  }
                : null,
          ),
        );
      },
    );
  }
}
