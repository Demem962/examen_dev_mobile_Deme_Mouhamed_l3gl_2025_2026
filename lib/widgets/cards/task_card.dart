import 'package:flutter/material.dart';
import '../../models/Task.dart';
import '../../core/constants/app_colors.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  // Couleur selon le statut
  Color _getStatusColor() {
    switch (task.status) {
      case TaskStatus.todo:
        return AppColors.statusTodo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.done:
        return AppColors.statusDone;
    }
  }

  // Texte selon le statut
  String _getStatusText() {
    switch (task.status) {
      case TaskStatus.todo:
        return 'À faire';
      case TaskStatus.inProgress:
        return 'En cours';
      case TaskStatus.done:
        return 'Terminé';
    }
  }

  // Couleur selon la priorité
  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
    }
  }

  // Icône selon la priorité
  IconData _getPriorityIcon() {
    switch (task.priority) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.arrow_upward;
    }
  }

  // Texte selon la priorité
  String _getPriorityText() {
    switch (task.priority) {
      case TaskPriority.low:
        return 'Basse';
      case TaskPriority.medium:
        return 'Moyenne';
      case TaskPriority.high:
        return 'Haute';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Titre
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  // Badge statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
              // Description
              if (task.description != null &&
                  task.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  // Indicateur priorité
                  Icon(
                    _getPriorityIcon(),
                    size: 14,
                    color: _getPriorityColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getPriorityText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getPriorityColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // Date d'échéance
                  if (task.dueDate != null) ...[
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}