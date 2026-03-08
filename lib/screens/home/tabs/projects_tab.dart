import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/project_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../widgets/cards/project_card.dart';
import '../../projects/project_form_screen.dart';
import '../../projects/project_detail_screen.dart';

class ProjectsTab extends StatelessWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const ProjectsTab({
    super.key,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: projectProvider,
      builder: (context, _) {
        final projects = projectProvider.projects;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: projects.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_open,
                    size: 80, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                const Text(
                  AppStrings.noProjects,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.noProjectsDesc,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _navigateToCreateProject(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.newProject),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProjectCard(
                  project: project,
                  taskCount: 0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectDetailScreen(
                          project: project,
                          projectProvider: projectProvider,
                          taskProvider: taskProvider,
                        ),
                      ),
                    );
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectFormScreen(
                          project: project,
                          projectProvider: projectProvider,
                          userId: authProvider.currentUser!.id,
                        ),
                      ),
                    );
                  },
                  onDelete: () => _confirmDelete(context, project.id),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            onPressed: () => _navigateToCreateProject(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _navigateToCreateProject(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectFormScreen(
          projectProvider: projectProvider,
          userId: authProvider.currentUser!.id,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String projectId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteProject),
        content: const Text(AppStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              projectProvider.deleteProject(projectId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}