import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../presentation/resourses/app_colors.dart';

class BottomBar extends StatelessWidget {
  final ValueChanged<int> onChanged;
  final int selectedIndex;

  const BottomBar({super.key, required this.onChanged, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 75,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BottomNavigationItem(
            index: 0,
            selectedIndex: selectedIndex,
            label: "Ana səhifə",
            iconPath: 'asset/fi-sr-home.svg',
            onChanged: (index) {
              onChanged(index);
            },
          ),
          BottomNavigationItem(
            index: 1,
            selectedIndex: selectedIndex,
            label: "Xəritə",
            iconPath: 'asset/fi-sr-heart.svg',
            onChanged: (index) {
              onChanged(index);
            },
          ),
          BottomNavigationItem(
            index: 2,
            selectedIndex: selectedIndex,
            label: "Rezervasiya",
            iconPath: 'asset/fi-sr-apps.svg',
            onChanged: (index) {
              onChanged(index);
            },
          ),
          BottomNavigationItem(
            index: 3,
            selectedIndex: selectedIndex,
            label: "AI-Chat",
            iconPath: 'asset/fi-sr-ff.svg',
            size: 22,
            onChanged: (index) {
              onChanged(index);
            },
          ),
          BottomNavigationItem(
            index: 4,
            selectedIndex: selectedIndex,
            label: "Profil",
            iconPath: 'asset/fi-sr-user.svg',
            onChanged: (index) {
              onChanged(index);
            },
          ),
        ],
      ),
    );
  }
}

class BottomNavigationItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final String label;
  final String iconPath;
  final double? size ;
  final ValueChanged<int> onChanged;

  const BottomNavigationItem({
    Key? key,
    required this.index,
    required this.selectedIndex,
    required this.label,
    required this.iconPath,
    required this.onChanged,
      this.size = 26,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onChanged(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 15,
            width: 20,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.appColor : null,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6, top: 2),
            child: SvgPicture.asset(
              iconPath,
              color: isSelected ? AppColors.appColor : null,
              height: size,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.appColor : null,
              fontSize: 9,
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
