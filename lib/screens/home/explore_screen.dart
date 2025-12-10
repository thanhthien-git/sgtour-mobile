import 'package:flutter/material.dart';
import '../../models/location_model.dart';
import '../../models/category_model.dart';
import '../../utils/extensions/localization_extension.dart';
import '../../widgets/common/base_scaffold.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/cards/location_card.dart';
import '../../widgets/cards/category_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<LocationModel> _nearbyLocations = const [
    LocationModel(
      id: '1',
      name: 'Landmark 81',
      address: 'Tp Hồ Chí Minh',
      imageUrl: 'assets/images/landmark81.jpg',
      rating: 4.8,
    ),
    LocationModel(
      id: '2',
      name: 'Landmark 81',
      address: 'Tp Hồ Chí Minh',
      imageUrl: 'assets/images/landmark81.jpg',
      rating: 4.8,
    ),
    LocationModel(
      id: '3',
      name: 'Landmark 81',
      address: 'Tp Hồ Chí Minh',
      imageUrl: 'assets/images/landmark81.jpg',
      rating: 4.8,
    ),
  ];

  List<CategoryModel> _getCategories(BuildContext context) {
    final l10n = context.l10n;
    return [
      CategoryModel(
        id: '1',
        name: l10n.category_food,
        imageUrl: 'assets/images/food.jpg',
        icon: Icons.restaurant_outlined,
      ),
      CategoryModel(
        id: '2',
        name: l10n.category_culture,
        imageUrl: 'assets/images/culture.jpg',
        icon: Icons.account_balance_outlined,
      ),
      CategoryModel(
        id: '3',
        name: l10n.category_shopping,
        imageUrl: 'assets/images/shopping.jpg',
        icon: Icons.shopping_bag_outlined,
      ),
      CategoryModel(
        id: '4',
        name: l10n.category_entertainment,
        imageUrl: 'assets/images/entertainment.jpg',
        icon: Icons.celebration_outlined,
      ),
    ];
  }

  final String _currentLocation = 'Thành phố Hồ Chí Minh';

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Search Bar
              SearchBarWidget(
                hintText: _currentLocation,
                onTap: _handleSearchTap,
                onAiTap: _handleAiTap,
              ),

              const SizedBox(height: 32),

              // Nearby Locations Section
              SectionHeader(title: context.l10n.home_exploreNearby),
              const SizedBox(height: 16),
              _buildNearbyLocations(),

              const SizedBox(height: 32),

              // Categories Section
              SectionHeader(title: context.l10n.home_categories),
              const SizedBox(height: 16),
              _buildCategories(context),

              // Bottom padding for nav bar
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyLocations() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _nearbyLocations.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final location = _nearbyLocations[index];
          return LocationCard(
            location: location,
            onTap: () => _handleLocationTap(location),
          );
        },
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = _getCategories(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((category) {
        return CategoryCard(
          category: category,
          onTap: () => _handleCategoryTap(category),
        );
      }).toList(),
    );
  }

  void _handleSearchTap() {
    // Navigate to search screen
    debugPrint('Search tapped');
  }

  void _handleAiTap() {
    // Navigate to AI assistant
    debugPrint('AI tapped');
  }

  void _handleLocationTap(LocationModel location) {
    // Navigate to location detail
    debugPrint('Location tapped: ${location.name}');
  }

  void _handleCategoryTap(CategoryModel category) {
    // Navigate to category listing
    debugPrint('Category tapped: ${category.name}');
  }
}
