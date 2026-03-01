import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/Projet.dart';
import '../../providers/project_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/cards/project_card.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;
  final ProjectProvider projectProvider;
  final String userId;

  const ProjectFormScreen({
    super.key,
    this.project,
    required this.projectProvider,
    required this.userId,
  });

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  // 8 couleurs prédéfinies
  final List<Color> _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.error,
    AppColors.warning,
    AppColors.success,
    const Color(0xFF9C27B0),
    const Color(0xFFFF9800),
    const Color(0xFF00BCD4),
  ];

  late int _selectedColor;

  @override
  void initState() {
    super.initState();
    // Pré-remplir en mode modification
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description ?? '';
      _selectedColor = widget.project!.color;
    } else {
      _selectedColor = _colors[0].value;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    if (widget.project == null) {
      // Création
      await widget.projectProvider.createProject(
        _nameController.text.trim(),
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        _selectedColor,
        widget.userId,
      );
    } else {
      // Modification
      final updatedProject = widget.project!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        color: _selectedColor,
      );
      await widget.projectProvider.updateProject(updatedProject);
    }

    setState(() => _isLoading = false);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing
            ? AppStrings.editProject
            : AppStrings.newProject),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom du projet
              CustomTextField(
                label: AppStrings.projectName,
                controller: _nameController,
                hint: 'Ex: Application Mobile',
                prefixIcon: Icons.folder_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.requiredField;
                  }
                  if (value.length < 3) {
                    return 'Le nom doit contenir au moins 3 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description
              CustomTextField(
                label: AppStrings.projectDescription,
                controller: _descriptionController,
                hint: 'Description du projet (optionnel)',
                maxLines: 3,
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 24),
              // Sélecteur de couleur
              const Text(
                'Couleur du projet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color.value;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color.value),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                            color: AppColors.textPrimary, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 8,
                          )
                        ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                          color: AppColors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Aperçu
              const Text(
                'Aperçu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ListenableBuilder(
                listenable: _nameController,
                builder: (context, _) {
                  return ProjectCard(
                    project: Project(
                      id: 'preview',
                      name: _nameController.text.isEmpty
                          ? 'Nom du projet'
                          : _nameController.text,
                      description: _descriptionController.text.isEmpty
                          ? null
                          : _descriptionController.text,
                      userId: widget.userId,
                      color: _selectedColor,
                    ),
                    taskCount: 0,
                  );
                },
              ),
              const SizedBox(height: 24),
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
}