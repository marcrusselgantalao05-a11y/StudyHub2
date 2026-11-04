import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/study_models.dart';

class AppState extends ChangeNotifier {
  static const _tasksKey = 'tasks';
  static const _reviewersKey = 'reviewers';
  static const _flashcardsKey = 'flashcards';

  final List<StudyTask> _tasks = [];
  final List<Reviewer> _reviewers = [];
  final List<Flashcard> _flashcards = [];
  late SharedPreferences _preferences;

  List<StudyTask> get tasks => List.unmodifiable(_tasks);
  List<Reviewer> get reviewers => List.unmodifiable(_reviewers);
  List<Flashcard> get flashcards => List.unmodifiable(_flashcards);

  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();
    _tasks.addAll(_readList(_tasksKey, StudyTask.fromJson));
    _reviewers.addAll(_readList(_reviewersKey, Reviewer.fromJson));
    _flashcards.addAll(_readList(_flashcardsKey, Flashcard.fromJson));
  }

  List<T> _readList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final savedValue = _preferences.getString(key);
    if (savedValue == null) return [];

    final decoded = jsonDecode(savedValue) as List<dynamic>;
    return decoded
        .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> addTask({
    required String title,
    required String description,
    required DateTime deadline,
  }) async {
    _tasks.insert(
      0,
      StudyTask(
        id: _newId(),
        title: title,
        description: description,
        deadline: deadline,
      ),
    );
    await _saveTasks();
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(
      isCompleted: !_tasks[index].isCompleted,
    );
    await _saveTasks();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> saveReviewer({
    String? id,
    required String subject,
    required String title,
    required String content,
  }) async {
    final reviewer = Reviewer(
      id: id ?? _newId(),
      subject: subject,
      title: title,
      content: content,
    );
    final index = _reviewers.indexWhere((item) => item.id == reviewer.id);
    if (index == -1) {
      _reviewers.insert(0, reviewer);
    } else {
      _reviewers[index] = reviewer;
    }
    await _saveReviewers();
    notifyListeners();
  }

  Future<void> deleteReviewer(String id) async {
    _reviewers.removeWhere((reviewer) => reviewer.id == id);
    await _saveReviewers();
    notifyListeners();
  }

  Future<void> addFlashcard({
    required String question,
    required String answer,
  }) async {
    _flashcards.insert(
      0,
      Flashcard(id: _newId(), question: question, answer: answer),
    );
    await _saveFlashcards();
    notifyListeners();
  }

  Future<void> deleteFlashcard(String id) async {
    _flashcards.removeWhere((flashcard) => flashcard.id == id);
    await _saveFlashcards();
    notifyListeners();
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _saveTasks() => _saveList(_tasksKey, _tasks);

  Future<void> _saveReviewers() => _saveList(_reviewersKey, _reviewers);

  Future<void> _saveFlashcards() => _saveList(_flashcardsKey, _flashcards);

  Future<void> _saveList(String key, List<dynamic> values) async {
    await _preferences.setString(
      key,
      jsonEncode(values.map((value) => value.toJson()).toList()),
    );
  }
}
