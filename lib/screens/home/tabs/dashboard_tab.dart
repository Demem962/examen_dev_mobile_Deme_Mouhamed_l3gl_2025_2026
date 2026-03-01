import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/Task.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/project_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../widgets/cards/project_card.dart';

class DashboardTab extends StatelessWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const DashboardTab({
    super.key,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
  });

  // Message de bienvenue selon l'heure
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([authProvider, projectProvider, taskProvider]),
      builder: (context, _) {
        final user = authProvider.currentUser;
        final projects = projectProvider.projects;
        final taskCounts = taskProvider.taskCountByStatus;

        return RefreshIndicator(
          onRefresh: () async {
            if (user != null) {
              await projectProvider.loadProjects(user.id);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message de bienvenue
                Text(
                  '${_getGreeting()}, ${user?.name ?? ''} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Voici un résumé de vos activités',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Cartes statistiques
                Row(
                  children: [
                    _buildStatCard(
                      'Projets',
                      '${projectProvider.projectCount}',
                      Icons.folder,
                      AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'À faire',
                      '${taskCounts[TaskStatus.todo] ?? 0}',
                      Icons.radio_button_unchecked,
                      AppColors.statusTodo,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard(
                      'En cours',
                      '${taskCounts[TaskStatus.inProgress] ?? 0}',
                      Icons.timelapse,
                      AppColors.statusInProgress,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Terminées',
                      '${taskCounts[TaskStatus.done] ?? 0}',
                      Icons.check_circle,
                      AppColors.statusDone,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Projets récents
                const Text(
                  'Projets récents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                if (projects.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.folder_open,
                              size: 64, color: AppColors.textSecondary),
                          SizedBox(height: 16),
                          Text(
                            'Aucun projet pour le moment',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: projects.length > 3 ? 3 : projects.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ProjectCard(
                          project: projects[index],
                          taskCount: 0,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}