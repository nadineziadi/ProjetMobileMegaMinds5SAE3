import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/supplement.dart';
import '../../models/category.dart';
import '../../services/supplement_database_service.dart';
import '../../widgets/supplement_card.dart';
import '../../widgets/category_filter.dart';
import 'user_supplement_detail_page.dart';
import 'user_wishlist_page.dart';

enum SortOption {
  priceLowHigh,
  priceHighLow,
  rating,
  name,
}

class UserSupplementsListPage extends StatefulWidget {
  const UserSupplementsListPage({super.key});

  @override
  State<UserSupplementsListPage> createState() => _UserSupplementsListPageState();
}

class _UserSupplementsListPageState extends State<UserSupplementsListPage> {
  List<Supplement> _allSupplements = [];
  List<Supplement> _filteredSupplements = [];
  SupplementCategory? _selectedCategory;
  SortOption _sortOption = SortOption.name;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSupplements();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSupplements() async {
    setState(() => _isLoading = true);
    try {
      final supplements = await SupplementDatabaseService.getAllSupplements();
      setState(() {
        _allSupplements = supplements;
        _filteredSupplements = supplements;
      });
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading supplements: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<Supplement> filtered = _allSupplements;

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((s) => s.type == _selectedCategory).toList();
    }

    // Apply search filter
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(query) ||
            s.brand.toLowerCase().contains(query) ||
            s.description.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sort
    switch (_sortOption) {
      case SortOption.priceLowHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    setState(() {
      _filteredSupplements = filtered;
    });
  }

  Future<void> _toggleFavorite(String supplementId) async {
    final isInWishlist = await SupplementDatabaseService.isInWishlist(supplementId);
    if (isInWishlist) {
      await SupplementDatabaseService.removeFromWishlist(supplementId);
    } else {
      await SupplementDatabaseService.addToWishlist(supplementId);
      if (mounted) {
        _showWishlistNotification();
      }
    }
    setState(() {});
  }

  void _showWishlistNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(CupertinoIcons.heart_fill, color: Colors.white),
            SizedBox(width: 12),
            Text('Added to wishlist'),
          ],
        ),
        backgroundColor: const Color(0xFF32383E),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _showSortOptions() async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Sort By'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _sortOption = SortOption.priceLowHigh);
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Price: Low to High'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _sortOption = SortOption.priceHighLow);
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Price: High to Low'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _sortOption = SortOption.rating);
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Rating'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _sortOption = SortOption.name);
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Name'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF17191C),
      navigationBar: CupertinoNavigationBar(
        heroTag: 'nav-supplements-user',
        transitionBetweenRoutes: false,
        middle: const Text(
          'Supplements',
          style: TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: const Color(0xFF32383E),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const UserWishlistPage(),
                  ),
                );
              },
              child: const Icon(
                CupertinoIcons.cart,
                color: CupertinoColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: _showSortOptions,
              child: const Icon(
                CupertinoIcons.sort_down,
                color: CupertinoColors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search supplements...',
                style: const TextStyle(color: CupertinoColors.white),
                backgroundColor: const Color(0xFF32383E),
              ),
            ),

            // Category filter
            CategoryFilter(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() => _selectedCategory = category);
                _applyFilters();
              },
            ),

            // Supplements list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CupertinoActivityIndicator(radius: 20),
                    )
                  : _filteredSupplements.isEmpty
                      ? const Center(
                          child: Text(
                            'No supplements found',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredSupplements.length,
                          itemBuilder: (context, index) {
                            final supplement = _filteredSupplements[index];
                            return SupplementCard(
                              supplement: supplement,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => UserSupplementDetailPage(
                                      supplement: supplement,
                                    ),
                                  ),
                                );
                                _loadSupplements();
                              },
                              onFavoriteToggle: () => _toggleFavorite(supplement.id),
                              // No onModify or onDelete for users
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
