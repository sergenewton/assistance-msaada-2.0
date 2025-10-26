import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../screens/home/home_screen.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: RouteConstants.home,
    routes: [
      // Home route
      GoRoute(
        path: RouteConstants.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Report routes
      GoRoute(
        path: RouteConstants.reportForm,
        name: 'report-form',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Formulaire de signalement'),
          ),
        ),
      ),
      
      GoRoute(
        path: RouteConstants.reportChat,
        name: 'report-chat',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Chat de signalement'),
          ),
        ),
      ),
      
      GoRoute(
        path: RouteConstants.reportVoice,
        name: 'report-voice',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Signalement vocal'),
          ),
        ),
      ),
      
      GoRoute(
        path: RouteConstants.myReports,
        name: 'my-reports',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Mes signalements'),
          ),
        ),
      ),
      
      // Content routes
      GoRoute(
        path: RouteConstants.articles,
        name: 'articles',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Articles'),
          ),
        ),
      ),
      
      GoRoute(
        path: RouteConstants.videos,
        name: 'videos',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Vidéos'),
          ),
        ),
      ),
      
      // Chat routes
      GoRoute(
        path: RouteConstants.chat,
        name: 'chat',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Chat'),
          ),
        ),
      ),
      
      // Settings routes
      GoRoute(
        path: RouteConstants.settings,
        name: 'settings',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Paramètres'),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'La page que vous cherchez n\'existe pas.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteConstants.home),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}

// Navigation helper methods
class AppNavigation {
  static void goToHome(BuildContext context) {
    context.go(RouteConstants.home);
  }
  
  static void goToReportForm(BuildContext context) {
    context.push(RouteConstants.reportForm);
  }
  
  static void goToMyReports(BuildContext context) {
    context.push(RouteConstants.myReports);
  }
  
  static void goToChat(BuildContext context) {
    context.push(RouteConstants.chat);
  }
  
  static void goToArticles(BuildContext context) {
    context.push(RouteConstants.articles);
  }
  
  static void goToVideos(BuildContext context) {
    context.push(RouteConstants.videos);
  }
  
  static void goToSettings(BuildContext context) {
    context.push(RouteConstants.settings);
  }
  
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteConstants.home);
    }
  }
}