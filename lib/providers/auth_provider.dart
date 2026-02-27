import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  // Propriétés privées
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters publics
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charge l'utilisateur connecté au démarrage
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await StorageService.instance.getCurrentUser();

    _isLoading = false;
    notifyListeners();
  }

  // Connexion
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Récupérer tous les users
      final users = await StorageService.instance.getUsers();

      // Chercher un user avec cet email et mot de passe
      final user = users.firstWhere(
            (u) => u.email == email && u.password == password,
        orElse: () => throw Exception('Email ou mot de passe incorrect'),
      );

      // Sauvegarder l'utilisateur connecté
      await StorageService.instance.saveCurrentUser(user);
      _currentUser = user;

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Inscription
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Vérifier si l'email existe déjà
      final users = await StorageService.instance.getUsers();
      final emailExists = users.any((u) => u.email == email);

      if (emailExists) {
        throw Exception('Un compte existe déjà avec cet email');
      }

      // Créer le nouvel utilisateur
      final newUser = User(
        id: const Uuid().v4(),
        name: name,
        email: email,
        password: password,
        createdAt: DateTime.now(),
      );

      // Sauvegarder
      await StorageService.instance.saveUser(newUser);
      await StorageService.instance.saveCurrentUser(newUser);
      _currentUser = newUser;

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await StorageService.instance.clearCurrentUser();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  // Mise à jour du profil
  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      name: name,
      email: email,
    );

    await StorageService.instance.saveUser(updatedUser);
    await StorageService.instance.saveCurrentUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  // Effacer le message d'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}