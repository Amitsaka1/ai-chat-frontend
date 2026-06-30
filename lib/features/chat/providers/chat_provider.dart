import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../data/chat_service.dart';
import '../../cards/models/story_card_model.dart';

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
  final StoryCardModel storyCard;

  ChatNotifier(this.storyCard) : super(ChatState()) {
    _startConversation();
  }

  Future<void> _startConversation() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await ChatService.sendMessage(
        message: '__START__',
        isStart: true,
        cardId: storyCard.id,
        systemPrompt: storyCard.systemPrompt,
      );
      final aiMessage = MessageModel.fromJson(response['message']);
      state = state.copyWith(
        messages: [aiMessage],
        isLoading: false,
        conversationId: response['conversationId'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'something went wrong');
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
        cardId: storyCard.id,
        systemPrompt: storyCard.systemPrompt,
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
}

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, StoryCardModel>(
  (ref, storyCard) => ChatNotifier(storyCard),
);
