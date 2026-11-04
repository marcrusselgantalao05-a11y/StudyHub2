import 'package:flutter/material.dart';

import '../models/study_models.dart';
import '../state/app_state.dart';
import '../widgets/app_widgets.dart';

class FlashcardsPage extends StatefulWidget {
  const FlashcardsPage({required this.appState, super.key});

  final AppState appState;

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  Future<void> _addFlashcard() async {
    var question = '';
    var answer = '';

    final details = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add a flashcard'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormFieldInput(
                label: 'Question',
                maxLines: 3,
                onChanged: (value) => question = value,
              ),
              const SizedBox(height: 12),
              FormFieldInput(
                label: 'Answer',
                maxLines: 3,
                onChanged: (value) => answer = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final cardQuestion = question.trim();
              final cardAnswer = answer.trim();
              if (cardQuestion.isNotEmpty && cardAnswer.isNotEmpty) {
                Navigator.pop(dialogContext, (cardQuestion, cardAnswer));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (details != null) {
      await widget.appState.addFlashcard(
        question: details.$1,
        answer: details.$2,
      );
      if (mounted) {
        setState(() {
          _currentIndex = 0;
          _showAnswer = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flashcards = widget.appState.flashcards;
    if (_currentIndex >= flashcards.length) {
      _currentIndex = flashcards.isEmpty ? 0 : flashcards.length - 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFlashcard,
        icon: const Icon(Icons.add),
        label: const Text('Add card'),
      ),
      body: flashcards.isEmpty
          ? const EmptyState(
              icon: Icons.style_outlined,
              title: 'No flashcards yet',
              message: 'Add a question and answer to start studying.',
            )
          : _FlashcardStudyView(
              flashcards: flashcards,
              currentIndex: _currentIndex,
              showAnswer: _showAnswer,
              onTap: () => setState(() => _showAnswer = !_showAnswer),
              onPrevious: () => setState(() {
                _currentIndex =
                    (_currentIndex - 1 + flashcards.length) % flashcards.length;
                _showAnswer = false;
              }),
              onNext: () => setState(() {
                _currentIndex = (_currentIndex + 1) % flashcards.length;
                _showAnswer = false;
              }),
              onDelete: () async {
                final flashcard = flashcards[_currentIndex];
                if (await showDeleteConfirmation(
                  context,
                  itemName: 'this flashcard',
                )) {
                  await widget.appState.deleteFlashcard(flashcard.id);
                  if (mounted) {
                    setState(() {
                      if (_currentIndex >= widget.appState.flashcards.length) {
                        _currentIndex = widget.appState.flashcards.isEmpty
                            ? 0
                            : widget.appState.flashcards.length - 1;
                      }
                      _showAnswer = false;
                    });
                  }
                }
              },
            ),
    );
  }
}

class _FlashcardStudyView extends StatelessWidget {
  const _FlashcardStudyView({
    required this.flashcards,
    required this.currentIndex,
    required this.showAnswer,
    required this.onTap,
    required this.onPrevious,
    required this.onNext,
    required this.onDelete,
  });

  final List<Flashcard> flashcards;
  final int currentIndex;
  final bool showAnswer;
  final VoidCallback onTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final flashcard = flashcards[currentIndex];
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '${currentIndex + 1} of ${flashcards.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Card(
              color: colorScheme.primary,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onTap,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          showAnswer ? 'ANSWER' : 'QUESTION',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: colorScheme.onPrimary.withValues(
                                  alpha: 0.8,
                                ),
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          showAnswer ? flashcard.answer : flashcard.question,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Tap to ${showAnswer ? 'see the question' : 'reveal the answer'}',
                          style: TextStyle(
                            color: colorScheme.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
              IconButton(
                tooltip: 'Delete flashcard',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
              FilledButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
              ),
            ],
          ),
          const SizedBox(height: 76),
        ],
      ),
    );
  }
}
