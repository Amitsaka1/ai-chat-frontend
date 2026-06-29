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
  ChatNotifier() : super(ChatState()) {
    _startConversation();
  }

  Future<void> _startConversation() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await ChatService.sendMessage(
        message: '__START__',
        isStart: true,
      );
      final aiMessage = MessageModel.fromJson(response['message']);
      state = state.copyWith(
        messages: [aiMessage],
        isLoading: false,
        conversationId: response['conversationId'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendMessage(String message) async {
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
        error: 'something went wrong try again',
      );
    }
  }

  void clearChat() {
    state = ChatState();
    _startConversation();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
