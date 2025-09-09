// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../providers/ai_provider.dart';
import '../../models/ai_message.dart';
import '../../models/ai_response_models.dart';
import '../../widgets/ai_response_cards.dart';
import '../../localization/app_localizations.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _messageController.clear();
    setState(() {
      _isComposing = false;
    });

    // Send message through provider
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    aiProvider.sendMessage(text.trim());

    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessage(AIMessage message) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              radius: 16,
              child: Icon(
                Icons.smart_toy,
                size: 18,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show structured data cards for AI responses
                if (!isUser && message.structuredData != null) ...[
                  _buildStructuredContent(message.structuredData!),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(
                            color: isUser 
                              ? theme.colorScheme.onPrimary 
                              : theme.colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            color: isUser 
                              ? theme.colorScheme.onPrimary.withOpacity(0.7)
                              : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondary,
              radius: 16,
              child: Icon(
                Icons.person,
                size: 18,
                color: theme.colorScheme.onSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildStructuredContent(AIStructuredResponse response) {
    final localizations = AppLocalizations.of(context);
    switch (response.type) {
      case AIResponseType.orderMetrics:
        final metrics = response.data as OrderMetrics;
        return OrderMetricsCard(metrics: metrics);
      case AIResponseType.driverMetrics:
        final metrics = response.data as DriverMetrics;
        return DriverMetricsCard(metrics: metrics);
      case AIResponseType.companyMetrics:
        final metrics = response.data as CompanyMetrics;
        return CompanyMetricsCard(metrics: metrics);
      case AIResponseType.systemInsights:
        final insights = response.data as SystemInsights;
        return SystemInsightsCard(insights: insights);
      case AIResponseType.textResponse:
      case AIResponseType.error:
      case AIResponseType.help:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: response.type == AIResponseType.error 
              ? Colors.red.withOpacity(0.1)
              : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: response.type == AIResponseType.error 
                ? Colors.red.withOpacity(0.3)
                : Colors.blue.withOpacity(0.3),
            ),
          ),
          child: MarkdownBody(
            data: response.message ?? 'No message available',
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 14),
              h1: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              h2: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              h3: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              listBullet: const TextStyle(fontSize: 14),
              code: TextStyle(
                backgroundColor: Colors.grey.withOpacity(0.2),
                fontFamily: 'monospace',
              ),
            ),
          ),
        );
    }
  }

  Widget _buildComposer() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.trim().isNotEmpty;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isComposing 
                ? () => _handleSubmitted(_messageController.text)
                : null,
              icon: Icon(
                Icons.send,
                color: _isComposing 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    final suggestions = [
      'Show today\'s orders',
      'Analyze performance',
      'Check driver status',
      'View company stats',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: suggestions.map((suggestion) => ActionChip(
            label: Text(suggestion),
            onPressed: () => _handleSubmitted(suggestion),
            backgroundColor: theme.colorScheme.surfaceVariant,
            labelStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.smart_toy,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text('AI Assistant'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              final aiProvider = Provider.of<AIProvider>(context, listen: false);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Clear Chat'),
                  content: Text('Are you sure you want to clear the chat history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(localizations.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        aiProvider.clearChat();
                        Navigator.of(context).pop();
                      },
                      child: Text('Clear'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AIProvider>(
              builder: (context, aiProvider, child) {
                final messages = aiProvider.messages;
                
                if (messages.isEmpty) {
                  return Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.smart_toy,
                                size: 64,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Hello! I\'m your AI assistant.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ask me about orders, drivers, companies, or analytics.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildSuggestionChips(),
                    ],
                  );
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length + (aiProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && aiProvider.isLoading) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.primary,
                              radius: 16,
                              child: Icon(
                                Icons.smart_toy,
                                size: 18,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Thinking...',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return _buildMessage(messages[index]);
                  },
                );
              },
            ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }
}
