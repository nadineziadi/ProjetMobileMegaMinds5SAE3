import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/supplement.dart';
import '../../services/supplement_database_service.dart';
import '../../widgets/interactive_rating_stars.dart';
import 'add_supplement_page.dart';
import 'supplement_detail_page.dart';

// Simple admin check - in production, this should come from auth service
bool get isAdmin => true; // TODO: Replace with actual admin check

enum SortOption {
  priceLowHigh,
  priceHighLow,
  rating,
  name,
}

class AdminSupplementPage extends StatefulWidget {
  const AdminSupplementPage({super.key});

  @override
  State<AdminSupplementPage> createState() => _AdminSupplementPageState();
}

class _AdminSupplementPageState extends State<AdminSupplementPage> {
  List<Supplement> _allSupplements = [];
  List<Supplement> _filteredSupplements = [];
  SortOption _sortOption = SortOption.name;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!isAdmin) {
      // Redirect if not admin
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return;
    }
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

  Future<void> _addSupplement() async {
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
  }

  Future<void> _editSupplement(Supplement supplement) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AddSupplementPage(supplement: supplement),
      ),
    );
    // Refresh the list if a supplement was updated
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
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SupplementDatabaseService.deleteSupplement(supplement.id);
      _loadSupplements();
    }
  }

  Widget _buildSupplementImage(String imageUrl, double width, double height) {
    if (imageUrl.isEmpty) {
      return _buildFallbackImage(width, height);
    }

    // Check if it's a file path (local) or URL (network)
    final isFile = imageUrl.startsWith('/') || 
                   imageUrl.contains('\\') || 
                   (!imageUrl.startsWith('http') && imageUrl.isNotEmpty);

    if (isFile) {
      // Local file path
      final file = File(imageUrl);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackImage(width, height);
            },
          ),
        );
      } else {
        return _buildFallbackImage(width, height);
      }
    } else {
      // Network URL
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage(width, height);
          },
        ),
      );
    }
  }

  Widget _buildFallbackImage(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        CupertinoIcons.photo,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return const SizedBox.shrink();
    }

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF17191C),
      navigationBar: CupertinoNavigationBar(
        heroTag: 'nav-admin-supplements',
        transitionBetweenRoutes: false,
        middle: const Text(
          'Admin - Supplements',
          style: TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: const Color(0xFF32383E),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _addSupplement,
              child: const Icon(
                CupertinoIcons.add_circled,
                color: Color(0xFFC7F000),
                size: 28,
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
                placeholderStyle: TextStyle(color: Colors.grey[400]),
                style: const TextStyle(color: CupertinoColors.white),
              ),
            ),
            // Supplements list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CupertinoActivityIndicator(radius: 20),
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
                                _searchController.text.isNotEmpty
                                    ? 'No supplements found'
                                    : 'No supplements yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[400],
                                ),
                              ),
                              if (_searchController.text.isEmpty) ...[
                                const SizedBox(height: 8),
                                CupertinoButton(
                                  onPressed: _addSupplement,
                                  child: const Text(
                                    'Add First Supplement',
                                    style: TextStyle(
                                      color: Color(0xFFC7F000),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredSupplements.length,
                          itemBuilder: (context, index) {
                            final supplement = _filteredSupplements[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF32383E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => SupplementDetailPage(
                                  supplement: supplement,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: CupertinoListTile(
                              leading: _buildSupplementImage(supplement.imageUrl, 60, 60),
                              title: Text(
                                supplement.name,
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${supplement.price.toInt()}DT', // Changed from $ to DT format
                                    style: const TextStyle(
                                      color: Color(0xFFC7F000),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InteractiveRatingStars(
                                        currentRating: supplement.rating,
                                        readOnly: true,
                                        size: 14,
                                        spacing: 2,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        supplement.rating.toStringAsFixed(1),
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    supplement.type.displayName,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    minSize: 0,
                                    onPressed: () => _editSupplement(supplement),
                                    child: const Icon(
                                      CupertinoIcons.pencil,
                                      color: Color(0xFFC7F000),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    minSize: 0,
                                    onPressed: () => _deleteSupplement(supplement),
                                    child: const Icon(
                                      CupertinoIcons.delete,
                                      color: CupertinoColors.systemRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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

