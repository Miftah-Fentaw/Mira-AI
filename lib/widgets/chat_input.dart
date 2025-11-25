import 'package:flutter/material.dart';
import 'package:chatbot/theme.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isEnabled;

  const ChatInput({
    super.key,
    required this.onSend,
    this.isEnabled = true,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_hasText && widget.isEnabled) {
      widget.onSend(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.richBlack,
        border: Border(
          top: BorderSide(
            color: AppColors.darkGreen.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.all(AppSpacing.md),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.isEnabled,
                style: context.textStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(
                      color: AppColors.darkGreen.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(
                      color: AppColors.neonGreen,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.darkGray,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                gradient: _hasText && widget.isEnabled 
                  ? AppGradients.accentGradient 
                  : null,
                color: !_hasText || !widget.isEnabled 
                  ? AppColors.darkGray 
                  : null,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.send_rounded),
                color: _hasText && widget.isEnabled 
                  ? AppColors.deepBlack 
                  : AppColors.pureWhite.withValues(alpha: 0.3),
                onPressed: _hasText && widget.isEnabled ? _handleSend : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
