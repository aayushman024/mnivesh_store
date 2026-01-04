import 'package:flutter/material.dart';
import 'package:mnivesh_store/Themes/AppTextStyle.dart';

class HomeSliverAppBar extends StatelessWidget {
  final String userName;
  final String storeName;

  const HomeSliverAppBar({
    super.key,
    this.userName = "Aayushman",
    this.storeName = "mNivesh Store",
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) return "Good Morning, ☀️";
    if (hour >= 12 && hour < 16) return "Good Afternoon, 🌤️";
    return "Good Evening, 🌙";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: 140.0,
      pinned: true,
      floating: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,

      actions: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storefront_rounded,
                  size: 16,
                  // 70% White, 30% Primary
                  color: Color.lerp(colorScheme.primary, Colors.white, 0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  storeName,
                  // Same lighter color for text
                  style: AppTextStyle.bold.small(
                    Color.lerp(colorScheme.primary, Colors.white, 0.7)!,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],

      // The Expanding/Collapsing Area
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        expandedTitleScale: 1.5,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _getGreeting(),
              style: AppTextStyle.normal.small(Colors.grey[400]!).copyWith(
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              userName,
              style: AppTextStyle.bold.normal(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}