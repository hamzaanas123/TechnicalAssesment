import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_assesment/constants/constants.dart';
import 'package:online_assesment/screens/product_detail_screen.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatelessWidget {
  final dynamic product;
  final String discounted;
  final bool isDark;

  const ProductCard({
    super.key,
    required this.product,
    required this.discounted,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cardColor = isDark ? Colors.grey[850] : Colors.grey[100];
    final textPrimaryColor = isDark ? Colors.white : Colors.black87;
    final textSecondaryColor = isDark ? Colors.white70 : Colors.black54;
    final descColor = isDark ? Colors.white60 : Colors.blueGrey.shade800;

    return Card(
      color: cardColor,
      elevation: 3,
      margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: EdgeInsets.all(screenWidth * 0.03),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: product.thumbnail,
            width: screenWidth * 0.18,
            height: screenHeight * 0.09,
            fit: BoxFit.cover,
            placeholder: (_, __) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                color: Colors.white,
                width: screenWidth * 0.18,
                height: screenHeight * 0.09,
              ),
            ),
            errorWidget: (_, __, ___) => Icon(Icons.error, size: screenWidth * 0.08),
          ),
        ),
        title: Text(
          product.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: screenWidth * 0.045,
            color: textPrimaryColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.005),
            Text(
              '${product.brand}  |  ⭐ ${product.rating.toInt()}',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.03,
                color: textSecondaryColor,
              ),
            ),
            SizedBox(height: screenHeight * 0.008),
            Text(
              product.description,
              overflow: TextOverflow.clip,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.028,
                color: descColor,
                height: 1.4,
              ),
            ),
            SizedBox(height: screenHeight * 0.008),
            Row(
              children: [
                Text(
                  '\$$discounted',
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.036,
                    fontWeight: FontWeight.bold,
                    color: successColor,
                  ),
                ),
                SizedBox(width: screenWidth * 0.015),
                Text(
                  '\$${product.price}',
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.03,
                    color: textSecondaryColor,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02, vertical: screenHeight * 0.005),
          decoration: BoxDecoration(
            color: product.stock > 0
                ? successColor.withOpacity(0.15)
                : errorColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            product.stock > 0 ? txtInStock : txtOutOfStock,
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.025,
              fontWeight: FontWeight.bold,
              color: product.stock > 0 ? successColor : errorColor,
            ),
          ),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(id: product.id),
          ),
        ),
      ),
    );
  }
}
