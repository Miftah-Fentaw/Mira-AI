import 'package:flutter/material.dart';
import 'package:chatbot/models/message.dart';
import 'package:chatbot/theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppGradients.accentGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: AppColors.deepBlack, size: 18),
            ),
            SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: isUser ? AppColors.darkGreen : AppColors.darkGray,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(isUser ? AppRadius.lg : AppRadius.sm),
                  bottomRight: Radius.circular(isUser ? AppRadius.sm : AppRadius.lg),
                ),
                border: Border.all(
                  color: isUser 
                    ? AppColors.matrixGreen.withValues(alpha: 0.3) 
                    : AppColors.darkGreen.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: context.textStyles.bodyMedium,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatTime(message.timestamp),
                    style: context.textStyles.bodySmall?.copyWith(
                      color: AppColors.pureWhite.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: AppSpacing.sm),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.neonGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: AppColors.deepBlack, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
