import 'package:flutter/material.dart';


const String appTitle = 'Products App';
const String baseUrl = 'https://dummyjson.com/products';

const int pageLimit = 10;

const String txtSearchHint = 'Search products...';
const String txtInStock = 'In Stock';
const String txtOutOfStock = 'Out of Stock';
const String txtLoading = 'Loading...';
const String txtNoData = 'No products found';
const String txtFailedToLoad = 'Failed to load product';
const String txtMockReviews = 'Mock Reviews';
const String txtReview1 = '⭐ 5/5   Excellent quality';
const String txtReview2 = '⭐ 4/5   Good for daily use';
const String txtPriceLabel = 'Price: ';
const String txtCategoryAll = 'All';
const String txtFilterLabel = 'Filter by Category';
const String txtQrPrefix = 'QR: ';
const String txtDarkMode = 'Dark Mode';

const Color primaryColor = Colors.teal;
const Color successColor = Colors.green;
const Color errorColor = Colors.red;
const Color textGrey = Colors.grey;


final List<Map<String, String>> banners = [
  {'img': 'https://picsum.photos/400/200?1', 'txt': 'Big Sale Up to 50% OFF'},
  {'img': 'https://picsum.photos/400/200?2', 'txt': 'New Arrivals Just In!'},
  {'img': 'https://picsum.photos/400/200?3', 'txt': 'Special Weekend Deals'},
]; // Will replace with active promotions