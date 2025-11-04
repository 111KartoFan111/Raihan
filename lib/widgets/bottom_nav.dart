import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.1), width: 0.5)),
        color: Colors.white,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.warning_rounded,
                label: 'SOS',
                isActive: currentIndex == 0,
                onTap: () => _navigate(context, 0, '/'),
              ),
              _NavItem(
                icon: Icons.location_on_outlined,
                label: 'Службы',
                isActive: currentIndex == 1,
                onTap: () => _navigate(context, 1, '/map'),
              ),
              _NavItem(
                icon: Icons.gavel_outlined,
                label: 'Законы',
                isActive: currentIndex == 3,
                onTap: () => _navigate(context, 3, '/laws'),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Профиль',
                isActive: currentIndex == 4,
                onTap: () => _navigate(context, 4, '/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index, String route) {
    if (index != currentIndex) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0x1A030213) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? const Color(0xFF030213) : const Color(0xFF717182),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? const Color(0xFF030213) : const Color(0xFF717182),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
