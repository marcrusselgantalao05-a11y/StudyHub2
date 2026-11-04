import 'package:flutter/material.dart';

import '../models/study_models.dart';
import '../state/app_state.dart';
import '../widgets/app_widgets.dart';

class TaskManagerPage extends StatelessWidget {
  const TaskManagerPage({required this.appState, super.key});

  final AppState appState;

  Future<void> _addTask(BuildContext context) async {
    var title = '';
    var description = '';
    var deadline = DateTime.now().add(const Duration(days: 1));

    final taskDetails = await showDialog<(String, String, DateTime)>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add a task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormFieldInput(
                  label: 'Task title',
                  onChanged: (value) => title = value,
                ),
                const SizedBox(height: 12),
                FormFieldInput(
                  label: 'Description',
                  maxLines: 3,
                  onChanged: (value) => description = value,
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Deadline'),
                  subtitle: Text(formatDate(deadline)),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: deadline,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setDialogState(() => deadline = pickedDate);
                    }
                  },
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
                final taskTitle = title.trim();
                if (taskTitle.isNotEmpty) {
                  Navigator.pop(dialogContext, (
                    taskTitle,
                    description.trim(),
                    deadline,
                  ));
                }
              },
              child: const Text('Save task'),
            ),
          ],
        ),
      ),
    );

    if (taskDetails != null) {
      await appState.addTask(
        title: taskDetails.$1,
        description: taskDetails.$2,
        deadline: taskDetails.$3,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks = appState.tasks.where((task) => !task.isCompleted);
    final completedTasks = appState.tasks.where((task) => task.isCompleted);
    final tasks = [...pendingTasks, ...completedTasks];

    return Scaffold(
      appBar: AppBar(title: const Text('Task manager')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTask(context),
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
      ),
      body: tasks.isEmpty
          ? const EmptyState(
              icon: Icons.checklist,
              title: 'No tasks yet',
              message: 'Add a task to keep your school work organized.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: tasks.length,
              itemBuilder: (context, index) =>
                  _TaskCard(task: tasks[index], appState: appState),
            ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.appState});

  final StudyTask task;
  final AppState appState;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => appState.toggleTask(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(task.description),
            ],
            const SizedBox(height: 4),
            Text('Due ${formatDate(task.deadline)}'),
          ],
        ),
        trailing: IconButton(
          tooltip: 'Delete task',
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            if (await showDeleteConfirmation(context, itemName: task.title)) {
              await appState.deleteTask(task.id);
            }
          },
        ),
      ),
    ),
  );
}
