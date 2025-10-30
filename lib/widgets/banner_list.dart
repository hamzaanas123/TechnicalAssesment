
import 'package:flutter/material.dart';

class BannerList extends StatelessWidget {
  final List<Map<String, String>> banners;
  final ValueNotifier<int> bannerIndexNotifier;

  const BannerList({
    super.key,
    required this.banners,
    required this.bannerIndexNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ValueListenableBuilder<int>(
          valueListenable: bannerIndexNotifier,
          builder: (_, index, __) {
            final banner = banners[index];
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Container(
                key: ValueKey(index),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(banner['img']!),
                    fit: BoxFit.cover,
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    banner['txt']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
