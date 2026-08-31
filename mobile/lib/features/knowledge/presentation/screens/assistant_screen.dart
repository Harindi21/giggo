import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/assistant_providers.dart';

/// Knowledge Hub assistant chat (RAG-05): ask a question in plain language and
/// get a grounded answer with citations to the source guides. It refuses
/// politely when the answer is not in the Knowledge Hub.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  static const _suggestions = [
    'How does escrow payment work?',
    'How do I get verified as a provider?',
    'How is my rating calculated?',
    'How does live tracking work?',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final q = (preset ?? _ctrl.text).trim();
    if (q.isEmpty) return;
    _ctrl.clear();
    ref.read(assistantChatProvider.notifier).ask(q);
    FocusScope.of(context).unfocus();
  }

  void _toBottom() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantChatProvider);
    ref.listen(assistantChatProvider, (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _toBottom());
    });
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: state.messages.isEmpty
                ? _empty()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                    itemCount: state.messages.length,
                    itemBuilder: (_, i) => _bubble(state.messages[i]),
                  ),
          ),
          _composer(state.busy),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Knowledge Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Answers from the Knowledge Hub, with sources',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.auto_awesome, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
      children: [
        const Icon(Icons.forum_outlined, size: 52, color: AppColors.accent),
        const SizedBox(height: 14),
        const Text(
          'Ask about bookings, payments, safety, or getting verified.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Every answer is grounded in the Knowledge Hub guides and links back '
          'to its sources. If it is not covered there, the assistant will say so '
          'rather than guess.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in _suggestions)
              ActionChip(
                label: Text(s),
                onPressed: () => _send(s),
                backgroundColor: AppColors.surfaceBlue.withValues(alpha: 0.5),
                labelStyle: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide.none,
              ),
          ],
        ),
      ],
    );
  }

  Widget _bubble(ChatMessage m) {
    if (m.fromUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          child: Text(
            m.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ),
      );
    }

    if (m.pending) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(bottom: 14, top: 2, left: 4),
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }

    final refusal = !m.grounded;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 32),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: refusal
              ? AppColors.background
              : AppColors.surfaceBlue.withValues(alpha: 0.55),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: refusal ? Border.all(color: AppColors.border) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  refusal ? Icons.info_outline : Icons.auto_awesome,
                  size: 16,
                  color: refusal ? AppColors.textMuted : AppColors.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    m.text,
                    style: const TextStyle(
                      color: AppColors.textBody,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            if (m.citations.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'SOURCES',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in m.citations)
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/articles/${c.slug}'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.menu_book_outlined,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                c.title,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _composer(bool busy) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'Ask a question…',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: busy ? AppColors.border : AppColors.accent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: busy ? null : () => _send(),
                child: const Padding(
                  padding: EdgeInsets.all(11),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
