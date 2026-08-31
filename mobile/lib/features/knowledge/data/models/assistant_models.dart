/// A source guide the assistant's answer was grounded in (RAG-05).
class AssistantCitation {
  final String slug;
  final String title;

  const AssistantCitation({required this.slug, required this.title});

  factory AssistantCitation.fromJson(Map<String, dynamic> json) {
    return AssistantCitation(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );
  }
}

/// The Knowledge assistant's reply: a grounded answer with citations, or a
/// polite refusal when the question is outside the Knowledge Hub (grounded=false).
class AssistantAnswer {
  final String answer;
  final bool grounded;
  final List<AssistantCitation> citations;
  final String backend;

  const AssistantAnswer({
    required this.answer,
    required this.grounded,
    required this.citations,
    required this.backend,
  });

  factory AssistantAnswer.fromJson(Map<String, dynamic> json) {
    final cites = (json['citations'] as List<dynamic>? ?? const [])
        .map((e) => AssistantCitation.fromJson(e as Map<String, dynamic>))
        .toList();
    return AssistantAnswer(
      answer: json['answer'] as String? ?? '',
      grounded: json['grounded'] as bool? ?? false,
      citations: cites,
      backend: json['backend'] as String? ?? '',
    );
  }
}
