import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

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

  // ======== Onboarding =========
  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }

  // ======== Users =========

  // Récupérer tous les utilisateurs
  Future<List<User>> getUsers() async {
    final String? usersJson = _prefs.getString(_keyUsers);
    if (usersJson == null) return [];

    final List<dynamic> usersList = jsonDecode(usersJson);
    return usersList.map((u) => User.fromMap(u)).toList();
  }

  // Sauvegarder un utilisateur
  Future<void> saveUser(User user) async {
    final users = await getUsers();
    // Vérifie si l'user existe déjà, si oui on le remplace
    final index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await _prefs.setString(_keyUsers, jsonEncode(
        users.map((u) => u.toMap()).toList()
    ));
  }

  // Sauvegarder l'utilisateur connecté
  Future<void> saveCurrentUser(User user) async {
    await _prefs.setString(_keyCurrentUser, jsonEncode(user.toMap()));
  }

  // Récupérer l'utilisateur connecté
  Future<User?> getCurrentUser() async {
    final String? userJson = _prefs.getString(_keyCurrentUser);
    if (userJson == null) return null;
    return User.fromMap(jsonDecode(userJson));
  }

  // Supprimer l'utilisateur connecté (déconnexion)
  Future<void> clearCurrentUser() async {
    await _prefs.remove(_keyCurrentUser);
  }
}