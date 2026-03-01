import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/Task.dart';
import '../../../providers/project_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../widgets/cards/task_card.dart';
import '../../tasks/task_detail_screen.dart';

class TasksTab extends StatelessWidget {
  final TaskProvider taskProvider;
  final ProjectProvider projectProvider;

  const TasksTab({
    super.key,
    required this.taskProvider,
    required this.projectProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: taskProvider,
      builder: (context, _) {
        final tasks = taskProvider.tasks;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Filtres
              _buildFilters(),
              // Liste tâches
              Expanded(
                child: tasks.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 80,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        AppStrings.noTasks,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        AppStrings.noTasksDesc,
                        style:
                        TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
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
                                taskProvider: taskProvider,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtre statut
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Tous',
                  taskProvider.statusFilter == null,
                      () => taskProvider.setStatusFilter(null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'À faire',
                  taskProvider.statusFilter == TaskStatus.todo,
                      () => taskProvider.setStatusFilter(TaskStatus.todo),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'En cours',
                  taskProvider.statusFilter == TaskStatus.inProgress,
                      () => taskProvider.setStatusFilter(TaskStatus.inProgress),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Terminées',
                  taskProvider.statusFilter == TaskStatus.done,
                      () => taskProvider.setStatusFilter(TaskStatus.done),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? AppColors.white : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}