import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/app_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.appState,
    required this.onNavigate,
    super.key,
  });

  final AppState appState;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final completedCount = appState.tasks
        .where((task) => task.isCompleted)
        .length;
    final pendingCount = appState.tasks.length - completedCount;
    final recentTasks = appState.tasks.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Academic Assistant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'Welcome back!',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'A little progress each day adds up.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Image.asset(
              'assets/images/study_logo.png',
              height: 78,
              fit: BoxFit.contain,
              semanticLabel: 'Study your best',
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Total',
                  value: '${appState.tasks.length}',
                  icon: Icons.checklist,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryCard(
                  label: 'Done',
                  value: '$completedCount',
                  icon: Icons.task_alt,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryCard(
                  label: 'Pending',
                  value: '$pendingCount',
                  icon: Icons.pending_actions,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently added',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => onNavigate(1),
                child: const Text('All tasks'),
              ),
            ],
          ),
          if (recentTasks.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Your recently added tasks will appear here.'),
              ),
            )
          else
            ...recentTasks.map(
              (task) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('Due ${formatDate(task.deadline)}'),
                ),
              ),
            ),
          const SizedBox(height: 14),
          Text(
            'Your study space',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _ShortcutCard(
            icon: Icons.checklist,
            title: 'Task manager',
            subtitle: 'Keep track of assignments and deadlines',
            onTap: () => onNavigate(1),
          ),
          _ShortcutCard(
            icon: Icons.menu_book,
            title: 'My reviewers',
            subtitle: 'Save and revisit your subject notes',
            onTap: () => onNavigate(2),
          ),
          _ShortcutCard(
            icon: Icons.style,
            title: 'Flashcards',
            subtitle: 'Practice with your question and answer cards',
            onTap: () => onNavigate(3),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    ),
  );
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    ),
  );
}
