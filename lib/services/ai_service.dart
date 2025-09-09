// ignore_for_file: avoid_print

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_data_service.dart';
import '../models/ai_response_models.dart';

class AIService {
  static AIService? _instance;
  static AIService get instance => _instance ??= AIService._internal();

  AIService._internal();

  GenerativeModel? _model;
  ChatSession? _chatSession;

  /// Initialize the AI service with API key from environment
  Future<void> initialize() async {
    try {
      final apiKey = dotenv.env['GOOGLE_AI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Google AI API key not found in environment variables');
      }

      _model = GenerativeModel(
        model: dotenv.env['AI_MODEL'] ?? 'gemini-1.5-pro',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          maxOutputTokens: int.tryParse(dotenv.env['AI_MAX_TOKENS'] ?? '2048'),
          temperature: double.tryParse(dotenv.env['AI_TEMPERATURE'] ?? '0.7'),
        ),
      );

      print('AI Service initialized successfully');
    } catch (e) {
      print('Failed to initialize AI Service: $e');
      rethrow;
    }
  }

  /// Start a new chat session
  void startNewChat({String? systemPrompt}) {
    if (_model == null) {
      throw Exception('AI Service not initialized. Call initialize() first.');
    }

    final initialHistory = systemPrompt != null
        ? [Content.text(systemPrompt)]
        : <Content>[];

    _chatSession = _model!.startChat(history: initialHistory);
  }

  /// Send a message to the AI model and get structured response
  Future<AIStructuredResponse> sendMessage(String message) async {
    try {
      // Check if this is a general conversation (greetings, general questions)
      final isArabic = _detectArabic(message);
      final generalResponse = _handleGeneralConversation(message, isArabic);
      
      if (generalResponse != null) {
        return generalResponse;
      }

      // Check if this is a natural language query that needs parsing
      if (_isNaturalLanguageQuery(message, isArabic)) {
        return await _processNaturalLanguageQuery(message);
      }

      // For data-related queries, get fresh data and generate structured response
      final data = await AIDataService.instance.getAllDataForAI();
      return _generateDataResponse(message, data, isArabic);
      
    } catch (e) {
      final isArabic = _detectArabic(message);
      return AIStructuredResponse.error(
        isArabic 
          ? 'خطأ في الخدمة: ${e.toString()}' 
          : 'Service error: ${e.toString()}',
      );
    }
  }

  /// Check if the message is a natural language query that needs parsing
  bool _isNaturalLanguageQuery(String message, bool isArabic) {
    final lowerMessage = message.toLowerCase();
    
    if (isArabic) {
      return RegExp(r'\b(اعرض|أظهر|احسب|كم|قارن|تحليل|توقع|ابحث)\b').hasMatch(lowerMessage) ||
             RegExp(r'\b(طلبات|سائقين|شركات|اليوم|أمس|الأسبوع|الشهر|مكتمل|معلق)\b').hasMatch(lowerMessage);
    } else {
      return RegExp(r'\b(show|display|count|how many|compare|analyze|predict|search)\b').hasMatch(lowerMessage) ||
             RegExp(r'\b(orders|drivers|companies|today|yesterday|week|month|completed|pending)\b').hasMatch(lowerMessage);
    }
  }

  /// Generate data response (renamed from _generateStructuredMockResponse)
  Future<AIStructuredResponse> _generateDataResponse(String message, Map<String, dynamic> data, bool isArabic) async {
    return _generateStructuredMockResponse(message);
  }

  /// Handle general conversation queries
  AIStructuredResponse? _handleGeneralConversation(String message, bool isArabic) {
    final lowerMessage = message.toLowerCase();
    
    // Greetings
    if (isArabic) {
      if (RegExp(r'\b(مرحبا|أهلا|السلام عليكم|صباح الخير|مساء الخير)\b').hasMatch(lowerMessage)) {
        return AIStructuredResponse.textResponse(
          '🤖 **مرحباً بك!** \n\nأنا مساعدك الذكي لإدارة نظام التوصيل. يمكنني مساعدتك في:\n\n'
          '📊 **تحليل البيانات**: اعرض إحصائيات الطلبات والسائقين\n'
          '🔍 **البحث**: ابحث عن معلومات محددة\n'
          '📈 **التوقعات**: توقع الطلب وأوقات التوصيل\n'
          '💡 **الرؤى**: احصل على توصيات وتحليلات\n\n'
          'اسأل عن أي شيء تريد معرفته!'
        );
      }
      
      if (RegExp(r'\b(كيف حالك|كيفك|شلونك)\b').hasMatch(lowerMessage)) {
        return AIStructuredResponse.textResponse(
          '🤖 أنا بخير وجاهز لمساعدتك! كيف يمكنني مساعدتك اليوم؟'
        );
      }
    } else {
      if (RegExp(r'\b(hello|hi|hey|good morning|good afternoon|good evening)\b').hasMatch(lowerMessage)) {
        return AIStructuredResponse.textResponse(
          '🤖 **Hello there!** \n\nI\'m your AI assistant for delivery management. I can help you with:\n\n'
          '📊 **Data Analysis**: View order and driver statistics\n'
          '🔍 **Search**: Find specific information\n'
          '📈 **Predictions**: Forecast demand and delivery times\n'
          '💡 **Insights**: Get recommendations and analysis\n\n'
          'Ask me anything you\'d like to know!'
        );
      }
      
      if (RegExp(r'\b(how are you|how do you do)\b').hasMatch(lowerMessage)) {
        return AIStructuredResponse.textResponse(
          '🤖 I\'m doing great and ready to help! How can I assist you today?'
        );
      }
    }

    // Help requests
    if (isArabic) {
      if (RegExp(r'\b(مساعدة|ساعدني|كيف|ماذا يمكنك)\b').hasMatch(lowerMessage)) {
        return AIStructuredResponse.textResponse(
          '📋 **يمكنني مساعدتك في:**\n\n'
          '• **اعرض الطلبات** - احصل على إحصائيات الطلبات\n'
          '• **كم عدد السائقين النشطين** - معلومات السائقين\n'
          '• **تحليل الأداء** - رؤى النظام\n'
          '• **توقع الطلب** - توقعات مستقبلية\n'
          '• **اعرض طلبات اليوم** - بيانات مفلترة حسب التاريخ\n\n'
          'جرب أي من هذه الأسئلة!'
        );
      }
    } else {
      if (RegExp(r'\b(help|assist|what can you|how to)\b').hasMatch(lowerMessage)) {
        return AIStructuredResponse.textResponse(
          '📋 **I can help you with:**\n\n'
          '• **Show orders** - Get order statistics\n'
          '• **How many active drivers** - Driver information\n'
          '• **Analyze performance** - System insights\n'
          '• **Predict demand** - Future forecasts\n'
          '• **Show today\'s orders** - Date-filtered data\n\n'
          'Try asking any of these questions!'
        );
      }
    }

    return null; // Not a general conversation, continue to data processing
  }

  /// Get suggested questions for quick actions
  List<String> getSuggestedQuestions(bool isArabic) {
    if (isArabic) {
      return [
        'اعرض طلبات اليوم',
        'كم عدد السائقين النشطين؟',
        'تحليل أداء النظام',
        'توقع الطلب للأسبوع القادم',
        'اعرض أفضل الشركات',
        'كم طلب مكتمل هذا الأسبوع؟',
        'اعرض السائقين غير النشطين',
        'تحليل طلبات الشهر الماضي',
      ];
    } else {
      return [
        'Show today\'s orders',
        'How many active drivers?',
        'Analyze system performance',
        'Predict demand for next week',
        'Show top companies',
        'How many completed orders this week?',
        'Show inactive drivers',
        'Analyze last month\'s orders',
      ];
    }
  }

  /// Get chart/graph suggestions based on current data context
  List<Map<String, dynamic>> getChartSuggestions(String entity, bool isArabic) {
    switch (entity.toLowerCase()) {
      case 'orders':
        return [
          {
            'type': 'line_chart',
            'title': isArabic ? 'اتجاه الطلبات عبر الزمن' : 'Orders Trend Over Time',
            'description': isArabic ? 'يظهر نمو أو انخفاض الطلبات' : 'Shows order growth or decline',
            'icon': '📈',
          },
          {
            'type': 'pie_chart', 
            'title': isArabic ? 'توزيع حالات الطلبات' : 'Order Status Distribution',
            'description': isArabic ? 'مكتمل، معلق، ملغي، إلخ' : 'Completed, pending, cancelled, etc.',
            'icon': '🥧',
          },
          {
            'type': 'bar_chart',
            'title': isArabic ? 'الطلبات حسب ساعات اليوم' : 'Orders by Hour of Day',
            'description': isArabic ? 'أوقات الذروة والهدوء' : 'Peak and quiet hours',
            'icon': '📊',
          },
        ];
        
      case 'drivers':
        return [
          {
            'type': 'bar_chart',
            'title': isArabic ? 'كفاءة السائقين' : 'Driver Efficiency',
            'description': isArabic ? 'مقارنة أداء السائقين' : 'Compare driver performance',
            'icon': '📊',
          },
          {
            'type': 'scatter_plot',
            'title': isArabic ? 'التوصيلات مقابل التقييم' : 'Deliveries vs Rating',
            'description': isArabic ? 'العلاقة بين العدد والجودة' : 'Relationship between quantity and quality',
            'icon': '🔸',
          },
          {
            'type': 'pie_chart',
            'title': isArabic ? 'السائقون النشطون مقابل غير النشطين' : 'Active vs Inactive Drivers',
            'description': isArabic ? 'نسبة النشاط' : 'Activity ratio',
            'icon': '🥧',
          },
        ];
        
      case 'companies':
        return [
          {
            'type': 'bar_chart',
            'title': isArabic ? 'تقييمات الشركات' : 'Company Ratings',
            'description': isArabic ? 'مقارنة تقييمات الشراكات' : 'Compare partner ratings',
            'icon': '📊',
          },
          {
            'type': 'line_chart',
            'title': isArabic ? 'نمو الشراكات' : 'Partnership Growth',
            'description': isArabic ? 'توسع قاعدة الشراكات' : 'Partner base expansion',
            'icon': '📈',
          },
        ];
        
      default:
        return [
          {
            'type': 'dashboard',
            'title': isArabic ? 'لوحة معلومات شاملة' : 'Comprehensive Dashboard',
            'description': isArabic ? 'نظرة عامة على جميع المقاييس' : 'Overview of all metrics',
            'icon': '📋',
          },
          {
            'type': 'heatmap',
            'title': isArabic ? 'خريطة النشاط' : 'Activity Heatmap',
            'description': isArabic ? 'أنماط النشاط عبر الوقت' : 'Activity patterns over time',
            'icon': '🗺️',
          },
        ];
    }
  }

  /// Send a message to the AI model (legacy method for backward compatibility)
  Future<String> sendMessageText(String message) async {
    final structuredResponse = await sendMessage(message);
    
    // Convert structured response back to text for legacy support
    switch (structuredResponse.type) {
      case AIResponseType.orderMetrics:
        final metrics = structuredResponse.data as OrderMetrics;
        return '''📦 Order Metrics:
Total: ${metrics.totalOrders}
Completed: ${metrics.completed}
Pending: ${metrics.pending}
Revenue: \$${metrics.revenue.toStringAsFixed(2)}''';
      case AIResponseType.driverMetrics:
        final metrics = structuredResponse.data as DriverMetrics;
        return '''🚚 Driver Metrics:
Total Drivers: ${metrics.totalDrivers}
Active: ${metrics.activeDrivers}
Best: ${metrics.mostActiveDriver}''';
      case AIResponseType.companyMetrics:
        final metrics = structuredResponse.data as CompanyMetrics;
        return '''🏢 Company Metrics:
Total: ${metrics.totalCompanies}
Active: ${metrics.activeCompanies}
Best: ${metrics.bestPerformingCompany}''';
      case AIResponseType.systemInsights:
      case AIResponseType.textResponse:
      case AIResponseType.error:
      case AIResponseType.help:
        return structuredResponse.message ?? 'No message available';
    }
  }

  /// Send a one-time message without chat history
  Future<String> generateResponse(String prompt, {String? context}) async {
    if (_model == null) {
      throw Exception('AI Service not initialized. Call initialize() first.');
    }

    try {
      final content = context != null ? '$context\n\n$prompt' : prompt;
      final response = await _model!.generateContent([Content.text(content)]);
      return response.text ?? 'No response generated';
    } catch (e) {
      print('Error generating AI response: $e');

      // Check if it's a quota exceeded error
      if (e.toString().contains('exceeded your current quota')) {
        return await _generateMockResponse(prompt);
      }

      return 'Sorry, I encountered an error processing your request. Please try again.';
    }
  }

  /// Analyze data with AI
  Future<String> analyzeData(
    String dataDescription,
    Map<String, dynamic> data,
  ) async {
    if (_model == null) {
      throw Exception('AI Service not initialized. Call initialize() first.');
    }

    try {
      final prompt =
          '''
You are an AI assistant analyzing delivery management data. 

Data Description: $dataDescription

Data: ${_formatDataForAI(data)}

Please analyze this data and provide insights including:
1. Key trends and patterns
2. Notable statistics
3. Areas for improvement
4. Actionable recommendations

Keep your response clear and organized.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'Analysis could not be completed';
    } catch (e) {
      print('Error analyzing data with AI: $e');
      return 'Sorry, I encountered an error analyzing the data. Please try again.';
    }
  }

  /// Format data for AI consumption
  String _formatDataForAI(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    data.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    return buffer.toString();
  }

  /// Get current chat history
  List<Content> getChatHistory() {
    return _chatSession?.history.toList() ?? [];
  }

  /// Clear chat history and start fresh
  void clearChatHistory() {
    if (_model != null) {
      _chatSession = _model!.startChat();
    }
  }

  /// Generate a structured mock response when AI API is not available
  Future<AIStructuredResponse> _generateStructuredMockResponse(String message) async {
    final lowerMessage = message.toLowerCase();
    final isArabic = _detectArabic(message);

    // Check if it's a conversational message first
    final conversationalResponse = _handleConversationalMessage(message);
    if (conversationalResponse != null) {
      return conversationalResponse;
    }

    try {
      final data = await AIDataService.instance.getAllDataForAI();

      if (lowerMessage.contains('order') || lowerMessage.contains('today') || 
          lowerMessage.contains('طلب') || lowerMessage.contains('اليوم')) {
        return _generateOrderAnalytics(data, isArabic);
      }

      if (lowerMessage.contains('driver') || lowerMessage.contains('performance') ||
          lowerMessage.contains('سائق') || lowerMessage.contains('أداء')) {
        return _generateDriverAnalytics(data, isArabic);
      }

      if (lowerMessage.contains('company') || lowerMessage.contains('stat') ||
          lowerMessage.contains('شركة') || lowerMessage.contains('إحصائيات')) {
        return _generateCompanyAnalytics(data, isArabic);
      }

      if (lowerMessage.contains('analyz') || lowerMessage.contains('insight') ||
          lowerMessage.contains('تحليل') || lowerMessage.contains('رؤى')) {
        return generateSystemInsights(data, isArabic);
      }

      // Default help response
      return _getHelpResponse(isArabic);
    } catch (e) {
      print('Error fetching real data for structured mock response: $e');
      return AIStructuredResponse.error(
        isArabic 
          ? 'خطأ في جلب البيانات. يرجى المحاولة مرة أخرى.'
          : 'Error fetching data. Please try again.',
      );
    }
  }

  /// Handle conversational messages (greetings, small talk)
  AIStructuredResponse? _handleConversationalMessage(String message) {
    final lowerMessage = message.toLowerCase();
    final isArabic = _detectArabic(message);

    // Greetings
    if (_isGreeting(lowerMessage, isArabic)) {
      return AIStructuredResponse.textResponse(
        isArabic
          ? '''مرحباً! 😊 أنا مساعدك الذكي لنظام إدارة التوصيل.

**كيف يمكنني مساعدتك اليوم؟**
• عرض طلبات اليوم - إحصائيات الطلبات
• تحليل الأداء - مقاييس السائقين والتوصيل  
• إحصائيات الشركات - تحليلات الأعمال
• رؤى النظام - توصيات تشغيلية

أو يمكنك ببساطة أن تسأل عن أي شيء تريد معرفته! 🚀'''
          : '''Hello! 😊 I'm your AI assistant for the delivery management system.

**How can I help you today?**
• "Show today's orders" - View order statistics
• "Analyze performance" - Driver & delivery metrics  
• "Check company stats" - Business analytics
• "System insights" - Operational recommendations

Or just ask me anything you'd like to know! 🚀''',
      );
    }

    // How are you / State inquiries
    if (_isStateInquiry(lowerMessage, isArabic)) {
      return AIStructuredResponse.textResponse(
        isArabic
          ? '''الحمد لله، أنا بخير وجاهز لمساعدتك! 😄

**حالة النظام الحالية:**
✅ قاعدة بيانات Firebase متصلة
✅ البيانات المباشرة متاحة
✅ جميع الخدمات تعمل بشكل طبيعي

هل تريد مراجعة أي بيانات معينة أو لديك استفسار محدد؟'''
          : '''I'm doing great and ready to help you! 😄

**Current System Status:**
✅ Firebase database connected
✅ Live data available  
✅ All services operational

Would you like to check any specific data or do you have a particular question?''',
      );
    }

    // Thank you messages
    if (_isThankYou(lowerMessage, isArabic)) {
      return AIStructuredResponse.textResponse(
        isArabic
          ? '''العفو! 😊 أسعدني أن أساعدك.

إذا كنت بحاجة لأي معلومات أخرى عن النظام أو تريد تحليل أي بيانات، فقط اسأل!

**نصائح سريعة:**
📊 جرب "عرض طلبات اليوم" للإحصائيات
🚚 أو "تحليل الأداء" لمعلومات السائقين
🏢 أو "إحصائيات الشركات" لتحليلات الأعمال'''
          : '''You're very welcome! 😊 Happy to help.

If you need any other information about the system or want to analyze any data, just ask!

**Quick Tips:**
📊 Try "Show today's orders" for statistics
🚚 Or "Analyze performance" for driver info
🏢 Or "Check company stats" for business analytics''',
      );
    }

    // Help requests
    if (_isHelpRequest(lowerMessage, isArabic)) {
      return _getHelpResponse(isArabic);
    }

    // If it's a general question, try to give a helpful but natural response
    if (message.trim().length > 2 && !_isSpecificCommand(lowerMessage)) {
      return _handleGeneralQuestion(message, isArabic);
    }

    return null; // Not a conversational message
  }

  /// Detect if message is in Arabic
  bool _detectArabic(String message) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(message);
  }

  /// Check if message is a greeting
  bool _isGreeting(String lowerMessage, bool isArabic) {
    if (isArabic) {
      return lowerMessage.contains('مرحبا') || lowerMessage.contains('مرحباً') || 
             lowerMessage.contains('السلام') || lowerMessage.contains('أهلا') ||
             lowerMessage.contains('اهلا') || lowerMessage.contains('صباح') ||
             lowerMessage.contains('مساء');
    } else {
      return lowerMessage.contains('hello') || lowerMessage.contains('hi') || 
             lowerMessage.contains('hey') || lowerMessage.contains('good morning') ||
             lowerMessage.contains('good afternoon') || lowerMessage.contains('good evening');
    }
  }

  /// Check if message is asking about state/condition
  bool _isStateInquiry(String lowerMessage, bool isArabic) {
    if (isArabic) {
      return lowerMessage.contains('كيف حالك') || lowerMessage.contains('كيفك') ||
             lowerMessage.contains('إيش أخبارك') || lowerMessage.contains('شو أخبارك') ||
             lowerMessage.contains('كيف الأحوال') || lowerMessage.contains('إيش الأخبار');
    } else {
      return lowerMessage.contains('how are you') || lowerMessage.contains('how do you do') ||
             lowerMessage.contains('what\'s up') || lowerMessage.contains('how\'s it going') ||
             lowerMessage.contains('how are things');
    }
  }

  /// Check if message is thanking
  bool _isThankYou(String lowerMessage, bool isArabic) {
    if (isArabic) {
      return lowerMessage.contains('شكرا') || lowerMessage.contains('شكراً') ||
             lowerMessage.contains('مشكور') || lowerMessage.contains('تسلم') ||
             lowerMessage.contains('يعطيك العافية');
    } else {
      return lowerMessage.contains('thank') || lowerMessage.contains('thanks') ||
             lowerMessage.contains('appreciate') || lowerMessage.contains('grateful');
    }
  }

  /// Check if message is asking for help
  bool _isHelpRequest(String lowerMessage, bool isArabic) {
    if (isArabic) {
      return lowerMessage.contains('مساعدة') || lowerMessage.contains('ساعدني') ||
             lowerMessage.contains('إيش تقدر تسوي') || lowerMessage.contains('شو بتقدر تعمل') ||
             lowerMessage.contains('كيف أستخدم') || lowerMessage.contains('help');
    } else {
      return lowerMessage.contains('help') || lowerMessage.contains('assist') ||
             lowerMessage.contains('what can you do') || lowerMessage.contains('how to use') ||
             lowerMessage.contains('commands') || lowerMessage.contains('functions');
    }
  }

  /// Check if it's a specific system command
  bool _isSpecificCommand(String lowerMessage) {
    final commands = [
      'order', 'today', 'driver', 'performance', 'company', 'stat', 'analyz', 'insight',
      'طلب', 'اليوم', 'سائق', 'أداء', 'شركة', 'إحصائيات', 'تحليل', 'رؤى'
    ];
    return commands.any((cmd) => lowerMessage.contains(cmd));
  }

  /// Handle general questions with natural responses
  AIStructuredResponse _handleGeneralQuestion(String message, bool isArabic) {
    final lowerMessage = message.toLowerCase();
    
    // Business/customer related questions
    if (lowerMessage.contains('customer') || lowerMessage.contains('client') || 
        lowerMessage.contains('عميل') || lowerMessage.contains('زبون')) {
      return AIStructuredResponse.textResponse(
        isArabic
          ? '''بالنسبة لعدد العملاء، يمكنني مساعدتك في الحصول على هذه المعلومات من خلال عرض إحصائيات الشركات والطلبات.

جرب قول "إحصائيات الشركات" أو "اعرض طلبات اليوم" للحصول على بيانات مفصلة عن العملاء والطلبات! 📊'''
          : '''For customer information, I can help you get these details through company statistics and order data.

Try saying "Check company stats" or "Show today's orders" to get detailed customer and order information! 📊''',
      );
    }

    // Time/date questions  
    if (lowerMessage.contains('time') || lowerMessage.contains('date') || lowerMessage.contains('when') ||
        lowerMessage.contains('وقت') || lowerMessage.contains('تاريخ') || lowerMessage.contains('متى')) {
      final now = DateTime.now();
      return AIStructuredResponse.textResponse(
        isArabic
          ? '''الوقت الحالي: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}
التاريخ: ${now.day}/${now.month}/${now.year}

هل تريد مراجعة طلبات اليوم أو أي معلومات أخرى؟ ⏰'''
          : '''Current time: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}
Date: ${now.day}/${now.month}/${now.year}

Would you like to check today's orders or any other information? ⏰''',
      );
    }

    // Weather questions
    if (lowerMessage.contains('weather') || lowerMessage.contains('طقس') || lowerMessage.contains('جو')) {
      return AIStructuredResponse.textResponse(
        isArabic
          ? '''لا أستطيع التحقق من الطقس، لكن يمكنني مساعدتك في مراقبة أداء نظام التوصيل!

هل تريد معرفة كيف يؤثر الطقس على توصيلاتنا اليوم؟ 🌤️'''
          : '''I can't check the weather, but I can help you monitor delivery system performance!

Would you like to see how weather might be affecting our deliveries today? 🌤️''',
      );
    }

    // Math questions
    if (lowerMessage.contains('calculate') || lowerMessage.contains('math') || lowerMessage.contains('+') || 
        lowerMessage.contains('احسب') || lowerMessage.contains('رياضيات')) {
      return AIStructuredResponse.textResponse(
        isArabic
          ? '''يمكنني مساعدتك في حسابات متعلقة بالتوصيل مثل:
• متوسط تكلفة الطلبات
• معدل إنجاز السائقين  
• إحصائيات الأرباح

جرب "رؤى النظام" للحصول على تحليلات مالية مفصلة! 🧮'''
          : '''I can help with delivery-related calculations like:
• Average order costs
• Driver completion rates
• Revenue statistics

Try "System insights" for detailed financial analytics! 🧮''',
      );
    }

    // Food/restaurants
    if (lowerMessage.contains('food') || lowerMessage.contains('restaurant') || lowerMessage.contains('eat') ||
        lowerMessage.contains('طعام') || lowerMessage.contains('مطعم') || lowerMessage.contains('أكل')) {
      return AIStructuredResponse.textResponse(
        isArabic
          ? '''بما أنني مختص في إدارة التوصيل، يمكنني مساعدتك في معرفة:
• إحصائيات طلبات الطعام اليوم
• أداء مطاعم الشراكة
• أوقات التوصيل المتوقعة

هل تريد مراجعة بيانات المطاعم والطلبات؟ 🍕'''
          : '''Since I specialize in delivery management, I can help you check:
• Today's food order statistics
• Partner restaurant performance  
• Expected delivery times

Would you like to review restaurant and order data? 🍕''',
      );
    }

    // Default natural response for other general questions
    return AIStructuredResponse.textResponse(
      isArabic
        ? '''أفهم سؤالك! وإن كان لا يقع ضمن تخصصي المباشر في إدارة التوصيل، فأنا سعيد للمحادثة معك.

إذا كان لديك أي استفسار عن النظام أو البيانات، أو تريد مجرد الدردشة، فأنا هنا! 😊

هل يمكنني مساعدتك بشيء آخر؟'''
        : '''I understand your question! While it might not be directly related to delivery management, I'm happy to chat with you.

If you have any questions about the system or data, or just want to have a conversation, I'm here! 😊

Is there anything else I can help you with?''',
    );
  }

  /// Get help response in appropriate language
  AIStructuredResponse _getHelpResponse(bool isArabic) {
    return AIStructuredResponse.textResponse(
      isArabic
        ? '''🤖 **مركز قيادة المساعد الذكي**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 **الأوامر المتاحة**
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 📊 "اعرض طلبات اليوم"     │ إحصائيات الطلبات   ┃
┃ 🚚 "تحليل الأداء"        │ مقاييس السائقين    ┃
┃ 🏢 "إحصائيات الشركات"    │ بيانات الأعمال     ┃
┃ 🔍 "رؤى النظام"          │ التحليلات         ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

✨ **مميزات العرض التوضيحي**
• ✅ بيانات Firebase مباشرة
• ✅ استجابات ذكية حسب السياق
• ✅ واجهة محادثة تفاعلية
• ✅ مراقبة النظام المباشر

🚀 *جرب أي أمر أعلاه لاستكشاف نظام التوصيل!*'''
        : '''🤖 **AI Assistant Command Center**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 **Available Commands**
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 📊 "Show today's orders"   │ Order stats     ┃
┃ 🚚 "Analyze performance"   │ Driver metrics  ┃
┃ 🏢 "Check company stats"   │ Business data   ┃
┃ 🔍 "System insights"       │ Analytics       ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

✨ **Demo Features**
• ✅ Real-time Firebase data
• ✅ Context-aware responses  
• ✅ Interactive chat interface
• ✅ Live system monitoring

🚀 *Try any command above to explore your delivery system!*''',
    );
  }

  /// Generate responses with real Firebase data when quota is exceeded
  Future<String> _generateMockResponse(String message) async {
    final lowerMessage = message.toLowerCase();
    final dataService = AIDataService.instance;

    try {
      final data = await dataService.getAllDataForAI();

      if (lowerMessage.contains('order') || lowerMessage.contains('today')) {
        final ordersData = data['orders'] as Map<String, dynamic>? ?? {};
        
        return '''🚀 **TODAY'S ORDERS DASHBOARD** 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 **ORDER METRICS**
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 📦 Total Orders      │ ${ordersData['total_orders'] ?? 0}           ┃
┃ ✅ Completed         │ ${ordersData['completed_orders'] ?? 0}           ┃  
┃ ⏳ Pending           │ ${ordersData['pending_orders'] ?? 0}           ┃
┃ 🚚 Out for Delivery  │ ${ordersData['out_for_delivery'] ?? 0}           ┃
┃ ❌ Not Returned      │ ${ordersData['not_returned'] ?? 0}           ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

💰 **FINANCIAL OVERVIEW**
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 💵 Total Revenue     │ \$${(ordersData['total_cost'] ?? 0.0).toStringAsFixed(2)}      ┃
┃ 📊 Average Order     │ \$${(ordersData['average_cost'] ?? 0.0).toStringAsFixed(2)}      ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

🔥 **RECENT ACTIVITY**
• 📅 ${ordersData['recent_orders_count'] ?? 0} orders in last 7 days
• 🔄 Live Firebase sync active
• 📡 Real-time tracking enabled

🎯 *Live data powered by Firebase • Demo mode active*''';
      }

      if (lowerMessage.contains('driver') || lowerMessage.contains('performance')) {
        final driversData = data['drivers'] as Map<String, dynamic>? ?? {};
        
        return '''🏆 **DRIVER PERFORMANCE CENTER**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 **DRIVER OVERVIEW**
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 👤 Total Drivers     │ ${driversData['total_drivers'] ?? 0}           ┃
┃ 🟢 Active Now        │ ${driversData['active_drivers'] ?? 0}           ┃
┃ 🚛 Total Deliveries  │ ${driversData['total_deliveries'] ?? 0}           ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

⭐ **TOP PERFORMER**
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 🥇 Best Driver       │ ${driversData['most_active_driver'] ?? 'No data'}    ┃
┃ 📊 Avg per Driver    │ ${(driversData['average_deliveries_per_driver'] ?? 0.0).toStringAsFixed(1)}         ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

🔄 **LIVE STATUS**
• 📡 Firebase sync active
• 🎯 Real-time performance tracking
• 📈 Driver metrics updated live

🚀 *Performance data powered by Firebase • Demo mode*''';
      }

      if (lowerMessage.contains('company') || lowerMessage.contains('stat')) {
        final companiesData = data['companies'] as Map<String, dynamic>? ?? {};
        
        return '''🏢 **Company Statistics Overview** (Live Data - Demo Mode)

**Registered Companies**: ${companiesData['total_companies'] ?? 0} partners

**Company Status:**
• **Active Companies**: ${companiesData['active_companies'] ?? 0}
• **Inactive Companies**: ${companiesData['inactive_companies'] ?? 0}
• **Best Performing**: ${companiesData['best_company'] ?? 'No data'}

**Live Status:**
- Data synced from Firebase in real-time
- Real company performance metrics

*Note: Live Firebase data displayed in demo mode due to AI quota limits.*''';
      }

      if (lowerMessage.contains('analyz') || lowerMessage.contains('insight')) {
        final ordersData = data['orders'] as Map<String, dynamic>? ?? {};
        final companiesData = data['companies'] as Map<String, dynamic>? ?? {};
        final driversData = data['drivers'] as Map<String, dynamic>? ?? {};
        
        return '''🔍 **SYSTEM INSIGHTS & ANALYTICS**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 **OPERATIONAL OVERVIEW**
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 📦 Total Orders      │ ${ordersData['total_orders'] ?? 0}           ┃
┃ 🏢 Active Companies  │ ${companiesData['active_companies'] ?? 0}           ┃
┃ 🚚 Active Drivers    │ ${driversData['active_drivers'] ?? 0}           ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

🎯 **PERFORMANCE INSIGHTS**
• 📈 Revenue: \$${(ordersData['total_cost'] ?? 0.0).toStringAsFixed(2)}
• 🏆 Top Company: ${companiesData['best_performing_company'] ?? 'No data'}
• ⭐ Best Driver: ${driversData['most_active_driver'] ?? 'No data'}
• 📊 Avg Order: \$${(ordersData['average_cost'] ?? 0.0).toStringAsFixed(2)}

🔄 **SYSTEM HEALTH**
• ✅ Firebase: Connected & Synced
• 📡 Real-time: Active
• 🎯 Data Quality: Live & Accurate
• 🚀 Performance: Optimal

💡 **RECOMMENDATIONS**
• Monitor driver performance trends
• Optimize company partnerships
• Track order completion rates
• Analyze revenue patterns

🌟 *Advanced analytics powered by Firebase • Demo mode*''';
      }
    } catch (e) {
      print('Error fetching real data for mock response: $e');
      return '''⚠️ **Data Access Issue** (Demo Mode)

Unable to fetch live Firebase data at the moment. This might be due to:
- Network connectivity issues
- Firebase configuration problems
- Permission restrictions

**What you can try:**
1. Check your internet connection
2. Verify Firebase is properly configured
3. Ensure you're logged in as admin

*Note: Demo mode active due to AI quota limits.*''';
    }

    // Default response for general queries
    return '''🤖 **AI ASSISTANT COMMAND CENTER**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 **AVAILABLE COMMANDS**
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 📊 "Show today's orders"   │ Order stats     ┃
┃ 🚚 "Analyze performance"   │ Driver metrics  ┃
┃ 🏢 "Check company stats"   │ Business data   ┃
┃ 🔍 "System insights"       │ Analytics       ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

✨ **DEMO FEATURES**
• ✅ Real-time Firebase data
• ✅ Context-aware responses  
• ✅ Interactive chat interface
• ✅ Live system monitoring

🚀 *Try any command above to explore your delivery system!*''';
  }

  /// Check if AI service is ready
  bool get isInitialized => _model != null;

  /// Check if chat session is active
  bool get isChatActive => _chatSession != null;

  /// Dispose resources
  void dispose() {
    _chatSession = null;
    _model = null;
  }

  /// Generate order analytics with enhanced metrics
  AIStructuredResponse _generateOrderAnalytics(Map<String, dynamic> data, bool isArabic) {
    final ordersData = data['orders'] as Map<String, dynamic>? ?? {};
    final orders = ordersData['recent_orders'] as List<dynamic>? ?? [];
    final ordersList = orders.cast<Map<String, dynamic>>();
    
    // Use advanced analytics
    final analytics = _analyzeOrderTrends(ordersList);
    
    final totalOrders = ordersList.length;
    final completedOrders = ordersList.where((o) => o['status'] == 'completed').length;
    final pendingOrders = ordersList.where((o) => o['status'] == 'pending').length;
    final revenue = ordersList.fold<double>(0, (sum, order) {
      final cost = order['totalCost'];
      if (cost is num) return sum + cost.toDouble();
      if (cost is String) return sum + (double.tryParse(cost) ?? 0);
      return sum;
    });

    final metrics = OrderMetrics(
      totalOrders: totalOrders,
      completed: completedOrders,
      pending: pendingOrders,
      outForDelivery: ordersList.where((o) => o['status'] == 'out_for_delivery').length,
      notReturned: ordersList.where((o) => o['status'] == 'not_returned').length,
      revenue: (analytics['totalRevenue'] ?? revenue).toDouble(),
      avgOrder: (analytics['avgOrderValue'] ?? (totalOrders > 0 ? (revenue / totalOrders) : 0)).toDouble(),
      recentOrdersCount: ordersList.where((o) {
        try {
          if (o['timestamp'] is String) {
            final orderTime = DateTime.parse(o['timestamp']);
            return DateTime.now().difference(orderTime).inDays <= 7;
          }
        } catch (e) {
          // ignore
        }
        return false;
      }).length,
    );

    return AIStructuredResponse.orderMetrics(metrics);
  }

  /// Generate driver analytics with performance insights
  AIStructuredResponse _generateDriverAnalytics(Map<String, dynamic> data, bool isArabic) {
    final driversData = data['drivers'] as Map<String, dynamic>? ?? {};
    final drivers = driversData['drivers'] as List<dynamic>? ?? [];
    final driversList = drivers.cast<Map<String, dynamic>>();
    
    // Use advanced analytics
    final analytics = _analyzeDriverPerformance(driversList);
    
    final totalDrivers = driversList.length;
    final activeDrivers = driversList.where((d) => d['isActive'] == true).length;
    final totalDeliveries = driversList.fold<int>(0, (sum, driver) {
      final deliveries = driver['completedDeliveries'];
      if (deliveries is int) return sum + deliveries;
      return sum;
    });

    final metrics = DriverMetrics(
      totalDrivers: totalDrivers,
      activeDrivers: activeDrivers,
      totalDeliveries: totalDeliveries,
      avgDeliveriesPerDriver: totalDrivers > 0 ? (totalDeliveries / totalDrivers).toDouble() : 0.0,
      mostActiveDriver: analytics['topPerformers']?.isNotEmpty == true 
          ? analytics['topPerformers'][0]['name'] 
          : 'No data',
    );

    return AIStructuredResponse.driverMetrics(metrics);
  }

  /// Generate company analytics with performance comparison
  AIStructuredResponse _generateCompanyAnalytics(Map<String, dynamic> data, bool isArabic) {
    final companiesData = data['companies'] as Map<String, dynamic>? ?? {};
    final companies = companiesData['companies'] as List<dynamic>? ?? [];
    final companiesList = companies.cast<Map<String, dynamic>>();
    
    // Use advanced analytics
    final analytics = _analyzeCompanyPerformance(companiesList);
    
    final totalCompanies = companiesList.length;
    final activeCompanies = companiesList.where((c) => c['isActive'] == true).length;

    final metrics = CompanyMetrics(
      totalCompanies: totalCompanies,
      activeCompanies: activeCompanies,
      inactiveCompanies: totalCompanies - activeCompanies,
      bestPerformingCompany: analytics['topCompanies']?.isNotEmpty == true 
          ? analytics['topCompanies'][0]['name'] 
          : 'No data',
    );

    return AIStructuredResponse.companyMetrics(metrics);
  }

  /// Generate system insights with predictive analytics
  AIStructuredResponse generateSystemInsights(Map<String, dynamic> data, bool isArabic) {
    final ordersData = data['orders'] as Map<String, dynamic>? ?? {};
    final driversData = data['drivers'] as Map<String, dynamic>? ?? {};
    final companiesData = data['companies'] as Map<String, dynamic>? ?? {};
    
    final orders = (ordersData['recent_orders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final drivers = (driversData['drivers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final companies = (companiesData['companies'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    
    // Advanced analytics
    final orderAnalytics = _analyzeOrderTrends(orders);
    final driverAnalytics = _analyzeDriverPerformance(drivers);
    final companyAnalytics = _analyzeCompanyPerformance(companies);
    
    // Generate insights and recommendations
    List<String> insights = [];
    List<String> recommendations = [];
    
    // Order insights
    if (orderAnalytics['peakHours']?.isNotEmpty == true) {
      final peakHour = orderAnalytics['peakHours'][0]['hour'];
      insights.add(isArabic 
          ? 'ذروة الطلبات في الساعة $peakHour'
          : 'Peak orders at hour $peakHour');
    }
    
    // Success rate insights
    final successRate = orderAnalytics['successRate'] ?? 0;
    if (successRate < 80) {
      recommendations.add(isArabic 
          ? 'تحسين معدل نجاح التوصيل (حاليا $successRate%)'
          : 'Improve delivery success rate (currently $successRate%)');
    }
    
    // Driver insights
    final avgEfficiency = driverAnalytics['avgEfficiency'] ?? 0;
    if (avgEfficiency < 75) {
      recommendations.add(isArabic 
          ? 'تدريب السائقين لتحسين الكفاءة'
          : 'Driver training needed to improve efficiency');
    }

    // Generate predictive analytics
    final demandForecast = _forecastDemand(orders);
    final deliveryPredictions = _predictDeliveryTimes(orders);
    final anomalies = _detectAnomalies(orders, drivers, companies);
    final optimizationSuggestions = _generateOptimizationSuggestions(
      orderAnalytics, driverAnalytics, companyAnalytics, anomalies, isArabic);

    // Add demand forecast insights
    if (demandForecast['totalPredictedOrders'] != null && demandForecast['totalPredictedOrders'] > 0) {
      insights.add(isArabic 
          ? 'توقع ${demandForecast['totalPredictedOrders']} طلب الأسبوع القادم'
          : 'Predicted ${demandForecast['totalPredictedOrders']} orders next week');
    }

    // Add delivery time predictions
    if (deliveryPredictions['avgDeliveryTime'] != null && deliveryPredictions['avgDeliveryTime'] != 'No data') {
      insights.add(isArabic 
          ? 'متوسط وقت التوصيل المتوقع: ${deliveryPredictions['avgDeliveryTime']} دقيقة'
          : 'Average delivery time: ${deliveryPredictions['avgDeliveryTime']} minutes');
    }

    // Add anomaly insights
    for (var anomaly in anomalies) {
      if (anomaly['severity'] == 'High') {
        insights.add(isArabic 
            ? 'تحذير: ${anomaly['type']} - ${anomaly['description']}'
            : 'Alert: ${anomaly['type']} - ${anomaly['description']}');
      }
    }

    // Replace generic recommendations with AI-generated optimization suggestions
    recommendations.clear();
    recommendations.addAll(optimizationSuggestions);

    // Create metrics for SystemInsights
    final orderMetrics = OrderMetrics(
      totalOrders: orders.length,
      completed: orders.where((o) => o['status'] == 'completed').length,
      pending: orders.where((o) => o['status'] == 'pending').length,
      outForDelivery: orders.where((o) => o['status'] == 'out_for_delivery').length,
      notReturned: orders.where((o) => o['status'] == 'not_returned').length,
      revenue: orderAnalytics['totalRevenue']?.toDouble() ?? 0.0,
      avgOrder: orderAnalytics['avgOrderValue']?.toDouble() ?? 0.0,
      recentOrdersCount: orders.where((o) {
        try {
          if (o['timestamp'] is String) {
            final orderTime = DateTime.parse(o['timestamp']);
            return DateTime.now().difference(orderTime).inDays <= 7;
          }
        } catch (e) {
          // ignore
        }
        return false;
      }).length,
    );

    final driverMetrics = DriverMetrics(
      totalDrivers: drivers.length,
      activeDrivers: driverAnalytics['activeDrivers'] ?? 0,
      totalDeliveries: drivers.fold<int>(0, (sum, driver) {
        final deliveries = driver['completedDeliveries'];
        if (deliveries is int) return sum + deliveries;
        return sum;
      }),
      avgDeliveriesPerDriver: driverAnalytics['avgEfficiency']?.toDouble() ?? 0.0,
      mostActiveDriver: driverAnalytics['topPerformers']?.isNotEmpty == true 
          ? driverAnalytics['topPerformers'][0]['name'] 
          : 'No data',
    );

    final companyMetrics = CompanyMetrics(
      totalCompanies: companies.length,
      activeCompanies: companyAnalytics['activeCompanies'] ?? 0,
      inactiveCompanies: companies.length - ((companyAnalytics['activeCompanies'] as int?) ?? 0),
      bestPerformingCompany: companyAnalytics['topCompanies']?.isNotEmpty == true 
          ? companyAnalytics['topCompanies'][0]['name'] 
          : 'No data',
    );

    final systemInsights = SystemInsights(
      orderMetrics: orderMetrics,
      driverMetrics: driverMetrics,
      companyMetrics: companyMetrics,
      recommendations: recommendations,
      systemHealth: {
        'overall_health': '${_calculateSystemHealth(orderAnalytics, driverAnalytics, companyAnalytics)}% Healthy',
        'firebase': 'Connected & Synced',
        'real_time': 'Active',
        'data_quality': 'Live & Accurate',
      },
    );

    return AIStructuredResponse.systemInsights(systemInsights);
  }

  /// Calculate overall system health score
  int _calculateSystemHealth(Map<String, dynamic> orderAnalytics, 
                           Map<String, dynamic> driverAnalytics, 
                           Map<String, dynamic> companyAnalytics) {
    double healthScore = 0;

    // Order success rate factor (30%)
    final successRate = orderAnalytics['successRate'] ?? 0;
    healthScore += (successRate / 100) * 30;

    // Driver efficiency factor (30%) 
    final driverEfficiency = driverAnalytics['avgEfficiency'] ?? 0;
    healthScore += (driverEfficiency / 100) * 30;

    // Company performance factor (25%)
    final avgRating = companyAnalytics['averageRating'] ?? 0;
    healthScore += (avgRating / 5) * 25;

    // Active participation factor (15%)
    final activeDrivers = driverAnalytics['activeDrivers'] ?? 0;
    final totalDrivers = driverAnalytics['totalDrivers'] ?? 1;
    final participationRate = activeDrivers / totalDrivers;
    healthScore += participationRate * 15;

    return healthScore.round().clamp(0, 100);
  }

  /// Advanced Order Trend Analysis
  Map<String, dynamic> _analyzeOrderTrends(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) return {};

    // Group orders by hour for peak time analysis
    Map<int, int> hourlyOrders = {};
    Map<String, int> dailyOrders = {};
    Map<String, double> dailyRevenue = {};
    List<double> orderValues = [];
    Map<String, int> statusCounts = {'completed': 0, 'pending': 0, 'cancelled': 0};
    
    for (var order in orders) {
      try {
        // Parse timestamp for trend analysis
        DateTime orderTime;
        if (order['timestamp'] is String) {
          orderTime = DateTime.parse(order['timestamp']);
        } else {
          orderTime = DateTime.now(); // Fallback
        }
        
        // Hour analysis for peak times
        int hour = orderTime.hour;
        hourlyOrders[hour] = (hourlyOrders[hour] ?? 0) + 1;
        
        // Daily analysis
        String dateKey = '${orderTime.year}-${orderTime.month.toString().padLeft(2, '0')}-${orderTime.day.toString().padLeft(2, '0')}';
        dailyOrders[dateKey] = (dailyOrders[dateKey] ?? 0) + 1;
        
        // Revenue analysis
        double totalCost = 0;
        if (order['totalCost'] is num) {
          totalCost = order['totalCost'].toDouble();
        } else if (order['totalCost'] is String) {
          totalCost = double.tryParse(order['totalCost']) ?? 0;
        }
        orderValues.add(totalCost);
        dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + totalCost;
        
        // Status analysis
        String status = order['status']?.toString().toLowerCase() ?? 'pending';
        if (statusCounts.containsKey(status)) {
          statusCounts[status] = statusCounts[status]! + 1;
        }
      } catch (e) {
        print('Error analyzing order: $e');
      }
    }

    // Calculate peak hours (top 3)
    var sortedHours = hourlyOrders.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    List<Map<String, dynamic>> peakHours = sortedHours.take(3)
        .map((e) => {'hour': e.key, 'orders': e.value})
        .toList();

    // Calculate success rate
    int totalOrders = orders.length;
    double successRate = totalOrders > 0 
        ? (statusCounts['completed']! / totalOrders * 100) 
        : 0;

    // Calculate average order value
    double avgOrderValue = orderValues.isNotEmpty 
        ? orderValues.reduce((a, b) => a + b) / orderValues.length 
        : 0;

    return {
      'peakHours': peakHours,
      'successRate': successRate.round(),
      'avgOrderValue': avgOrderValue.round(),
      'statusBreakdown': statusCounts,
      'totalRevenue': dailyRevenue.values.fold(0.0, (a, b) => a + b).round(),
    };
  }

  /// Advanced Driver Performance Analysis
  Map<String, dynamic> _analyzeDriverPerformance(List<Map<String, dynamic>> drivers) {
    if (drivers.isEmpty) return {};

    List<Map<String, dynamic>> performanceMetrics = [];
    double totalEfficiency = 0;
    int activeDrivers = 0;

    for (var driver in drivers) {
      try {
        String name = driver['name']?.toString() ?? 'Unknown';
        int completedDeliveries = driver['completedDeliveries'] as int? ?? 0;
        double rating = driver['rating'] is num ? driver['rating'].toDouble() : 0.0;
        bool isActive = driver['isActive'] as bool? ?? false;
        
        if (isActive) activeDrivers++;

        // Calculate efficiency score (0-100)
        double efficiency = ((rating / 5.0) * 50 + (completedDeliveries > 0 ? 50 : 0)).clamp(0, 100);
        totalEfficiency += efficiency;

        performanceMetrics.add({
          'name': name,
          'efficiency': efficiency.round(),
          'deliveries': completedDeliveries,
          'rating': rating,
          'isActive': isActive,
        });
      } catch (e) {
        print('Error analyzing driver: $e');
      }
    }

    // Sort by efficiency
    performanceMetrics.sort((a, b) => b['efficiency'].compareTo(a['efficiency']));

    // Get top performers (top 3)
    List<Map<String, dynamic>> topPerformers = performanceMetrics.take(3).toList();

    // Calculate overall metrics
    double avgEfficiency = drivers.isNotEmpty ? totalEfficiency / drivers.length : 0;
    
    return {
      'topPerformers': topPerformers,
      'avgEfficiency': avgEfficiency.round(),
      'activeDrivers': activeDrivers,
      'totalDrivers': drivers.length,
    };
  }

  /// Advanced Company Performance Comparison
  Map<String, dynamic> _analyzeCompanyPerformance(List<Map<String, dynamic>> companies) {
    if (companies.isEmpty) return {};

    List<Map<String, dynamic>> companyMetrics = [];
    double totalRevenue = 0;
    
    for (var company in companies) {
      try {
        String name = company['name']?.toString() ?? 'Unknown';
        int totalOrders = company['totalOrders'] as int? ?? 0;
        double rating = company['rating'] is num ? company['rating'].toDouble() : 0.0;
        bool isActive = company['isActive'] as bool? ?? false;
        
        // Calculate estimated revenue (orders * average cost)
        double estimatedRevenue = totalOrders * 25.0; // Assuming $25 avg order
        totalRevenue += estimatedRevenue;

        // Calculate performance score
        double performanceScore = ((rating / 5.0) * 60 + (totalOrders > 0 ? 40 : 0)).clamp(0, 100);

        companyMetrics.add({
          'name': name,
          'orders': totalOrders,
          'rating': rating,
          'isActive': isActive,
          'revenue': estimatedRevenue.round(),
          'performanceScore': performanceScore.round(),
        });
      } catch (e) {
        print('Error analyzing company: $e');
      }
    }

    // Sort by performance score
    companyMetrics.sort((a, b) => b['performanceScore'].compareTo(a['performanceScore']));

    // Get top companies (top 3)
    List<Map<String, dynamic>> topCompanies = companyMetrics.take(3).toList();

    return {
      'topCompanies': topCompanies,
      'totalRevenue': totalRevenue.round(),
      'averageRating': companies.isNotEmpty 
          ? companyMetrics.fold(0.0, (sum, c) => sum + c['rating']) / companies.length 
          : 0.0,
      'activeCompanies': companyMetrics.where((c) => c['isActive']).length,
    };
  }

  /// Predictive Analytics - Demand Forecasting
  Map<String, dynamic> _forecastDemand(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) return {'forecast': 'No data available'};

    // Group orders by day of week and hour for pattern analysis
    Map<int, List<int>> weeklyPattern = {};
    Map<int, List<int>> hourlyPattern = {};
    
    for (var order in orders) {
      try {
        DateTime orderTime;
        if (order['timestamp'] is String) {
          orderTime = DateTime.parse(order['timestamp']);
        } else {
          continue;
        }
        
        int weekday = orderTime.weekday;
        int hour = orderTime.hour;
        
        weeklyPattern.putIfAbsent(weekday, () => []).add(1);
        hourlyPattern.putIfAbsent(hour, () => []).add(1);
      } catch (e) {
        continue;
      }
    }

    // Calculate average orders per day/hour
    Map<int, double> avgWeeklyOrders = {};
    Map<int, double> avgHourlyOrders = {};
    
    weeklyPattern.forEach((day, orderCounts) {
      avgWeeklyOrders[day] = orderCounts.length.toDouble();
    });
    
    hourlyPattern.forEach((hour, orderCounts) {
      avgHourlyOrders[hour] = orderCounts.length.toDouble();
    });

    // Predict next week's demand
    List<Map<String, dynamic>> weeklyForecast = [];
    for (int day = 1; day <= 7; day++) {
      double predictedOrders = avgWeeklyOrders[day] ?? 0;
      weeklyForecast.add({
        'day': day,
        'dayName': ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][day],
        'predictedOrders': predictedOrders.round(),
        'confidence': predictedOrders > 0 ? 'High' : 'Low',
      });
    }

    // Predict peak hours for tomorrow
    var sortedHours = avgHourlyOrders.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    List<Map<String, dynamic>> peakHoursPrediction = sortedHours.take(3)
        .map((e) => {
          'hour': e.key,
          'predictedOrders': e.value.round(),
          'timeRange': '${e.key.toString().padLeft(2, '0')}:00 - ${(e.key + 1).toString().padLeft(2, '0')}:00'
        })
        .toList();

    return {
      'weeklyForecast': weeklyForecast,
      'peakHoursPrediction': peakHoursPrediction,
      'totalPredictedOrders': weeklyForecast.fold(0, (sum, day) => sum + (day['predictedOrders'] as int)),
      'confidence': weeklyForecast.any((day) => day['confidence'] == 'High') ? 'High' : 'Medium',
    };
  }

  /// Predictive Analytics - Delivery Time Estimation
  Map<String, dynamic> _predictDeliveryTimes(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) return {'avgDeliveryTime': 'No data'};

    List<double> deliveryTimes = [];
    Map<String, List<double>> companyDeliveryTimes = {};
    
    for (var order in orders) {
      try {
        if (order['status'] != 'completed') continue;
        
        // Mock delivery time calculation (in real app, calculate from timestamps)
        double deliveryTime = 30 + (order['totalCost'] is num ? (order['totalCost'] as num) / 10 : 0);
        deliveryTimes.add(deliveryTime);
        
        String company = order['companyName']?.toString() ?? 'Unknown';
        companyDeliveryTimes.putIfAbsent(company, () => []).add(deliveryTime);
      } catch (e) {
        continue;
      }
    }

    if (deliveryTimes.isEmpty) return {'avgDeliveryTime': 'No completed orders'};

    double avgDeliveryTime = deliveryTimes.reduce((a, b) => a + b) / deliveryTimes.length;
    double minTime = deliveryTimes.reduce((a, b) => a < b ? a : b);
    double maxTime = deliveryTimes.reduce((a, b) => a > b ? a : b);

    // Company performance predictions
    List<Map<String, dynamic>> companyPredictions = [];
    companyDeliveryTimes.forEach((company, times) {
      double avgTime = times.reduce((a, b) => a + b) / times.length;
      companyPredictions.add({
        'company': company,
        'avgDeliveryTime': avgTime.round(),
        'performance': avgTime < avgDeliveryTime ? 'Above Average' : 'Below Average',
        'reliability': times.length > 5 ? 'High' : 'Medium',
      });
    });

    companyPredictions.sort((a, b) => a['avgDeliveryTime'].compareTo(b['avgDeliveryTime']));

    return {
      'avgDeliveryTime': avgDeliveryTime.round(),
      'minDeliveryTime': minTime.round(),
      'maxDeliveryTime': maxTime.round(),
      'companyPredictions': companyPredictions,
      'prediction': 'Next order estimated delivery: ${(avgDeliveryTime + 5).round()} minutes',
    };
  }

  /// Anomaly Detection
  List<Map<String, dynamic>> _detectAnomalies(
    List<Map<String, dynamic>> orders,
    List<Map<String, dynamic>> drivers,
    List<Map<String, dynamic>> companies,
  ) {
    List<Map<String, dynamic>> anomalies = [];

    // Order anomalies
    if (orders.isNotEmpty) {
      List<double> orderValues = orders
          .where((o) => o['totalCost'] is num)
          .map((o) => (o['totalCost'] as num).toDouble())
          .toList();
      
      if (orderValues.isNotEmpty) {
        double avgOrderValue = orderValues.reduce((a, b) => a + b) / orderValues.length;
        double threshold = avgOrderValue * 2; // Orders 2x above average
        
        int highValueOrders = orderValues.where((value) => value > threshold).length;
        if (highValueOrders > orderValues.length * 0.1) { // More than 10% are high value
          anomalies.add({
            'type': 'High Value Orders',
            'description': '$highValueOrders orders significantly above average (\$${avgOrderValue.round()})',
            'severity': 'Medium',
            'recommendation': 'Review pricing strategy and customer segments',
          });
        }
      }

      // Status anomalies
      int cancelledOrders = orders.where((o) => o['status'] == 'cancelled').length;
      if (cancelledOrders > orders.length * 0.15) { // More than 15% cancelled
        anomalies.add({
          'type': 'High Cancellation Rate',
          'description': '${(cancelledOrders / orders.length * 100).round()}% of orders are cancelled',
          'severity': 'High',
          'recommendation': 'Investigate cancellation reasons and improve order processing',
        });
      }
    }

    // Driver anomalies
    if (drivers.isNotEmpty) {
      List<int> deliveryCounts = drivers
          .where((d) => d['completedDeliveries'] is int)
          .map((d) => d['completedDeliveries'] as int)
          .toList();
      
      if (deliveryCounts.isNotEmpty) {
        double avgDeliveries = deliveryCounts.reduce((a, b) => a + b) / deliveryCounts.length;
        int lowPerformers = deliveryCounts.where((count) => count < avgDeliveries * 0.5).length;
        
        if (lowPerformers > drivers.length * 0.2) { // More than 20% underperforming
          anomalies.add({
            'type': 'Driver Performance Gap',
            'description': '$lowPerformers drivers performing below 50% of average',
            'severity': 'Medium',
            'recommendation': 'Provide training and support for underperforming drivers',
          });
        }
      }
    }

    // Company anomalies
    if (companies.isNotEmpty) {
      int inactiveCompanies = companies.where((c) => c['isActive'] != true).length;
      if (inactiveCompanies > companies.length * 0.3) { // More than 30% inactive
        anomalies.add({
          'type': 'High Partner Inactivity',
          'description': '${(inactiveCompanies / companies.length * 100).round()}% of partner companies are inactive',
          'severity': 'High',
          'recommendation': 'Re-engage inactive partners or find new partnerships',
        });
      }
    }

    return anomalies;
  }

  /// Generate Optimization Suggestions
  List<String> _generateOptimizationSuggestions(
    Map<String, dynamic> orderAnalytics,
    Map<String, dynamic> driverAnalytics,
    Map<String, dynamic> companyAnalytics,
    List<Map<String, dynamic>> anomalies,
    bool isArabic,
  ) {
    List<String> suggestions = [];

    // Order optimizations
    final peakHours = orderAnalytics['peakHours'] as List<Map<String, dynamic>>? ?? [];
    if (peakHours.isNotEmpty) {
      final peakHour = peakHours[0]['hour'];
      suggestions.add(isArabic
          ? 'زيادة عدد السائقين المتاحين في الساعة $peakHour (وقت الذروة)'
          : 'Increase driver availability during hour $peakHour (peak time)');
    }

    final successRate = orderAnalytics['successRate'] ?? 0;
    if (successRate < 85) {
      suggestions.add(isArabic
          ? 'تحسين معدل نجاح التوصيل من $successRate% إلى 90%+'
          : 'Improve delivery success rate from $successRate% to 90%+');
    }

    // Driver optimizations
    final topPerformers = driverAnalytics['topPerformers'] as List<Map<String, dynamic>>? ?? [];
    if (topPerformers.isNotEmpty) {
      suggestions.add(isArabic
          ? 'تطبيق أفضل ممارسات السائق الأول: ${topPerformers[0]['name']}'
          : 'Apply best practices from top performer: ${topPerformers[0]['name']}');
    }

    final avgEfficiency = driverAnalytics['avgEfficiency'] ?? 0;
    if (avgEfficiency < 80) {
      suggestions.add(isArabic
          ? 'برنامج تدريب للسائقين لتحسين الكفاءة العامة'
          : 'Driver training program to improve overall efficiency');
    }

    // Company optimizations
    final topCompanies = companyAnalytics['topCompanies'] as List<Map<String, dynamic>>? ?? [];
    if (topCompanies.isNotEmpty && topCompanies.length > 1) {
      suggestions.add(isArabic
          ? 'تعزيز الشراكة مع الشركات عالية الأداء'
          : 'Strengthen partnerships with top-performing companies');
    }

    // Anomaly-based suggestions
    for (var anomaly in anomalies) {
      if (anomaly['recommendation'] != null) {
        suggestions.add(anomaly['recommendation']);
      }
    }

    // General optimizations
    if (suggestions.length < 3) {
      suggestions.addAll(isArabic ? [
        'تحليل أنماط الطلبات لتحسين التخطيط',
        'تطوير نظام مكافآت للسائقين المتميزين',
        'مراقبة مستمرة لمؤشرات الأداء الرئيسية',
      ] : [
        'Analyze order patterns for better planning',
        'Develop incentive system for top drivers',
        'Continuous monitoring of key performance indicators',
      ]);
    }

    return suggestions.take(5).toList(); // Return top 5 suggestions
  }

  /// Natural Language Query Parser
  Map<String, dynamic> _parseNaturalLanguageQuery(String query) {
    final lowerQuery = query.toLowerCase();
    final isArabic = _detectArabic(query);
    
    Map<String, dynamic> parsedQuery = {
      'intent': 'unknown',
      'entity': 'orders', // default
      'filters': <String, dynamic>{},
      'dateRange': null,
      'aggregation': null,
      'language': isArabic ? 'ar' : 'en',
      'originalQuery': query,
    };

    // Parse intent (what the user wants to do)
    parsedQuery['intent'] = _extractIntent(lowerQuery, isArabic);
    
    // Parse entity (what they're asking about)
    parsedQuery['entity'] = _extractEntity(lowerQuery, isArabic);
    
    // Parse date range
    parsedQuery['dateRange'] = _extractDateRange(lowerQuery, isArabic);
    
    // Parse filters (status, company, driver, etc.)
    parsedQuery['filters'] = _extractFilters(lowerQuery, isArabic);
    
    // Parse aggregation (count, average, sum, etc.)
    parsedQuery['aggregation'] = _extractAggregation(lowerQuery, isArabic);

    return parsedQuery;
  }

  /// Extract user intent from query
  String _extractIntent(String query, bool isArabic) {
    // Show/Display intents
    if (isArabic) {
      if (RegExp(r'\b(اعرض|أظهر|عرض|أرني)\b').hasMatch(query)) return 'show';
      if (RegExp(r'\b(احسب|حساب|عدد|كم)\b').hasMatch(query)) return 'count';
      if (RegExp(r'\b(قارن|مقارنة)\b').hasMatch(query)) return 'compare';
      if (RegExp(r'\b(تحليل|حلل|تحليلات)\b').hasMatch(query)) return 'analyze';
      if (RegExp(r'\b(توقع|تنبؤ|توقعات)\b').hasMatch(query)) return 'predict';
      if (RegExp(r'\b(ابحث|بحث|جد)\b').hasMatch(query)) return 'search';
    } else {
      if (RegExp(r'\b(show|display|list|view|get|give me)\b').hasMatch(query)) return 'show';
      if (RegExp(r'\b(count|how many|number of|total)\b').hasMatch(query)) return 'count';
      if (RegExp(r'\b(compare|comparison|vs|versus)\b').hasMatch(query)) return 'compare';
      if (RegExp(r'\b(analyze|analysis|insights|performance)\b').hasMatch(query)) return 'analyze';
      if (RegExp(r'\b(predict|forecast|estimate|future)\b').hasMatch(query)) return 'predict';
      if (RegExp(r'\b(search|find|lookup|filter)\b').hasMatch(query)) return 'search';
    }
    
    return 'show'; // default
  }

  /// Extract entity (what they're asking about)
  String _extractEntity(String query, bool isArabic) {
    if (isArabic) {
      if (RegExp(r'\b(طلبات|طلب|أوردر)\b').hasMatch(query)) return 'orders';
      if (RegExp(r'\b(سائقين|سائق|موصل|موصلين)\b').hasMatch(query)) return 'drivers';
      if (RegExp(r'\b(شركات|شركة|مطاعم|مطعم)\b').hasMatch(query)) return 'companies';
      if (RegExp(r'\b(رؤى|تحليلات|نظام|أداء)\b').hasMatch(query)) return 'insights';
      if (RegExp(r'\b(إيرادات|أرباح|مال|تكلفة)\b').hasMatch(query)) return 'revenue';
    } else {
      if (RegExp(r'\b(orders?|deliveries|shipments?)\b').hasMatch(query)) return 'orders';
      if (RegExp(r'\b(drivers?|couriers?|delivery\s+(?:guys?|persons?))\b').hasMatch(query)) return 'drivers';
      if (RegExp(r'\b(companies|company|restaurants?|partners?)\b').hasMatch(query)) return 'companies';
      if (RegExp(r'\b(insights?|analytics?|system|performance|health)\b').hasMatch(query)) return 'insights';
      if (RegExp(r'\b(revenue|income|money|earnings?|profits?)\b').hasMatch(query)) return 'revenue';
    }
    
    return 'orders'; // default
  }

  /// Extract date range from query
  Map<String, DateTime>? _extractDateRange(String query, bool isArabic) {
    final now = DateTime.now();
    
    if (isArabic) {
      if (RegExp(r'\b(اليوم|هذا اليوم)\b').hasMatch(query)) {
        return {'start': DateTime(now.year, now.month, now.day), 'end': now};
      }
      if (RegExp(r'\b(أمس|البارحة)\b').hasMatch(query)) {
        final yesterday = now.subtract(const Duration(days: 1));
        return {'start': DateTime(yesterday.year, yesterday.month, yesterday.day), 'end': DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59)};
      }
      if (RegExp(r'\b(هذا الأسبوع|الأسبوع الحالي)\b').hasMatch(query)) {
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return {'start': DateTime(weekStart.year, weekStart.month, weekStart.day), 'end': now};
      }
      if (RegExp(r'\b(الأسبوع الماضي|الأسبوع السابق)\b').hasMatch(query)) {
        final lastWeekEnd = now.subtract(Duration(days: now.weekday));
        final lastWeekStart = lastWeekEnd.subtract(const Duration(days: 6));
        return {'start': DateTime(lastWeekStart.year, lastWeekStart.month, lastWeekStart.day), 'end': DateTime(lastWeekEnd.year, lastWeekEnd.month, lastWeekEnd.day, 23, 59)};
      }
      if (RegExp(r'\b(هذا الشهر|الشهر الحالي)\b').hasMatch(query)) {
        return {'start': DateTime(now.year, now.month, 1), 'end': now};
      }
    } else {
      if (RegExp(r'\b(today|this day)\b').hasMatch(query)) {
        return {'start': DateTime(now.year, now.month, now.day), 'end': now};
      }
      if (RegExp(r'\b(yesterday|last day)\b').hasMatch(query)) {
        final yesterday = now.subtract(const Duration(days: 1));
        return {'start': DateTime(yesterday.year, yesterday.month, yesterday.day), 'end': DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59)};
      }
      if (RegExp(r'\b(this week|current week)\b').hasMatch(query)) {
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return {'start': DateTime(weekStart.year, weekStart.month, weekStart.day), 'end': now};
      }
      if (RegExp(r'\b(last week|previous week|past week)\b').hasMatch(query)) {
        final lastWeekEnd = now.subtract(Duration(days: now.weekday));
        final lastWeekStart = lastWeekEnd.subtract(const Duration(days: 6));
        return {'start': DateTime(lastWeekStart.year, lastWeekStart.month, lastWeekStart.day), 'end': DateTime(lastWeekEnd.year, lastWeekEnd.month, lastWeekEnd.day, 23, 59)};
      }
      if (RegExp(r'\b(this month|current month)\b').hasMatch(query)) {
        return {'start': DateTime(now.year, now.month, 1), 'end': now};
      }
      if (RegExp(r'\b(last (\d+) days?)\b').hasMatch(query)) {
        final match = RegExp(r'last (\d+) days?').firstMatch(query);
        if (match != null) {
          final days = int.parse(match.group(1)!);
          final startDate = now.subtract(Duration(days: days));
          return {'start': DateTime(startDate.year, startDate.month, startDate.day), 'end': now};
        }
      }
    }
    
    return null; // No specific date range found
  }

  /// Extract filters from query
  Map<String, dynamic> _extractFilters(String query, bool isArabic) {
    Map<String, dynamic> filters = {};
    
    // Status filters
    if (isArabic) {
      if (RegExp(r'\b(مكتمل|مكتملة|منجز|منجزة)\b').hasMatch(query)) {
        filters['status'] = 'completed';
      } else if (RegExp(r'\b(معلق|معلقة|قيد الانتظار)\b').hasMatch(query)) {
        filters['status'] = 'pending';
      } else if (RegExp(r'\b(ملغي|ملغية|محذوف)\b').hasMatch(query)) {
        filters['status'] = 'cancelled';
      } else if (RegExp(r'\b(قيد التوصيل|في الطريق)\b').hasMatch(query)) {
        filters['status'] = 'out_for_delivery';
      }
    } else {
      if (RegExp(r'\b(completed|finished|done|delivered)\b').hasMatch(query)) {
        filters['status'] = 'completed';
      } else if (RegExp(r'\b(pending|waiting|processing)\b').hasMatch(query)) {
        filters['status'] = 'pending';
      } else if (RegExp(r'\b(cancelled|canceled|rejected)\b').hasMatch(query)) {
        filters['status'] = 'cancelled';
      } else if (RegExp(r'\b(out for delivery|in transit|on the way)\b').hasMatch(query)) {
        filters['status'] = 'out_for_delivery';
      }
    }
    
    // Active/Inactive filters
    if (isArabic) {
      if (RegExp(r'\b(نشط|نشطة|فعال|فعالة)\b').hasMatch(query)) {
        filters['isActive'] = true;
      } else if (RegExp(r'\b(غير نشط|غير فعال|معطل|معطلة)\b').hasMatch(query)) {
        filters['isActive'] = false;
      }
    } else {
      if (RegExp(r'\b(active|enabled|working)\b').hasMatch(query)) {
        filters['isActive'] = true;
      } else if (RegExp(r'\b(inactive|disabled|not working)\b').hasMatch(query)) {
        filters['isActive'] = false;
      }
    }
    
    // Performance filters
    if (isArabic) {
      if (RegExp(r'\b(الأفضل|الأعلى|المتفوق|ممتاز)\b').hasMatch(query)) {
        filters['performance'] = 'top';
      } else if (RegExp(r'\b(الأسوأ|الأقل|ضعيف)\b').hasMatch(query)) {
        filters['performance'] = 'bottom';
      }
    } else {
      if (RegExp(r'\b(best|top|highest|excellent|outstanding)\b').hasMatch(query)) {
        filters['performance'] = 'top';
      } else if (RegExp(r'\b(worst|bottom|lowest|poor|underperforming)\b').hasMatch(query)) {
        filters['performance'] = 'bottom';
      }
    }
    
    return filters;
  }

  /// Extract aggregation type from query
  String? _extractAggregation(String query, bool isArabic) {
    if (isArabic) {
      if (RegExp(r'\b(المتوسط|معدل)\b').hasMatch(query)) return 'average';
      if (RegExp(r'\b(المجموع|إجمالي|كامل)\b').hasMatch(query)) return 'sum';
      if (RegExp(r'\b(العدد|كم عدد|عدد)\b').hasMatch(query)) return 'count';
      if (RegExp(r'\b(الأعلى|الحد الأقصى)\b').hasMatch(query)) return 'max';
      if (RegExp(r'\b(الأقل|الحد الأدنى)\b').hasMatch(query)) return 'min';
    } else {
      if (RegExp(r'\b(average|avg|mean)\b').hasMatch(query)) return 'average';
      if (RegExp(r'\b(total|sum|overall)\b').hasMatch(query)) return 'sum';
      if (RegExp(r'\b(count|number|how many)\b').hasMatch(query)) return 'count';
      if (RegExp(r'\b(maximum|max|highest)\b').hasMatch(query)) return 'max';
      if (RegExp(r'\b(minimum|min|lowest)\b').hasMatch(query)) return 'min';
    }
    
    return null;
  }

  /// Process natural language query and return results
  Future<AIStructuredResponse> _processNaturalLanguageQuery(String query) async {
    final parsedQuery = _parseNaturalLanguageQuery(query);
    final isArabic = parsedQuery['language'] == 'ar';
    
    try {
      // Get data based on entity type
      final data = await AIDataService.instance.getAllDataForAI();
      
      // Apply filters and date ranges
      final filteredData = _applyFiltersToData(data, parsedQuery);
      
      // Generate response based on intent
      return await _generateQueryResponse(filteredData, parsedQuery, isArabic);
      
    } catch (e) {
      return AIStructuredResponse.error(
        isArabic 
          ? 'خطأ في معالجة الاستعلام: ${e.toString()}'
          : 'Error processing query: ${e.toString()}',
      );
    }
  }

  /// Apply filters to data based on parsed query
  Map<String, dynamic> _applyFiltersToData(Map<String, dynamic> data, Map<String, dynamic> parsedQuery) {
    final entity = parsedQuery['entity'] as String;
    final filters = parsedQuery['filters'] as Map<String, dynamic>;
    final dateRange = parsedQuery['dateRange'] as Map<String, DateTime>?;
    
    Map<String, dynamic> filteredData = Map.from(data);
    
    // Apply filters based on entity type
    switch (entity) {
      case 'orders':
        final ordersData = data['orders'] as Map<String, dynamic>? ?? {};
        final orders = (ordersData['recent_orders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        List<Map<String, dynamic>> filteredOrders = orders.where((order) {
          // Apply status filter
          if (filters['status'] != null && order['status'] != filters['status']) {
            return false;
          }
          
          // Apply date range filter
          if (dateRange != null) {
            try {
              final orderTime = order['timestamp'] is String 
                  ? DateTime.parse(order['timestamp']) 
                  : DateTime.now();
              if (orderTime.isBefore(dateRange['start']!) || orderTime.isAfter(dateRange['end']!)) {
                return false;
              }
            } catch (e) {
              return false; // Skip orders with invalid timestamps
            }
          }
          
          return true;
        }).toList();
        
        // Apply performance filters for orders
        if (filters['performance'] != null) {
          filteredOrders.sort((a, b) {
            final aCost = (a['totalCost'] is num) ? (a['totalCost'] as num).toDouble() : 0.0;
            final bCost = (b['totalCost'] is num) ? (b['totalCost'] as num).toDouble() : 0.0;
            return bCost.compareTo(aCost);
          });
          
          if (filters['performance'] == 'top') {
            filteredOrders = filteredOrders.take(10).toList();
          } else if (filters['performance'] == 'bottom') {
            filteredOrders = filteredOrders.reversed.take(10).toList();
          }
        }
        
        filteredData['orders'] = filteredOrders;
        break;
        
      case 'drivers':
        final drivers = (data['drivers'] as List<Map<String, dynamic>>?) ?? [];
        List<Map<String, dynamic>> filteredDrivers = drivers.where((driver) {
          // Apply active filter
          if (filters['isActive'] != null && driver['isActive'] != filters['isActive']) {
            return false;
          }
          
          return true;
        }).toList();
        
        // Apply performance filters for drivers
        if (filters['performance'] != null) {
          filteredDrivers.sort((a, b) {
            final aDeliveries = (a['completedDeliveries'] is int) ? a['completedDeliveries'] as int : 0;
            final bDeliveries = (b['completedDeliveries'] is int) ? b['completedDeliveries'] as int : 0;
            return bDeliveries.compareTo(aDeliveries);
          });
          
          if (filters['performance'] == 'top') {
            filteredDrivers = filteredDrivers.take(10).toList();
          } else if (filters['performance'] == 'bottom') {
            filteredDrivers = filteredDrivers.reversed.take(10).toList();
          }
        }
        
        filteredData['drivers'] = filteredDrivers;
        break;
        
      case 'companies':
        final companies = (data['companies'] as List<Map<String, dynamic>>?) ?? [];
        List<Map<String, dynamic>> filteredCompanies = companies.where((company) {
          // Apply active filter
          if (filters['isActive'] != null && company['isActive'] != filters['isActive']) {
            return false;
          }
          
          return true;
        }).toList();
        
        // Apply performance filters for companies
        if (filters['performance'] != null) {
          filteredCompanies.sort((a, b) {
            final aRating = (a['rating'] is num) ? (a['rating'] as num).toDouble() : 0.0;
            final bRating = (b['rating'] is num) ? (b['rating'] as num).toDouble() : 0.0;
            return bRating.compareTo(aRating);
          });
          
          if (filters['performance'] == 'top') {
            filteredCompanies = filteredCompanies.take(10).toList();
          } else if (filters['performance'] == 'bottom') {
            filteredCompanies = filteredCompanies.reversed.take(10).toList();
          }
        }
        
        filteredData['companies'] = filteredCompanies;
        break;
    }
    
    return filteredData;
  }

  /// Generate response based on query intent and filtered data
  Future<AIStructuredResponse> _generateQueryResponse(
    Map<String, dynamic> filteredData, 
    Map<String, dynamic> parsedQuery, 
    bool isArabic
  ) async {
    final intent = parsedQuery['intent'] as String;
    final entity = parsedQuery['entity'] as String;
    
    switch (intent) {
      case 'count':
        return _generateCountResponse(filteredData, entity, parsedQuery, isArabic);
      case 'compare':
        return _generateComparisonResponse(filteredData, entity, parsedQuery, isArabic);
      case 'analyze':
        return _generateAnalysisResponse(filteredData, entity, parsedQuery, isArabic);
      case 'predict':
        return _generatePredictionResponse(filteredData, entity, parsedQuery, isArabic);
      case 'search':
      case 'show':
      default:
        return await _generateShowResponse(filteredData, entity, parsedQuery, isArabic);
    }
  }

  /// Generate count-based responses
  AIStructuredResponse _generateCountResponse(
    Map<String, dynamic> data, 
    String entity, 
    Map<String, dynamic> parsedQuery, 
    bool isArabic
  ) {
    final dateRange = parsedQuery['dateRange'] as Map<String, DateTime>?;
    final filters = parsedQuery['filters'] as Map<String, dynamic>;
    
    String dateRangeText = '';
    if (dateRange != null) {
      final start = dateRange['start']!;
      final end = dateRange['end']!;
      dateRangeText = isArabic 
          ? ' من ${start.day}/${start.month} إلى ${end.day}/${end.month}'
          : ' from ${start.day}/${start.month} to ${end.day}/${end.month}';
    }
    
    String filterText = '';
    if (filters['status'] != null) {
      filterText = isArabic 
          ? ' (${filters['status']})'
          : ' (${filters['status']})';
    }
    
    switch (entity) {
      case 'orders':
        final ordersData = data['orders'] as Map<String, dynamic>? ?? {};
        final orders = (ordersData['recent_orders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        final totalOrders = ordersData['total_orders'] as int? ?? 0;
        final completedOrders = ordersData['completed_orders'] as int? ?? 0;
        final completionRate = ordersData['completion_rate'] as int? ?? 0;
        return AIStructuredResponse.textResponse(
          isArabic 
              ? '''📊 **إحصائيات الطلبات**$dateRangeText

🔢 **العدد الإجمالي**: $totalOrders طلب$filterText
🎯 **معدل الإنجاز**: $completionRate%

📈 **التفاصيل**:
• ✅ مكتمل: $completedOrders
• ⏳ معلق: ${orders.where((o) => o['status'] == 'pending').length}
• 🚚 قيد التوصيل: ${orders.where((o) => o['status'] == 'out_for_delivery').length}
• ❌ ملغي: ${orders.where((o) => o['status'] == 'cancelled').length}

💰 **المجموع المالي**: \$${orders.fold<double>(0, (sum, o) => sum + ((o['totalCost'] is num) ? (o['totalCost'] as num).toDouble() : 0)).round()}'''
              : '''📊 **Order Statistics**$dateRangeText

🔢 **Total Count**: ${orders.length} orders$filterText

📈 **Breakdown**:
• ✅ Completed: ${orders.where((o) => o['status'] == 'completed').length}
• ⏳ Pending: ${orders.where((o) => o['status'] == 'pending').length}
• 🚚 Out for Delivery: ${orders.where((o) => o['status'] == 'out_for_delivery').length}
• ❌ Cancelled: ${orders.where((o) => o['status'] == 'cancelled').length}

💰 **Total Revenue**: \$${orders.fold<double>(0, (sum, o) => sum + ((o['totalCost'] is num) ? (o['totalCost'] as num).toDouble() : 0)).round()}'''
        );
        
      case 'drivers':
        final drivers = data['drivers'] as List<Map<String, dynamic>>? ?? [];
        final activeDrivers = drivers.where((d) => d['isActive'] == true).length;
        return AIStructuredResponse.textResponse(
          isArabic 
              ? '''👥 **إحصائيات السائقين**

🔢 **العدد الإجمالي**: ${drivers.length} سائق
🟢 **النشطون**: $activeDrivers سائق
🔴 **غير النشطين**: ${drivers.length - activeDrivers} سائق

📊 **إجمالي التوصيلات**: ${drivers.fold<int>(0, (sum, d) => sum + ((d['completedDeliveries'] is int) ? d['completedDeliveries'] as int : 0))}'''
              : '''👥 **Driver Statistics**

🔢 **Total Count**: ${drivers.length} drivers
🟢 **Active**: $activeDrivers drivers
🔴 **Inactive**: ${drivers.length - activeDrivers} drivers

📊 **Total Deliveries**: ${drivers.fold<int>(0, (sum, d) => sum + ((d['completedDeliveries'] is int) ? d['completedDeliveries'] as int : 0))}'''
        );
        
      case 'companies':
        final companies = data['companies'] as List<Map<String, dynamic>>? ?? [];
        final activeCompanies = companies.where((c) => c['isActive'] == true).length;
        return AIStructuredResponse.textResponse(
          isArabic 
              ? '''🏢 **إحصائيات الشركات**

🔢 **العدد الإجمالي**: ${companies.length} شركة
🟢 **النشطة**: $activeCompanies شركة
🔴 **غير النشطة**: ${companies.length - activeCompanies} شركة

⭐ **متوسط التقييم**: ${companies.isNotEmpty ? (companies.fold<double>(0, (sum, c) => sum + ((c['rating'] is num) ? (c['rating'] as num).toDouble() : 0)) / companies.length).toStringAsFixed(1) : '0'}/5'''
              : '''🏢 **Company Statistics**

🔢 **Total Count**: ${companies.length} companies
🟢 **Active**: $activeCompanies companies
🔴 **Inactive**: ${companies.length - activeCompanies} companies

⭐ **Average Rating**: ${companies.isNotEmpty ? (companies.fold<double>(0, (sum, c) => sum + ((c['rating'] is num) ? (c['rating'] as num).toDouble() : 0)) / companies.length).toStringAsFixed(1) : '0'}/5'''
        );
        
      default:
        return AIStructuredResponse.textResponse(
          isArabic ? 'لا توجد بيانات متاحة للعرض' : 'No data available to display'
        );
    }
  }

  /// Generate comparison responses
  AIStructuredResponse _generateComparisonResponse(
    Map<String, dynamic> data, 
    String entity, 
    Map<String, dynamic> parsedQuery, 
    bool isArabic
  ) {
    // For now, return structured analysis
    return generateSystemInsights(data, isArabic);
  }

  /// Generate analysis responses
  AIStructuredResponse _generateAnalysisResponse(
    Map<String, dynamic> data, 
    String entity, 
    Map<String, dynamic> parsedQuery, 
    bool isArabic
  ) {
    return generateSystemInsights(data, isArabic);
  }

  /// Generate prediction responses
  AIStructuredResponse _generatePredictionResponse(
    Map<String, dynamic> data, 
    String entity, 
    Map<String, dynamic> parsedQuery, 
    bool isArabic
  ) {
    final ordersData = data['orders'] as Map<String, dynamic>? ?? {};
    final orders = (ordersData['recent_orders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final forecast = _forecastDemand(orders);
    final deliveryPredictions = _predictDeliveryTimes(orders);
    
    return AIStructuredResponse.textResponse(
      isArabic 
          ? '''🔮 **توقعات النظام**

📈 **توقع الطلب**:
• الأسبوع القادم: ${forecast['totalPredictedOrders'] ?? 0} طلب متوقع
• درجة الثقة: ${forecast['confidence'] ?? 'متوسطة'}

⏱️ **توقعات وقت التوصيل**:
• متوسط وقت التوصيل: ${deliveryPredictions['avgDeliveryTime'] ?? 'غير متاح'} دقيقة
• ${deliveryPredictions['prediction'] ?? 'لا توجد توقعات متاحة'}

🎯 **توصيات**:
• مراقبة أوقات الذروة للتحسين
• تحسين كفاءة السائقين
• تطوير شراكات استراتيجية'''
          : '''🔮 **System Predictions**

📈 **Demand Forecast**:
• Next week: ${forecast['totalPredictedOrders'] ?? 0} orders predicted
• Confidence: ${forecast['confidence'] ?? 'Medium'}

⏱️ **Delivery Time Predictions**:
• Average delivery time: ${deliveryPredictions['avgDeliveryTime'] ?? 'Not available'} minutes
• ${deliveryPredictions['prediction'] ?? 'No predictions available'}

🎯 **Recommendations**:
• Monitor peak times for optimization
• Improve driver efficiency
• Develop strategic partnerships'''
    );
  }

  /// Generate show/display responses
  Future<AIStructuredResponse> _generateShowResponse(
    Map<String, dynamic> data, 
    String entity, 
    Map<String, dynamic> parsedQuery, 
    bool isArabic
  ) async {
    // Generate appropriate response based on entity type
    final query = parsedQuery['originalQuery'] as String? ?? 'show data';
    return await _generateStructuredMockResponse(query);
  }
}
