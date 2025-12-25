import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/browser_provider.dart';
import '../utils/constants.dart';

class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrowserProvider>();
    final isBookmarked = provider.isBookmarked(provider.currentTab.url);

    return BottomNavigationBar(
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_outline, color: AppConstants.primaryColor),
          label: 'Bookmarks',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      onTap: (index) {
        // Handle navigation: index 1 should open bookmarks sheet
        // We cannot directly change parent state here; the parent scaffold listens to taps.
      },
    );
  }
}