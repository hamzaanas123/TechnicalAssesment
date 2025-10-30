import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';

class ProductAppBar extends StatelessWidget {
  final bool isDark;
  const ProductAppBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.read<ThemeProvider>();
    final productProv = context.read<ProductProvider>();

    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return SliverAppBar(
      pinned: false,
      floating: true,
      snap: true,
      expandedHeight: size.height * 0.20, // responsive height
      backgroundColor: isDark ? Colors.grey[900] : primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.only(
            top: size.height * 0.06,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Welcome, Guest 👋",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmall ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: Colors.white,
                        size: isSmall ? 20 : 24,
                      ),
                      Switch(
                        value: isDark,
                        onChanged: themeProv.toggleTheme,
                        activeColor: Colors.white,
                        materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: txtSearchHint,
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.white24, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: productProv.updateSearch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
