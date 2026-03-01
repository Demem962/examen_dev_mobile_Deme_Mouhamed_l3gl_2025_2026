import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../auth/login_screen.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/projects_tab.dart';
import 'tabs/tasks_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authProvider = AuthProvider();
  final _projectProvider = ProjectProvider();
  final _taskProvider = TaskProvider();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _authProvider.init();
    if (_authProvider.currentUser != null) {
      await _projectProvider.loadProjects(_authProvider.currentUser!.id);
    }
  }

  Future<void> _logout() async {
    await _authProvider.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authProvider,
      builder: (context, _) {
        final user = _authProvider.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.appName),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
          // Drawer
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // En-tête avec avatar
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                  ),
                  accountName: Text(user?.name ?? ''),
                  accountEmail: Text(user?.email ?? ''),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: AppColors.white,
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                // Items navigation
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  selected: _currentIndex == 0,
                  selectedColor: AppColors.primary,
                  onTap: () {
                    setState(() => _currentIndex = 0);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(AppStrings.projects),
                  selected: _currentIndex == 1,
                  selectedColor: AppColors.primary,
                  onTap: () {
                    setState(() => _currentIndex = 1);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.task),
                  title: Text(AppStrings.tasks),
                  selected: _currentIndex == 2,
                  selectedColor: AppColors.primary,
                  onTap: () {
                    setState(() => _currentIndex = 2);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(AppStrings.profile),
                  selected: _currentIndex == 3,
                  selectedColor: AppColors.primary,
                  onTap: () {
                    setState(() => _currentIndex = 3);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                // Déconnexion
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: Text(
                    AppStrings.logout,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          // Corps avec IndexedStack
          body: IndexedStack(
            index: _currentIndex,
            children: [
              DashboardTab(
                authProvider: _authProvider,
                projectProvider: _projectProvider,
                taskProvider: _taskProvider,
              ),
              ProjectsTab(
                authProvider: _authProvider,
                projectProvider: _projectProvider,
              ),
              TasksTab(
                taskProvider: _taskProvider,
                projectProvider: _projectProvider,
              ),
              ProfileTab(
                authProvider: _authProvider,
                projectProvider: _projectProvider,
                taskProvider: _taskProvider,
                onLogout: _logout,
              ),
            ],
          ),
          // BottomNavigationBar
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.folder),
                label: 'Projets',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.task),
                label: 'Tâches',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
          // FAB visible sur Dashboard et Projets
          floatingActionButton: _currentIndex == 0 || _currentIndex == 1
              ? FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            onPressed: () {
              // Navigation vers création projet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectsTab(
                    authProvider: _authProvider,
                    projectProvider: _projectProvider,
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          )
              : null,
        );
      },
    );
  }
}