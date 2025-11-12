import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/supplement.dart';
import '../../models/category.dart';
import '../../services/supplement_database_service.dart';
import '../../widgets/supplement_card.dart';
import '../../widgets/category_filter.dart';
import 'supplement_detail_page.dart';
import 'add_supplement_page.dart';
import 'wishlist_page.dart';

enum SortOption {
  priceLowHigh,
  priceHighLow,
  rating,
  name,
}

class SupplementsListPage extends StatefulWidget {
  const SupplementsListPage({super.key});

  @override
  State<SupplementsListPage> createState() => _SupplementsListPageState();
}

class _SupplementsListPageState extends State<SupplementsListPage> {
  List<Supplement> _allSupplements = [];
  List<Supplement> _filteredSupplements = [];
  SupplementCategory? _selectedCategory;
  SortOption _sortOption = SortOption.name;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSupplements();
    _searchController.addListener(_onSearchChanged);
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
      // Handle error
      debugPrint('Error loading supplements: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    List<Supplement> filtered = List.from(_allSupplements);

    // Category filter
    if (_selectedCategory != null) {
      filtered = filtered
          .where((s) => s.type == _selectedCategory)
          .toList();
    }

    // Search filter
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((s) =>
              s.name.toLowerCase().contains(query) ||
              s.description.toLowerCase().contains(query))
          .toList();
    }

    // Sort
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
      // Show notification when adding to wishlist
      if (mounted) {
        _showWishlistNotification();
      }
    }
    setState(() {});
  }

  void _showWishlistNotification() {
    // Show top notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              CupertinoIcons.check_mark_circled_solid,
              color: CupertinoColors.systemGreen,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Supplement has been successfully added to your wishlist.',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF32383E),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 0,
        ),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _editSupplement(Supplement supplement) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AddSupplementPage(supplement: supplement),
      ),
    );
    if (result == true) {
      _loadSupplements();
    }
  }

  Future<void> _deleteSupplement(Supplement supplement) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Supplement'),
        content: Text('Are you sure you want to delete "${supplement.name}"?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SupplementDatabaseService.deleteSupplement(supplement.id);
        await _loadSupplements();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Supplement deleted'),
              backgroundColor: const Color(0xFF32383E),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text('Failed to delete supplement: $e'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
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
        heroTag: 'nav-supplements-list',
        transitionBetweenRoutes: false,
        middle: const Text(
          'Supplements',
          style: TextStyle(
            color: CupertinoColors.white,
            decoration: TextDecoration.none,
          ),
        ),
        backgroundColor: const Color(0xFF32383E),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const WishlistPage(),
                  ),
                ).then((_) {
                  // Refresh the list when returning from wishlist
                  _loadSupplements();
                });
              },
              child: const Icon(
                CupertinoIcons.cart,
                color: Color(0xFFC7F000),
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const AddSupplementPage(),
                  ),
                );
                // Refresh the list if a supplement was added
                if (result == true) {
                  _loadSupplements();
                }
              },
              child: const Icon(
                CupertinoIcons.add,
                color: Color(0xFFC7F000),
                size: 28,
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
                backgroundColor: const Color(0xFF32383E),
                placeholderStyle: TextStyle(
                  color: Colors.grey[400],
                  decoration: TextDecoration.none,
                ),
                style: const TextStyle(
                  color: CupertinoColors.white,
                  decoration: TextDecoration.none,
                ),
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
                      child: CupertinoActivityIndicator(
                        radius: 20,
                      ),
                    )
                  : _filteredSupplements.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.search,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No supplements found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[400],
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        )
                      : CustomScrollView(
                          slivers: [
                            CupertinoSliverRefreshControl(
                              onRefresh: _loadSupplements,
                            ),
                            SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.66,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final supplement = _filteredSupplements[index];
                                  return SupplementCard(
                                    supplement: supplement,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              SupplementDetailPage(
                                            supplement: supplement,
                                          ),
                                        ),
                                      ).then((_) {
                                        // Refresh after returning from detail page
                                        _loadSupplements();
                                      });
                                    },
                                    onFavoriteToggle: () =>
                                        _toggleFavorite(supplement.id),
                                    onModify: () => _editSupplement(supplement),
                                    onDelete: () => _deleteSupplement(supplement),
                                  );
                                },
                                childCount: _filteredSupplements.length,
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

