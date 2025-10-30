import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../constants/constants.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final int id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  State<ProductDetailScreen> createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? product;
  bool loading = true;
  late PageController _pageController;
  Timer? bannerTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    bannerTimer?.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    final prov = context.read<ProductProvider>();
    final data = await prov.fetchProduct(widget.id);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      product = data;
      loading = false;
    });

    final totalImages = (product?.images ?? []).length;
    if (totalImages > 1) {
      bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (_pageController.hasClients) {
          int nextPage = _pageController.page!.round() + 1;
          if (nextPage >= totalImages) nextPage = 0;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bgColor = isDark ? Colors.grey[850] : Colors.grey[200];

    if (loading) return showShimmer(isDark, bgColor);
    if (product == null) return showError(bgColor);

    return mainWidget(context, isDark, bgColor, product!);
  }

  Widget showShimmer(bool isDark, Color? bgColor) {
    final base = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final highlight = isDark ? Colors.grey[600]! : Colors.grey[100]!;
    final height = MediaQuery.of(context).size.height * 0.4;

    return Scaffold(
      backgroundColor: bgColor,
      body: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Column(
          children: [
            Container(height: height, color: Colors.white),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    8,
                        (_) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(height: 20, width: double.infinity, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showError(Color? bgColor) {
    return Scaffold(
      backgroundColor: bgColor,
      body: const Center(child: Text(txtFailedToLoad)),
    );
  }

  Widget mainWidget(BuildContext context, bool isDark, Color? bgColor, Product p) {
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final badgeColor = isDark ? Colors.tealAccent[100] : Colors.blueGrey[800];
    final buttonColor = isDark ? Colors.tealAccent[700]! : primaryColor;
    final discounted = (p.price * p.discount / 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          imageSection(p, isDark),
          backButton(),
          detailsCard(p, isDark, titleColor, subtitleColor, badgeColor, buttonColor, discounted),
        ],
      ),
    );
  }

  Widget imageSection(Product p, bool isDark) {
    final images = p.images ?? [];
    final totalImages = images.isNotEmpty ? images.length : 1;
    final height = MediaQuery.of(context).size.height * 0.35;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[300],
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: totalImages,
                itemBuilder: (context, index) {
                  final imageUrl = images.isNotEmpty ? images[index] : p.thumbnail;
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[400],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, size: 60, color: Colors.white70),
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.25),
                        Colors.transparent,
                        Colors.black.withOpacity(0.25),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              if (totalImages > 1)
                Positioned(
                  bottom: 12,
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: totalImages,
                    effect: const WormEffect(
                      dotColor: Colors.white38,
                      activeDotColor: Colors.white,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget backButton() {
    final top = MediaQuery.of(context).padding.top + 8;
    return Positioned(
      top: top,
      left: 16,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.black38,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget detailsCard(Product p, bool isDark, Color titleColor, Color subtitleColor, Color? badgeColor, Color buttonColor, String discounted) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.65,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[200],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -3))],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.title,
                    style: TextStyle(fontSize: screenWidth * 0.065, fontWeight: FontWeight.bold, color: titleColor)),
                SizedBox(height: screenHeight * 0.015),
                Row(
                  children: [
                    category(p.category, badgeColor, isDark),
                    SizedBox(width: screenWidth * 0.03),
                    Text(p.stock > 0 ? txtInStock : txtOutOfStock,
                        style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                            color: p.stock > 0 ? Colors.greenAccent[400] : Colors.redAccent[400])),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                ratingAndPriceRow(p, subtitleColor, buttonColor, discounted, screenWidth),
                SizedBox(height: screenHeight * 0.025),
                featuresRow(isDark, screenWidth),
                SizedBox(height: screenHeight * 0.025),
                Text(p.description,
                    style: TextStyle(fontSize: screenWidth * 0.04, height: 1.5, color: Colors.blueGrey.shade600)),
                SizedBox(height: screenHeight * 0.04),
                addToCartButton(buttonColor, screenWidth),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.only(top: screenHeight * 0.02),
                  child: p.qr != null && p.qr.isNotEmpty
                      ? Image.network(
                    p.qr,
                    height: screenHeight * 0.15,
                    width: screenHeight * 0.15,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                    loadingBuilder: (context, child, loadingProgress) =>
                    loadingProgress == null ? child : const Center(child: CircularProgressIndicator()),
                  )
                      : Icon(Icons.qr_code_2, size: screenHeight * 0.1, color: Colors.grey),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget category(String label, Color? color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget ratingAndPriceRow(Product p, Color subtitleColor, Color buttonColor, String discounted, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: screenWidth * 0.05),
            SizedBox(width: screenWidth * 0.01),
            Text('${p.rating.toStringAsFixed(1)} / 5',
                style: TextStyle(fontWeight: FontWeight.w600, color: subtitleColor, fontSize: screenWidth * 0.035)),
          ],
        ),
        Row(
          children: [
            Text('\$$discounted',
                style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: buttonColor)),
            SizedBox(width: screenWidth * 0.015),
            Text('\$${p.price}',
                style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: subtitleColor,
                    decoration: TextDecoration.lineThrough)),
          ],
        ),
      ],
    );
  }

  Widget featuresRow(bool isDark, double screenWidth) {
    final features = ['Free Shipping', '1-Year Warranty', 'Easy Returns'];
    return Wrap(
      spacing: screenWidth * 0.025,
      runSpacing: screenWidth * 0.02,
      children: features.map((f) => _featureChip(f, isDark, screenWidth)).toList(),
    );
  }

  Widget _featureChip(String label, bool isDark, double screenWidth) {
    final textColor = isDark ? Colors.tealAccent[100] : Colors.blueGrey[800];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[300],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(label, style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.w600, color: textColor)),
    );
  }

  Widget addToCartButton(Color color, double screenWidth) {
    return Center(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.30, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 6,
          shadowColor: Colors.black54,
        ),
        child: const Text('Add To Cart',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white)),
      ),
    );
  }
}
