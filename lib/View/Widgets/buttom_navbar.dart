import 'package:flutter/material.dart';
import 'package:lingoverse_frontend/View/Pages/main_screen.dart';
import 'package:lingoverse_frontend/View/Pages/league_screen.dart';
import 'package:lingoverse_frontend/View/Pages/activities_screen.dart';
import 'package:lingoverse_frontend/View/Pages/profile_screen.dart';
import 'package:lingoverse_frontend/View/Pages/stage_selection_screen.dart';

class BottomNavbar extends StatefulWidget {
  final int? forcedIndex;

  const BottomNavbar({super.key, this.forcedIndex});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.forcedIndex != null) {
      _selectedIndex = widget.forcedIndex!;
    } else {
      final route = ModalRoute.of(context)?.settings.name;
      _selectedIndex = switch (route) {
        '/league' => 0,
        '/activities' => 1,
        '/profile' => 2,
        _ => 0,
      };
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StageSelectionScreen(),
            settings: const RouteSettings(name: '/league'),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ActivitiesScreen(),
            settings: const RouteSettings(name: '/activities'),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
            settings: const RouteSettings(name: '/profile'),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.transparent,
currentIndex: (_selectedIndex >= 0 && _selectedIndex < 3) ? _selectedIndex : 0,
      onTap: _onItemTapped,
      elevation: 1,
      items: [
        _buildNavItem(context, Icons.emoji_events, 0),
        _buildNavItem(context, Icons.fitness_center, 1),
        _buildNavItem(context, Icons.person, 2),
      ],
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    );
  }

  BottomNavigationBarItem _buildNavItem(BuildContext context, IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.white,
      ),
      label: '',
    );
  }
}
