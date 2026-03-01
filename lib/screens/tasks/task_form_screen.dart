import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/Task.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final TaskProvider taskProvider;
  final String projectId;
  final String userId;

  const TaskFormScreen({
    super.key,
    this.task,
    required this.taskProvider,
    required this.projectId,
    required this.userId,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  late TaskStatus _selectedStatus;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    // Pré-remplir en mode modification
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedStatus = widget.task!.status;
      _selectedPriority = widget.task!.priority;
      _selectedDueDate = widget.task!.dueDate;
    } else {
      _selectedStatus = TaskStatus.todo;
      _selectedPriority = TaskPriority.medium;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    if (widget.task == null) {
      // Création
      await widget.taskProvider.createTask(
        _titleController.text.trim(),
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        widget.projectId,
        widget.userId,
        status: _selectedStatus,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );
    } else {
      // Modification
      final updatedTask = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );
      await widget.taskProvider.updateTask(updatedTask);
    }

    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteTask),
        content: const Text(AppStrings.confirmDelete),
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
      await widget.taskProvider.deleteTask(widget.task!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editTask : AppStrings.newTask),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          // Bouton suppression uniquement en mode modification
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              CustomTextField(
                label: AppStrings.taskTitle,
                controller: _titleController,
                hint: 'Ex: Créer la maquette',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.requiredField;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description
              CustomTextField(
                label: AppStrings.taskDescription,
                controller: _descriptionController,
                hint: 'Description de la tâche (optionnel)',
                maxLines: 3,
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 24),
              // Sélecteur statut
              const Text(
                'Statut',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatusSelector(
                    'À faire',
                    TaskStatus.todo,
                    AppColors.statusTodo,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusSelector(
                    'En cours',
                    TaskStatus.inProgress,
                    AppColors.statusInProgress,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusSelector(
                    'Terminée',
                    TaskStatus.done,
                    AppColors.statusDone,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Sélecteur priorité
              const Text(
                'Priorité',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPrioritySelector(
                    'Haute',
                    TaskPriority.high,
                    AppColors.priorityHigh,
                    Icons.arrow_upward,
                  ),
                  const SizedBox(width: 8),
                  _buildPrioritySelector(
                    'Moyenne',
                    TaskPriority.medium,
                    AppColors.priorityMedium,
                    Icons.remove,
                  ),
                  const SizedBox(width: 8),
                  _buildPrioritySelector(
                    'Basse',
                    TaskPriority.low,
                    AppColors.priorityLow,
                    Icons.arrow_downward,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Date d'échéance
              const Text(
                'Date d\'échéance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDueDate != null
                            ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                            : 'Sélectionner une date (optionnel)',
                        style: TextStyle(
                          color: _selectedDueDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedDueDate != null)
                        GestureDetector(
                          onTap: () =>
                              setState(() => _selectedDueDate = null),
                          child: const Icon(Icons.close,
                              color: AppColors.textSecondary, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Bouton sauvegarder
              CustomButton(
                text: isEditing ? AppStrings.save : 'Créer',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSelector(
      String label, TaskStatus status, Color color) {
    final isSelected = _selectedStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStatus = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.circle,
                color: isSelected ? color : AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(
      String label, TaskPriority priority, Color color, IconData icon) {
    final isSelected = _selectedPriority == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = priority),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}