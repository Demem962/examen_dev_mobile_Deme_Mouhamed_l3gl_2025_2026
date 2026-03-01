import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/Projet.dart';
import '../../models/Task.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/cards/task_card.dart';
import '../tasks/task_form_screen.dart';
import '../tasks/task_detail_screen.dart';
import 'project_form_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  final ProjectProvider projectProvider;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.projectProvider,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final TaskProvider _taskProvider = TaskProvider();
  late Project _project;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    await _taskProvider.loadTasks(_project.id);
  }

  Future<void> _deleteProject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteProject),
        content: const Text(
            'Supprimer ce projet supprimera aussi toutes ses tâches. Continuer ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await widget.projectProvider.deleteProject(_project.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_project.name),
        backgroundColor: _project.projectColor,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectFormScreen(
                    project: _project,
                    projectProvider: widget.projectProvider,
                    userId: _project.userId,
                  ),
                ),
              );
              setState(() {
                _project = widget.projectProvider.projects.firstWhere(
                      (p) => p.id == _project.id,
                  orElse: () => _project,
                );
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteProject,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _taskProvider,
        builder: (context, _) {
          final tasks = _taskProvider.tasks;
          final taskCounts = _taskProvider.taskCountByStatus;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête coloré
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: _project.projectColor.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_project.description != null &&
                          _project.description!.isNotEmpty)
                        Text(
                          _project.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Créé le ${_project.createdAt.day}/${_project.createdAt.month}/${_project.createdAt.year}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Chips statistiques
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildStatusChip(
                            'À faire',
                            taskCounts[TaskStatus.todo] ?? 0,
                            AppColors.statusTodo,
                          ),
                          _buildStatusChip(
                            'En cours',
                            taskCounts[TaskStatus.inProgress] ?? 0,
                            AppColors.statusInProgress,
                          ),
                          _buildStatusChip(
                            'Terminées',
                            taskCounts[TaskStatus.done] ?? 0,
                            AppColors.statusDone,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Liste des tâches
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tâches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (tasks.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(Icons.task_alt,
                                    size: 64,
                                    color: AppColors.textSecondary),
                                SizedBox(height: 16),
                                Text(
                                  'Aucune tâche pour ce projet',
                                  style: TextStyle(
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TaskCard(
                                task: task,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TaskDetailScreen(
                                        task: task,
                                        taskProvider: _taskProvider,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _project.projectColor,
        foregroundColor: AppColors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskFormScreen(
                projectId: _project.id,
                userId: _project.userId,
                taskProvider: _taskProvider,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}