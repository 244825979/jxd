import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiUrl = 'https://api.deepseek.com/chat/completions';
  static const String _apiKey = 'sk-baa41b59556440d9b82e4e185033db16';
  
  static Future<String> getChatResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': '你是一位专业、温暖、富有同理心的心理健康助手。你的名字是"心灵伙伴"。你的任务是：\n'
                  '1. 以温和、理解的语气与用户交流\n'
                  '2. 提供情感支持和积极的建议\n'
                  '3. 鼓励用户表达自己的感受\n'
                  '4. 在适当时候给出实用的心理健康建议\n'
                  '5. 如果用户表现出严重心理问题，建议寻求专业帮助\n'
                  '6. 保持对话轻松、温暖，避免过于正式或生硬\n'
                  '7. 回复长度适中，不要太长也不要太短\n'
                  '请用中文回复，语气亲切自然。'
            },
            {
              'role': 'user',
              'content': userMessage,
            }
          ],
          'stream': false,
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return content?.toString().trim() ?? '抱歉，我现在无法回复，请稍后再试。';
      } else {
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      return _getFallbackResponse(userMessage);
    }
  }

  // 网络错误时的备用回复
  static String _getFallbackResponse(String userMessage) {
    final fallbackResponses = [
      '我能感受到你的情感，谢谢你与我分享。每个人都会有起伏，这是很正常的。',
      '听起来你现在有很多感受。我想让你知道，无论什么情绪都是有价值的，都值得被听见。',
      '你愿意和我分享你的想法，这很棒。有时候表达出来就已经是很大的进步了。',
      '我理解你现在的感受。请记住，你并不孤单，每一天都是新的开始。',
      '感谢你信任我，与我分享这些。你的感受是真实和重要的。',
    ];
    
    // 简单根据消息长度选择回复
    final index = userMessage.length % fallbackResponses.length;
    return fallbackResponses[index];
  }
} 