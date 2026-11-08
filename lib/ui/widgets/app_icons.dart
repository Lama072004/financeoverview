import 'package:flutter/material.dart';

/// Icons the user can pick for categories. Stored by key.
const categoryIcons = <String, IconData>{
  'salary': Icons.payments_rounded,
  'income': Icons.trending_up_rounded,
  'home': Icons.home_rounded,
  'car': Icons.directions_car_rounded,
  'shield': Icons.shield_rounded,
  'phone': Icons.smartphone_rounded,
  'subscription': Icons.subscriptions_rounded,
  'sport': Icons.sports_soccer_rounded,
  'groceries': Icons.shopping_cart_rounded,
  'education': Icons.school_rounded,
  'health': Icons.favorite_rounded,
  'loan': Icons.credit_card_rounded,
  'savings': Icons.savings_rounded,
  'other': Icons.category_rounded,
  'restaurant': Icons.restaurant_rounded,
  'cafe': Icons.local_cafe_rounded,
  'travel': Icons.flight_rounded,
  'holiday': Icons.beach_access_rounded,
  'pets': Icons.pets_rounded,
  'kids': Icons.child_care_rounded,
  'gift': Icons.card_giftcard_rounded,
  'clothes': Icons.checkroom_rounded,
  'fuel': Icons.local_gas_station_rounded,
  'train': Icons.train_rounded,
  'energy': Icons.bolt_rounded,
  'water': Icons.water_drop_rounded,
  'tools': Icons.build_rounded,
  'movie': Icons.movie_rounded,
  'music': Icons.music_note_rounded,
  'games': Icons.sports_esports_rounded,
  'wellness': Icons.spa_rounded,
  'medical': Icons.local_hospital_rounded,
  'tax': Icons.receipt_long_rounded,
  'shopping': Icons.shopping_bag_rounded,
  'donation': Icons.volunteer_activism_rounded,
  'tech': Icons.laptop_rounded,
  'party': Icons.celebration_rounded,
};

/// Icons the user can pick for accounts.
const accountIcons = <String, IconData>{
  'bank': Icons.account_balance_rounded,
  'wallet': Icons.account_balance_wallet_rounded,
  'savings': Icons.savings_rounded,
  'chart': Icons.show_chart_rounded,
  'pie': Icons.pie_chart_rounded,
  'gold': Icons.diamond_rounded,
  'cash': Icons.payments_rounded,
  'card': Icons.credit_card_rounded,
  'loan': Icons.request_quote_rounded,
  'home': Icons.home_rounded,
  'car': Icons.directions_car_rounded,
  'crypto': Icons.currency_bitcoin_rounded,
};

IconData categoryIcon(String? key) => categoryIcons[key] ?? Icons.category_rounded;

IconData accountIcon(String? key) => accountIcons[key] ?? Icons.account_balance_rounded;
