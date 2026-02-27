import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/Projet.dart';
import '../services/storage_service.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;

  // Getters
  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  int get projectCount => _projects.length;
  bool get isLoading => _isLoading;

  // Charger les projets d'un utilisateur
  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    notifyListeners();

    _projects = await StorageService.instance.getProjects(userId);

    _isLoading = false;
    notifyListeners();
  }

  // Créer un projet
  Future<void> createProject(String name, String? description,
      int color, String userId) async {
    final project = Project(
      id: const Uuid().v4(),
      name: name,
      description: description,
      color: color,
      userId: userId,
    );

    await StorageService.instance.saveProject(project);
    _projects.add(project);
    notifyListeners();
  }

  // Modifier un projet
  Future<void> updateProject(Project project) async {
    await StorageService.instance.saveProject(project);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      _projects[index] = project;
      notifyListeners();
    }
  }

  // Supprimer un projet et toutes ses tâches
  Future<void> deleteProject(String projectId) async {
    await StorageService.instance.deleteProject(projectId);
    await StorageService.instance.deleteTasksByProjectId(projectId);
    _projects.removeWhere((p) => p.id == projectId);
    if (_selectedProject?.id == projectId) {
      _selectedProject = null;
    }
    notifyListeners();
  }

  // Sélectionner un projet
  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }
}