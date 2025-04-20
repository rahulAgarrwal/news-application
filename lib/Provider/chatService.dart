// api/chat_api.dart
import 'package:dart_openai/dart_openai.dart';
import 'package:newsapp2/Models/chat_message.dart';

class ChatApi {
  static const _model = 'gpt-3.5-turbo';

  ChatApi() {
    OpenAI.apiKey = "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";
  }

  Future<String> completeChat(List<ChatMessage> messages) async {
    final chatCompletion = await OpenAI.instance.chat.create(
      model: _model,
      messages: messages
          .map((e) => OpenAIChatCompletionChoiceMessageModel(
                role: e.isUserMessage ?OpenAIChatMessageRole.user:OpenAIChatMessageRole.assistant,
                content: e.content,
              ))
          .toList(),
    );
    print(chatCompletion.choices.first.message.content);
    return chatCompletion.choices.first.message.content;
  }
}
