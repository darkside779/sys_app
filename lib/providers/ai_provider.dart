// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../models/ai_message.dart';
import '../models/ai_response_models.dart';

class AIProvider extends ChangeNotifier {
  static final AIProvider _instance = AIProvider._internal();
  factory AIProvider() => _instance;
  AIProvider._internal();

  final AIService _aiService = AIService.instance;
  
  final List<AIMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<AIMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize AI provider and start chat session
  Future<void> initialize() async {
    try {
      await _aiService.initialize();
    } catch (e) {
      _error = 'Failed to initialize AI: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Send a message to the AI assistant
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message to history
    final userMessage = AIMessage.user(message);
    _messages.add(userMessage);
    notifyListeners();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get structured AI response
      final structuredResponse = await _aiService.sendMessage(message);
      
      // Convert structured response to message format
      String responseText = _convertStructuredResponseToText(structuredResponse);
      
      // Add AI response to history with structured data
      final aiMessage = AIMessage.assistant(responseText);
      // Store structured data for UI rendering
      aiMessage.structuredData = structuredResponse;
      _messages.add(aiMessage);
      
    } catch (e) {
      _error = 'Failed to get AI response: $e';
      notifyListeners();
      debugPrint('AI Provider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Convert structured response to text for display
  String _convertStructuredResponseToText(AIStructuredResponse response) {
    switch (response.type) {
      case AIResponseType.orderMetrics:
        final metrics = response.data as OrderMetrics;
        return '📦 Order metrics updated with ${metrics.totalOrders} total orders';
      case AIResponseType.driverMetrics:
        final metrics = response.data as DriverMetrics;
        return '🚚 Driver performance data with ${metrics.activeDrivers} active drivers';
      case AIResponseType.companyMetrics:
        final metrics = response.data as CompanyMetrics;
        return '🏢 Company analytics for ${metrics.totalCompanies} registered companies';
      case AIResponseType.systemInsights:
        return '🔍 System insights and analytics generated';
      case AIResponseType.textResponse:
      case AIResponseType.error:
      case AIResponseType.help:
        return response.message ?? 'Response received';
    }
  }

  /// Send a predefined query (like analytics request)
  Future<void> sendAnalyticsQuery(String queryType) async {
    if (_isLoading) return;

    String query;
    switch (queryType) {
      case 'performance':
        query = 'Show me today\'s performance metrics and analytics';
        break;
      case 'orders':
        query = 'What are today\'s orders and their current status?';
        break;
      case 'drivers':
        query = 'Show me driver performance and availability';
        break;
      case 'companies':
        query = 'Give me a summary of company statistics';
        break;
      default:
        query = 'Provide a general overview of the delivery system';
    }

    await sendMessage(query);
  }

  /// Clear chat history
  void clearChat() {
    _messages.clear();
    _error = null;
    _aiService.clearChatHistory();
    notifyListeners();
  }

  /// Get chat summary for context
  String getChatSummary() {
    if (_messages.isEmpty) return '';
    
    final recentMessages = _messages.length > 6 
        ? _messages.sublist(_messages.length - 6) 
        : _messages;
    
    return recentMessages
        .map((msg) => '${msg.isUser ? 'User' : 'Assistant'}: ${msg.content}')
        .join('\n');
  }


  /// Dispose resources
  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }
}
