import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/custom_button.dart';
import '../../../core/constants/route_constants.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize providers if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistance Msaada 2.0'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(context),
              const SizedBox(height: 24),
              
              // Emergency section
              _buildEmergencySection(context),
              const SizedBox(height: 24),
              
              // Quick actions
              _buildQuickActions(context),
              const SizedBox(height: 24),
              
              // Recent content
              _buildRecentContent(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous n\'êtes pas seul(e). Nous sommes là pour vous aider.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emergency,
            color: Colors.red,
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            'Urgence ?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Si vous êtes en danger immédiat, contactez les services d\'urgence',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: '117 - Police',
                  onPressed: () => _makeEmergencyCall('117'),
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  text: '118 - Pompiers',
                  onPressed: () => _makeEmergencyCall('118'),
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              context,
              icon: Icons.report,
              title: 'Signaler',
              subtitle: 'Faire un signalement',
              onTap: () => Navigator.pushNamed(context, RouteConstants.reportForm),
            ),
            _buildActionCard(
              context,
              icon: Icons.chat,
              title: 'Chat',
              subtitle: 'Parler à un conseiller',
              onTap: () => Navigator.pushNamed(context, RouteConstants.chat),
            ),
            _buildActionCard(
              context,
              icon: Icons.article,
              title: 'Articles',
              subtitle: 'Ressources utiles',
              onTap: () => Navigator.pushNamed(context, RouteConstants.articles),
            ),
            _buildActionCard(
              context,
              icon: Icons.video_library,
              title: 'Vidéos',
              subtitle: 'Contenu éducatif',
              onTap: () => Navigator.pushNamed(context, RouteConstants.videos),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Contenu récent',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, RouteConstants.articles),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3, // Mock data
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Article ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Description de l\'article...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.report),
          label: 'Signalements',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books),
          label: 'Ressources',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Paramètres',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            Navigator.pushNamed(context, RouteConstants.myReports);
            break;
          case 2:
            Navigator.pushNamed(context, RouteConstants.chat);
            break;
          case 3:
            Navigator.pushNamed(context, RouteConstants.articles);
            break;
          case 4:
            Navigator.pushNamed(context, RouteConstants.settings);
            break;
        }
      },
    );
  }

  void _makeEmergencyCall(String number) {
    // This would use the helpers to make an actual phone call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appel d\'urgence au $number'),
        backgroundColor: Colors.red,
      ),
    );
  }
}