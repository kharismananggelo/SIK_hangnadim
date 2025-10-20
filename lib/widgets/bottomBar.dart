import 'package:flutter/material.dart';

class CustomBottomToolbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  final List<BottomToolbarItem> items;

  const CustomBottomToolbar({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = currentIndex == index;
          
          return _buildToolbarItem(
            icon: item.icon,
            activeIcon: item.activeIcon,
            label: item.label,
            isActive: isActive,
            onTap: () => onTabChanged(index),
          );
        }),
      ),
    );
  }

  Widget _buildToolbarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required Function onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(),
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? Colors.blue : Colors.grey,
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.blue : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomToolbarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomToolbarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}