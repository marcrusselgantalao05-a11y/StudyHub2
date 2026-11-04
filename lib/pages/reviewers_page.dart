import 'package:flutter/material.dart';

import '../models/study_models.dart';
import '../state/app_state.dart';
import '../widgets/app_widgets.dart';

class ReviewersPage extends StatelessWidget {
  const ReviewersPage({required this.appState, super.key});

  final AppState appState;

  Future<void> _editReviewer(BuildContext context, {Reviewer? reviewer}) async {
    var subject = reviewer?.subject ?? '';
    var title = reviewer?.title ?? '';
    var content = reviewer?.content ?? '';

    final details = await showDialog<(String, String, String)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(reviewer == null ? 'Add a reviewer' : 'Edit reviewer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormFieldInput(
                label: 'Subject name',
                initialValue: subject,
                onChanged: (value) => subject = value,
              ),
              const SizedBox(height: 12),
              FormFieldInput(
                label: 'Title',
                initialValue: title,
                onChanged: (value) => title = value,
              ),
              const SizedBox(height: 12),
              FormFieldInput(
                label: 'Content',
                initialValue: content,
                maxLines: 5,
                onChanged: (value) => content = value,
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
              final reviewerSubject = subject.trim();
              final reviewerTitle = title.trim();
              final reviewerContent = content.trim();
              if (reviewerSubject.isNotEmpty &&
                  reviewerTitle.isNotEmpty &&
                  reviewerContent.isNotEmpty) {
                Navigator.pop(dialogContext, (
                  reviewerSubject,
                  reviewerTitle,
                  reviewerContent,
                ));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (details != null) {
      await appState.saveReviewer(
        id: reviewer?.id,
        subject: details.$1,
        title: details.$2,
        content: details.$3,
      );
    }
  }

  Future<void> _showDetails(BuildContext context, Reviewer reviewer) async {
    final shouldEdit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(reviewer.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reviewer.subject,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 16),
              SelectableText(reviewer.content),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Close'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
    if (shouldEdit == true && context.mounted) {
      await _editReviewer(context, reviewer: reviewer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewers = [...appState.reviewers]
      ..sort((first, second) => first.subject.compareTo(second.subject));

    return Scaffold(
      appBar: AppBar(title: const Text('My reviewers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editReviewer(context),
        icon: const Icon(Icons.add),
        label: const Text('Add reviewer'),
      ),
      body: reviewers.isEmpty
          ? const EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No reviewers yet',
              message:
                  'Create a reviewer to keep your study notes in one place.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                for (var index = 0; index < reviewers.length; index++) ...[
                  if (index == 0 ||
                      reviewers[index - 1].subject != reviewers[index].subject)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                      child: Text(
                        reviewers[index].subject,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  _ReviewerCard(
                    reviewer: reviewers[index],
                    onTap: () => _showDetails(context, reviewers[index]),
                    onEdit: () =>
                        _editReviewer(context, reviewer: reviewers[index]),
                    onDelete: () async {
                      final reviewer = reviewers[index];
                      if (await showDeleteConfirmation(
                        context,
                        itemName: reviewer.title,
                      )) {
                        await appState.deleteReviewer(reviewer.id);
                      }
                    },
                  ),
                ],
              ],
            ),
    );
  }
}

class _ReviewerCard extends StatelessWidget {
  const _ReviewerCard({
    required this.reviewer,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Reviewer reviewer;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(
        Icons.description_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(reviewer.title),
      subtitle: Text(
        reviewer.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      trailing: PopupMenuButton<String>(
        onSelected: (action) {
          if (action == 'edit') onEdit();
          if (action == 'delete') onDelete();
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    ),
  );
}
