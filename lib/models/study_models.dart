class StudyTask {
  const StudyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final bool isCompleted;

  StudyTask copyWith({bool? isCompleted}) => StudyTask(
    id: id,
    title: title,
    description: description,
    deadline: deadline,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'deadline': deadline.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory StudyTask.fromJson(Map<String, dynamic> json) => StudyTask(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    deadline: DateTime.parse(json['deadline'] as String),
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}

class Reviewer {
  const Reviewer({
    required this.id,
    required this.subject,
    required this.title,
    required this.content,
  });

  final String id;
  final String subject;
  final String title;
  final String content;

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'title': title,
    'content': content,
  };

  factory Reviewer.fromJson(Map<String, dynamic> json) => Reviewer(
    id: json['id'] as String,
    subject: json['subject'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
  );
}

class Flashcard {
  const Flashcard({
    required this.id,
    required this.question,
    required this.answer,
  });

  final String id;
  final String question;
  final String answer;

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
  };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'] as String,
    question: json['question'] as String,
    answer: json['answer'] as String,
  );
}
