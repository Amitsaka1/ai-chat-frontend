import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../data/chat_service.dart';

class ChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final String? conversationId;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.conversationId,
    this.error,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    String? conversationId,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      conversationId: conversationId ?? this.conversationId,
      error: error ?? this.error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState());

  Future<void> sendMessage(String message) async {
    // User message add karo
    final userMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: message,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final response = await ChatService.sendMessage(
        message: message,
        conversationId: state.conversationId,
      );

      final aiMessage = MessageModel.fromJson(response['message']);

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
        conversationId: response['conversationId'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  void clearChat() {
    state = ChatState();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
