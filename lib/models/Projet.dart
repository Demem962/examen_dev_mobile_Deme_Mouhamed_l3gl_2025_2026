import 'package:flutter/material.dart';

class Project {
  final String id;
  final String name;
  final String? description;
  final String userId; // ID du propriétaire
  final int color; // On stocke la couleur en int (Color.value)
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.color,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Getter pratique pour récupérer la Color
  Color get projectColor => Color(color);

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? userId,
    int? color,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'userId': userId,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      userId: map['userId'] as String,
      color: map['color'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, name: $name)';
  }
}