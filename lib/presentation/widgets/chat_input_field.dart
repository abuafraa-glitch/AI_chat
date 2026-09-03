import 'package:ai_chat/presentation/widgets/localized_text.dart';
import 'package:flutter/material.dart';

const Color _composerSendBlue = Color(0xFF13A5F6);
const Color _composerSendPurple = Color(0xFF713DF0);

/// Composer input used at the bottom of the chat surfaces.
///
/// A pure presentation widget: it holds the text-editing state, watches
/// the active locale for direction and tooltips, and forwards the
/// trimmed message through [onSendMessage]. Attachment actions are
/// optional and only rendered when a callback is supplied.
class ChatInputField extends StatefulWidget {
  /// Creates a [ChatInputField].
  const ChatInputField({
    super.key,
    required this.hintText,
    required this.onSendMessage,
    this.onAttachFile,
    this.onUploadImage,
    this.onRecordAudio,
    this.isRecording = false,
    this.onOpenAttachments,
  });

  /// Localized hint shown while the field is empty.
  final String hintText;

  /// Invoked with the trimmed message when the user sends.
  final ValueChanged<String> onSendMessage;

  /// Optional file-attachment action; hides the button when `null`.
  final VoidCallback? onAttachFile;

  /// Optional image-attachment action; hides the button when `null`.
  final VoidCallback? onUploadImage;

  /// Optional audio-recording action; hides the button when `null`.
  final VoidCallback? onRecordAudio;

  /// Whether audio recording is currently active.
  final bool isRecording;

  /// Opens the attachment actions menu from the compact plus button.
  final VoidCallback? onOpenAttachments;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final composing = _controller.text.trim().isNotEmpty;
    if (composing != _isComposing) {
      setState(() {
        _isComposing = composing;
      });
    }
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isEmpty) {
      return;
    }
    widget.onSendMessage(message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = isArabicLocale(context);
    const inputSurface = Color(0xFF0A1A38);
    const inputBorder = Color(0xFF29446D);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: inputSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: inputBorder, width: 1.2),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 7)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Row(
              children: isArabic
                  ? <Widget>[
                      _SendButton(enabled: _isComposing, onPressed: _sendMessage),
                      Expanded(child: _InputText(controller: _controller, hintText: widget.hintText, isArabic: isArabic)),
                      if (widget.onRecordAudio != null) _ComposerButton(icon: widget.isRecording ? Icons.stop_rounded : Icons.mic_none_rounded, onPressed: widget.onRecordAudio),
                      if (widget.onOpenAttachments != null) _ComposerButton(icon: Icons.add_rounded, tooltip: localizedText(context, 'Add attachment', 'إضافة مرفق'), onPressed: widget.onOpenAttachments),
                    ]
                  : <Widget>[
                      if (widget.onOpenAttachments != null) _ComposerButton(icon: Icons.add_rounded, tooltip: localizedText(context, 'Add attachment', 'إضافة مرفق'), onPressed: widget.onOpenAttachments),
                      if (widget.onRecordAudio != null) _ComposerButton(icon: widget.isRecording ? Icons.stop_rounded : Icons.mic_none_rounded, onPressed: widget.onRecordAudio),
                      Expanded(child: _InputText(controller: _controller, hintText: widget.hintText, isArabic: isArabic)),
                      _SendButton(enabled: _isComposing, onPressed: _sendMessage),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerButton extends StatelessWidget {
  const _ComposerButton({required this.icon, required this.onPressed, this.tooltip});
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      color: const Color(0xFFB8C7E6),
      style: IconButton.styleFrom(
        side: const BorderSide(color: Color(0xFF29446D)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(10),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onPressed});
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: enabled
              ? const LinearGradient(colors: <Color>[_composerSendBlue, _composerSendPurple])
              : null,
          color: enabled ? null : const Color(0xFF263655),
          boxShadow: enabled
              ? const <BoxShadow>[BoxShadow(color: Color(0x883C8BFF), blurRadius: 18)]
              : null,
        ),
        child: IconButton(
          onPressed: enabled ? onPressed : null,
          icon: const Icon(Icons.send_rounded),
          color: Colors.white,
          iconSize: 28,
          padding: const EdgeInsets.all(14),
          tooltip: localizedText(context, 'Send', 'إرسال'),
        ),
      );
}

class _InputText extends StatelessWidget {
  const _InputText({required this.controller, required this.hintText, required this.isArabic});
  final TextEditingController controller;
  final String hintText;
  final bool isArabic;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: TextField(
          controller: controller,
          maxLines: null,
          minLines: 1,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      );
}
