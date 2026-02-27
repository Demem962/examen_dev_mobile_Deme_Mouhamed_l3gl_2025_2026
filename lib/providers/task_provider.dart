import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/Task.dart';
import '../services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  bool _isLoading = false;

  // Getters
  bool get isLoading => _isLoading;
  TaskStatus? get statusFilter => _statusFilter;
  TaskPriority? get priorityFilter => _priorityFilter;

  // Retourne les tâches filtrées et triées
  List<Task> get tasks {
    List<Task> filtered = _tasks;

    // Appliquer filtre statut
    if (_statusFilter != null) {
      filtered = filtered.where((t) => t.status == _statusFilter).toList();
    }

    // Appliquer filtre priorité
    if (_priorityFilter != null) {
      filtered = filtered.where((t) => t.priority == _priorityFilter).toList();
    }

    // Trier : inProgress > todo > done, puis high > medium > low
    filtered.sort((a, b) {
      final statusOrder = {
        TaskStatus.inProgress: 0,
        TaskStatus.todo: 1,
        TaskStatus.done: 2,
      };
      final priorityOrder = {
        TaskPriority.high: 0,
        TaskPriority.medium: 1,
        TaskPriority.low: 2,
      };

      final statusCompare =
      statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
      if (statusCompare != 0) return statusCompare;

      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });

    return filtered;
  }

  // Compteur par statut
  Map<TaskStatus, int> get taskCountByStatus {
    return {
      TaskStatus.todo: _tasks.where((t) => t.status == TaskStatus.todo).length,
      TaskStatus.inProgress: _tasks.where((t) => t.status == TaskStatus.inProgress).length,
      TaskStatus.done: _tasks.where((t) => t.status == TaskStatus.done).length,
    };
  }

  // Charger les tâches d'un projet
  Future<void> loadTasks(String projectId) async {
    _isLoading = true;
    notifyListeners();

    _tasks = await StorageService.instance.getTasks(projectId);

    _isLoading = false;
    notifyListeners();
  }

  // Créer une tâche
  Future<void> createTask(String title, String? description,
      String projectId, String userId,
      {TaskStatus status = TaskStatus.todo,
        TaskPriority priority = TaskPriority.medium,
        DateTime? dueDate}) async {
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      projectId: projectId,
      userId: userId,
      status: status,
      priority: priority,
      dueDate: dueDate,
    );

    await StorageService.instance.saveTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  // Modifier une tâche
  Future<void> updateTask(Task task) async {
    await StorageService.instance.saveTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  // Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    await StorageService.instance.deleteTask(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  // Changer le statut d'une tâche rapidement
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final updatedTask = _tasks[index].copyWith(status: status);
      await StorageService.instance.saveTask(updatedTask);
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  // Filtres
  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    notifyListeners();
  }
}