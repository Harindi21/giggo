import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/assistant_repository.dart';
import '../../data/models/assistant_models.dart';

/// One turn in the assistant chat: either the customer's question or the
/// assistant's reply (which may be grounded with citations, a refusal, or an
/// error). While a reply is in flight it is shown as a pending placeholder.
class ChatMessage {
  final bool fromUser;
  final String text;
  final List<AssistantCitation> citations;
  final bool grounded;
  final bool pending;

  const ChatMessage({
    required this.fromUser,
    required this.text,
    this.citations = const [],
    this.grounded = true,
    this.pending = false,
  });
}

class AssistantChatState {
  final List<ChatMessage> messages;
  final bool busy;

  const AssistantChatState({this.messages = const [], this.busy = false});

  AssistantChatState copyWith({List<ChatMessage>? messages, bool? busy}) {
    return AssistantChatState(
      messages: messages ?? this.messages,
      busy: busy ?? this.busy,
    );
  }
}

class AssistantChatNotifier extends Notifier<AssistantChatState> {
  late final AssistantRepository _repo;

  @override
  AssistantChatState build() {
    _repo = ref.watch(assistantRepositoryProvider);
    return const AssistantChatState();
  }

  Future<void> ask(String question) async {
    final q = question.trim();
    if (q.isEmpty || state.busy) return;

    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(fromUser: true, text: q),
        const ChatMessage(fromUser: false, text: '', pending: true),
      ],
      busy: true,
    );

    try {
      final answer = await _repo.ask(q);
      _replacePending(
        ChatMessage(
          fromUser: false,
          text: answer.answer,
          citations: answer.citations,
          grounded: answer.grounded,
        ),
      );
    } catch (e) {
      _replacePending(
        ChatMessage(fromUser: false, text: e.toString(), grounded: false),
      );
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  void _replacePending(ChatMessage msg) {
    final msgs = [...state.messages];
    final idx = msgs.lastIndexWhere((m) => m.pending);
    if (idx >= 0) {
      msgs[idx] = msg;
    } else {
      msgs.add(msg);
    }
    state = state.copyWith(messages: msgs);
  }
}

final assistantChatProvider =
    NotifierProvider<AssistantChatNotifier, AssistantChatState>(
      AssistantChatNotifier.new,
    );
