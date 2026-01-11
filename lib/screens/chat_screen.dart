import 'package:chatbot/screens/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatbot/providers/chat_provider.dart';
import 'package:chatbot/theme.dart';
import 'package:chatbot/widgets/chat_input.dart';
import 'package:chatbot/widgets/loading_indicator.dart';
import 'package:chatbot/widgets/message_bubble.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.neonGreen, size: 26),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: AppColors.neonGreen.withOpacity(0.1),
    );
  }

  void _showAboutDialog() {
    Navigator.pop(context);
    showAboutDialog(
      context: context,
      applicationName: 'Mira AI',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            gradient: AppGradients.accentGradient, shape: BoxShape.circle),
        child: Icon(Icons.smart_toy_rounded, color: Colors.black, size: 40),
      ),
      children: [
        Text('Your personal AI companion — built with Flutter & Grok',
            textAlign: TextAlign.center)
      ],
    );
  }

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).init();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _handleSend(String message) {
    ref.read(chatProvider.notifier).sendMessage(message);
    _scrollToBottom();
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: Text('Clear Chat', style: context.textStyles.titleLarge),
        content: Text(
          'Are you sure you want to clear all messages?',
          style: context.textStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.pureWhite)),
          ),
          TextButton(
            onPressed: () {
              ref.read(chatProvider.notifier).clearChat();
              Navigator.pop(context);
            },
            child: const Text('Clear',
                style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        backgroundColor: AppColors.richBlack,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppGradients.accentGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.smart_toy_rounded,
                          color: Colors.black, size: 32),
                    ),
                    SizedBox(width: 16),
                    Text('Mira AI',
                        style: context.textStyles.headlineMedium
                            ?.copyWith(color: Colors.white)),
                  ],
                ),
              ),

              Divider(color: AppColors.darkGreen.withOpacity(0.3), height: 1),

              // NEW CHAT BUTTON
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(chatProvider.notifier).newChat();
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.add, color: AppColors.deepBlack),
                  label: Text('New Chat',
                      style: TextStyle(
                          color: AppColors.deepBlack,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              // RECENT CHATS TITLE
              if (chatState.sessions.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Recent Chats',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2)),
                  ),
                ),

              // CHAT SESSIONS LIST
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  children: [
                    ...chatState.sessions.map((session) {
                      final isSelected =
                          chatState.currentSessionId == session.id;
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: 2),
                        child: ListTile(
                          onTap: () {
                            ref
                                .read(chatProvider.notifier)
                                .switchSession(session.id);
                            Navigator.pop(context);
                          },
                          leading: Icon(Icons.chat_bubble_outline_rounded,
                              color: isSelected
                                  ? AppColors.neonGreen
                                  : Colors.white70,
                              size: 20),
                          title: Text(
                            session.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? IconButton(
                                  icon: Icon(Icons.delete_sweep_outlined,
                                      color: Colors.white38, size: 18),
                                  onPressed: () {
                                    ref
                                        .read(chatProvider.notifier)
                                        .deleteSession(session.id);
                                  },
                                )
                              : null,
                          selected: isSelected,
                          selectedTileColor:
                              AppColors.neonGreen.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        ),
                      );
                    }),
                    Divider(
                        color: AppColors.darkGreen.withOpacity(0.1),
                        height: 32),
                    _buildDrawerItem(
                      icon: Icons.feedback_rounded,
                      title: 'Send Feedback',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FeedbackScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.info_outline_rounded,
                      title: 'About App',
                      onTap: () => _showAboutDialog(),
                    ),
                    _buildDrawerItem(
                      icon: Icons.star_rounded,
                      title: 'Rate on Play Store',
                      onTap: () {
                        Navigator.pop(context);
                        launchUrl(Uri.parse(
                            'https://play.google.com/store/apps/details?id=package-name'));
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.privacy_tip_rounded,
                      title: 'Privacy Policy',
                      onTap: () {
                        Navigator.pop(context);
                        launchUrl(Uri.parse('https://privacy-link.com'));
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text('Version 1.0.0',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bkg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // FIXED: Top App Bar
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.richBlack.withValues(alpha: 0.7),
                  border: const Border(
                    bottom: BorderSide(color: AppColors.darkGreen, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    // FIXED: Drawer opens correctly
                    Builder(builder: (context) {
                      return GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppGradients.accentGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.smart_toy,
                              color: AppColors.deepBlack, size: 24),
                        ),
                      );
                    }),

                    const SizedBox(width: AppSpacing.md),

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mira AI',
                              style: context.textStyles.titleLarge?.semiBold),
                          Text(
                            'Always here to help',
                            style: context.textStyles.bodySmall
                                ?.copyWith(color: AppColors.neonGreen),
                          ),
                        ],
                      ),
                    ),

                    // Clear button
                    if (chatState.messages.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _showClearDialog,
                      ),
                  ],
                ),
              ),

              // Messages List
              Expanded(
                child: chatState.messages.isEmpty && !chatState.isLoading
                    ? Center(
                        child: Padding(
                          padding: AppSpacing.paddingXl,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: AppGradients.accentGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.chat_bubble_outline,
                                    color: AppColors.deepBlack, size: 40),
                              ),
                              SizedBox(height: AppSpacing.lg),
                              Text('Start a Conversation',
                                  style: context.textStyles.headlineMedium,
                                  textAlign: TextAlign.center),
                              SizedBox(height: AppSpacing.md),
                              Text(
                                'Type a message to begin chatting with your AI assistant',
                                style: context.textStyles.bodyMedium?.copyWith(
                                    color: AppColors.pureWhite
                                        .withValues(alpha: 0.7)),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: AppSpacing.verticalMd,
                        itemCount: chatState.messages.length +
                            (chatState.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < chatState.messages.length) {
                            return MessageBubble(
                                message: chatState.messages[index]);
                          }
                          return const LoadingIndicator();
                        },
                      ),
              ),

              // Input
              ChatInput(onSend: _handleSend, isEnabled: !chatState.isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
