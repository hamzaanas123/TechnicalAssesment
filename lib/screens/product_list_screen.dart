import 'dart:async';
import 'package:flutter/material.dart';
import 'package:online_assesment/widgets/product_card.dart';
import 'package:online_assesment/widgets/app_bar.dart';
import 'package:online_assesment/widgets/banner_list.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/constants.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> bannerIndexNotifier = ValueNotifier(0);
  late Timer bannerTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      productProvider.fetchProducts();
    });

    _scrollController.addListener(() {
      final productProvider = context.read<ProductProvider>();
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        productProvider.fetchProducts();
      }
    });

    bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (bannerIndexNotifier.value < banners.length - 1) {
        bannerIndexNotifier.value += 1;
      } else {
        bannerIndexNotifier.value = 0;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    bannerTimer.cancel();
    bannerIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;
    final bgColor = isDark ? Colors.grey[900] : Colors.grey[50];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: bgColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          ProductAppBar(isDark: isDark),
          BannerList(
            banners: banners,
            bannerIndexNotifier: bannerIndexNotifier,
          ),
          FilterRow(isDark: isDark, screenWidth: screenWidth),
          ProductList(isDark: isDark, screenHeight: screenHeight),
        ],
      ),
    );
  }
}

class FilterRow extends StatelessWidget {
  final bool isDark;
  final double screenWidth;

  const FilterRow({super.key, required this.isDark, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    const filters = [
      {'icon': Icons.filter_alt, 'label': 'All'},
      {'icon': Icons.phone_android, 'label': 'Phones'},
      {'icon': Icons.laptop, 'label': 'Laptops'},
      {'icon': Icons.face_retouching_natural, 'label': 'Beauty'},
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03, horizontal: screenWidth * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: filters.map((f) {
            return _FilterIcon(
              icon: f['icon'] as IconData,
              label: f['label'] as String,
              isDark: isDark,
              screenWidth: screenWidth,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FilterIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final double screenWidth;

  const _FilterIcon({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<ProductProvider, String>(
      selector: (_, prov) => prov.selectedCategory,
      builder: (context, selectedCategory, _) {
        final isSelected = selectedCategory == label;

        return InkWell(
          onTap: () => context.read<ProductProvider>().changeCategory(label),
          borderRadius: BorderRadius.circular(8),
          child: Column(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.06,
                backgroundColor: isSelected
                    ? (isDark ? Colors.teal : primaryColor)
                    : (isDark ? Colors.grey[800] : Colors.grey.shade200),
                child: Icon(
                  icon,
                  size: screenWidth * 0.06,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : primaryColor),
                ),
              ),
              SizedBox(height: screenWidth * 0.015),
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? (isDark ? Colors.teal : primaryColor)
                      : (isDark ? Colors.white70 : Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProductList extends StatelessWidget {
  final bool isDark;
  final double screenHeight;

  const ProductList({super.key, required this.isDark, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProv, _) {
        final products = productProv.visibleProducts;
        final loading = productProv.loading;

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, i) {
            if (i >= products.length) {
              return loading
                  ? Padding(
                padding: EdgeInsets.all(screenHeight * 0.02),
                child: Shimmer.fromColors(
                  baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
                  child: Column(
                    children: List.generate(3, (_) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                        height: screenHeight * 0.1,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                      );
                    }),
                  ),
                ),
              )
                  : const SizedBox.shrink();
            }

            final product = products[i];
            final discounted = (product.price * product.discount / 100).toStringAsFixed(0);

            return ProductCard(
              product: product,
              discounted: discounted,
              isDark: isDark,
            );
          }, childCount: products.length + (loading ? 1 : 0)),
        );
      },
    );
  }
}
