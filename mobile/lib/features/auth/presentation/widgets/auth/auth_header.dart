import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthHeader extends StatelessWidget {
  final double imageHeight;
  final String imagePath;
  final String title;
  final String description;

  const AuthHeader({
    super.key,
    required this.imageHeight,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const logoPath = 'assets/images/logo/loombo-white.png';

    return SizedBox(
      width: double.infinity,
      height: imageHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: Colors.black12),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xAA0E3256),
                    Color(0xCC0C2947),
                    Color(0xE60A2038),
                  ],
                  stops: [0.0, 0.52, 1.0],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 10, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              logoPath,
                              height: 50,
                              semanticLabel: title,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'LoomBo',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (context.canPop())
                      IconButton(
                        onPressed: context.pop,
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 20,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
