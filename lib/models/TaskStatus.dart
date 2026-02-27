// Les différents statuts d'une tâche
enum TaskStatus { todo, inProgress, done }

// Les différentes priorités d'une tâche
enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String? description;
  final String projectId; // ID du projet associé
  final String userId;    // ID du créateur
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate; // Date d'échéance optionnelle
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.projectId,
    required this.userId,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? projectId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectId': projectId,
      'userId': userId,
      'status': status.name,       // ex: 'todo', 'inProgress'
      'priority': priority.name,   // ex: 'low', 'medium', 'high'
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      projectId: map['projectId'] as String,
      userId: map['userId'] as String,
      status: TaskStatus.values.byName(map['status'] as String),
      priority: TaskPriority.values.byName(map['priority'] as String),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status)';
  }
}