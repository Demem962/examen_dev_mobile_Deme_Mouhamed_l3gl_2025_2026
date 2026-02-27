import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Projet.dart';
import '../models/user.dart';
import '../models/Task.dart';

class StorageService {
  static StorageService? _instance;

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  StorageService._();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ======== Clés de Stockage =========
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyUsers = 'users';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyProjects = 'projects';
  static const String _keyTasks = 'tasks';

  // ======== Onboarding =========
  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }

  // ======== Users =========
  Future<List<User>> getUsers() async {
    final String? usersJson = _prefs.getString(_keyUsers);
    if (usersJson == null) return [];
    final List<dynamic> usersList = jsonDecode(usersJson);
    return usersList.map((u) => User.fromMap(u)).toList();
  }

  Future<void> saveUser(User user) async {
    final users = await getUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await _prefs.setString(
        _keyUsers, jsonEncode(users.map((u) => u.toMap()).toList()));
  }

  Future<void> saveCurrentUser(User user) async {
    await _prefs.setString(_keyCurrentUser, jsonEncode(user.toMap()));
  }

  Future<User?> getCurrentUser() async {
    final String? userJson = _prefs.getString(_keyCurrentUser);
    if (userJson == null) return null;
    return User.fromMap(jsonDecode(userJson));
  }

  Future<void> clearCurrentUser() async {
    await _prefs.remove(_keyCurrentUser);
  }

  // ======== Projects =========
  Future<List<Project>> getProjects(String userId) async {
    final String? projectsJson = _prefs.getString(_keyProjects);
    if (projectsJson == null) return [];
    final List<dynamic> projectsList = jsonDecode(projectsJson);
    return projectsList
        .map((p) => Project.fromMap(p))
        .where((p) => p.userId == userId)
        .toList();
  }

  Future<void> saveProject(Project project) async {
    final String? projectsJson = _prefs.getString(_keyProjects);
    List<dynamic> projectsList =
    projectsJson != null ? jsonDecode(projectsJson) : [];
    final projects = projectsList.map((p) => Project.fromMap(p)).toList();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    await _prefs.setString(
        _keyProjects, jsonEncode(projects.map((p) => p.toMap()).toList()));
  }

  Future<void> deleteProject(String projectId) async {
    final String? projectsJson = _prefs.getString(_keyProjects);
    if (projectsJson == null) return;
    final List<dynamic> projectsList = jsonDecode(projectsJson);
    final projects = projectsList
        .map((p) => Project.fromMap(p))
        .where((p) => p.id != projectId)
        .toList();
    await _prefs.setString(
        _keyProjects, jsonEncode(projects.map((p) => p.toMap()).toList()));
  }

  // ======== Tasks =========
  Future<List<Task>> getTasks(String projectId) async {
    final String? tasksJson = _prefs.getString(_keyTasks);
    if (tasksJson == null) return [];
    final List<dynamic> tasksList = jsonDecode(tasksJson);
    return tasksList
        .map((t) => Task.fromMap(t))
        .where((t) => t.projectId == projectId)
        .toList();
  }

  Future<void> saveTask(Task task) async {
    final String? tasksJson = _prefs.getString(_keyTasks);
    List<dynamic> tasksList =
    tasksJson != null ? jsonDecode(tasksJson) : [];
    final tasks = tasksList.map((t) => Task.fromMap(t)).toList();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
    await _prefs.setString(
        _keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }

  Future<void> deleteTask(String taskId) async {
    final String? tasksJson = _prefs.getString(_keyTasks);
    if (tasksJson == null) return;
    final List<dynamic> tasksList = jsonDecode(tasksJson);
    final tasks = tasksList
        .map((t) => Task.fromMap(t))
        .where((t) => t.id != taskId)
        .toList();
    await _prefs.setString(
        _keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }

  Future<void> deleteTasksByProjectId(String projectId) async {
    final String? tasksJson = _prefs.getString(_keyTasks);
    if (tasksJson == null) return;
    final List<dynamic> tasksList = jsonDecode(tasksJson);
    final tasks = tasksList
        .map((t) => Task.fromMap(t))
        .where((t) => t.projectId != projectId)
        .toList();
    await _prefs.setString(
        _keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }
}