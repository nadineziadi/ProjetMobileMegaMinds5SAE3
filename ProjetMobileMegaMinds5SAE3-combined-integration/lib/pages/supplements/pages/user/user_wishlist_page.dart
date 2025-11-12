import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/supplement.dart';
import '../../services/supplement_database_service.dart';
import 'payment_screen.dart';

enum SortOption {
  priceLowHigh,
  priceHighLow,
  rating,
  name,
}

class UserWishlistPage extends StatefulWidget {
  const UserWishlistPage({super.key});

  @override
  State<UserWishlistPage> createState() => _UserWishlistPageState();
}

class _UserWishlistPageState extends State<UserWishlistPage> {
  List<Supplement> _wishlist = [];
  List<Supplement> _filteredWishlist = [];
  bool _isLoading = true;
  SortOption _sortOption = SortOption.name;
  final Map<String, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() => _isLoading = true);
    try {
      final wishlist = await SupplementDatabaseService.getWishlist();
      setState(() {
        _wishlist = wishlist;
        _filteredWishlist = wishlist;
        for (final supplement in wishlist) {
          _quantities.putIfAbsent(supplement.id, () => 1);
        }
      });
      _applySort();
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applySort() {
    List<Supplement> sorted = List.from(_wishlist);
    switch (_sortOption) {
      case SortOption.priceLowHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    setState(() {
      _filteredWishlist = sorted;
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
              _applySort();
              Navigator.pop(context);
            },
            child: const Text('Price: Low to High'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _sortOption = SortOption.priceHighLow);
              _applySort();
              Navigator.pop(context);
            },
            child: const Text('Price: High to Low'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _sortOption = SortOption.rating);
              _applySort();
              Navigator.pop(context);
            },
            child: const Text('Rating'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _sortOption = SortOption.name);
              _applySort();
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

  Future<void> _removeFromWishlist(Supplement supplement) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Remove from Wishlist'),
        content: const Text(
          'Are you sure you want to remove this supplement from your wishlist?',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SupplementDatabaseService.removeFromWishlist(supplement.id);
        _loadWishlist();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Removed from wishlist'),
              backgroundColor: const Color(0xFF32383E),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error removing from wishlist: $e');
      }
    }
  }

  Future<void> _handleBuyNow(Supplement supplement) async {
    if (!mounted) return;
    
    final quantity = _quantities[supplement.id] ?? 1;
    
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => PaymentScreen(
          supplement: supplement,
          quantity: quantity,
        ),
      ),
    );
    
    _loadWishlist();
  }
  
  void _increaseQuantity(String supplementId) {
    setState(() {
      _quantities[supplementId] = (_quantities[supplementId] ?? 1) + 1;
    });
  }
  
  void _decreaseQuantity(String supplementId) {
    setState(() {
      final currentQuantity = _quantities[supplementId] ?? 1;
      if (currentQuantity > 1) {
        _quantities[supplementId] = currentQuantity - 1;
      }
    });
  }
  
  int _getQuantity(String supplementId) {
    return _quantities[supplementId] ?? 1;
  }

  double _calculateTotal() {
    return _filteredWishlist
        .map((s) => s.price * _getQuantity(s.id))
        .fold(0.0, (sum, total) => sum + total);
  }

  Widget _buildSupplementImage(String? imageUrl, double width, double height) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF32383E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          CupertinoIcons.photo,
          color: Colors.grey,
          size: 32,
        ),
      );
    }

    try {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            width: width,
            height: height,
            fit: BoxFit.cover,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF32383E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        CupertinoIcons.photo,
        color: Colors.grey,
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF17191C),
      navigationBar: CupertinoNavigationBar(
        heroTag: 'nav-wishlist-user',
        transitionBetweenRoutes: false,
        middle: const Text(
          'My Wishlist',
          style: TextStyle(
            color: CupertinoColors.white,
            decoration: TextDecoration.none,
          ),
        ),
        backgroundColor: const Color(0xFF32383E),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: _showSortOptions,
          child: const Icon(
            CupertinoIcons.sort_down,
            color: CupertinoColors.white,
            size: 24,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CupertinoActivityIndicator(radius: 20),
                    )
                  : _filteredWishlist.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.heart,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your wishlist is empty',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 18,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredWishlist.length,
                          itemBuilder: (context, index) {
                            final supplement = _filteredWishlist[index];
                            final quantity = _getQuantity(supplement.id);
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF32383E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  _buildSupplementImage(supplement.imageUrl, 80, 80),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          supplement.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          supplement.brand,
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              '\$${supplement.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Color(0xFFC7F000),
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                            const Spacer(),
                                            // Quantity controls
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF17191C),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  CupertinoButton(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                                    minSize: 0,
                                                    onPressed: () => _decreaseQuantity(supplement.id),
                                                    child: const Icon(
                                                      CupertinoIcons.minus,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    '$quantity',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      decoration: TextDecoration.none,
                                                    ),
                                                  ),
                                                  CupertinoButton(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                                    minSize: 0,
                                                    onPressed: () => _increaseQuantity(supplement.id),
                                                    child: const Icon(
                                                      CupertinoIcons.plus,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CupertinoButton(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                color: const Color(0xFFC7F000),
                                                borderRadius: BorderRadius.circular(8),
                                                onPressed: () => _handleBuyNow(supplement),
                                                child: const Text(
                                                  'Buy Now',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            CupertinoButton(
                                              padding: const EdgeInsets.all(8),
                                              minSize: 0,
                                              onPressed: () => _removeFromWishlist(supplement),
                                              child: const Icon(
                                                CupertinoIcons.delete,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),

            // Total and checkout button
            if (_filteredWishlist.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF32383E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFFC7F000),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          color: const Color(0xFFC7F000),
                          borderRadius: BorderRadius.circular(12),
                          onPressed: () async {
                            if (_filteredWishlist.isNotEmpty) {
                              final firstItem = _filteredWishlist.first;
                              final quantity = _getQuantity(firstItem.id);
                              
                              await Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => PaymentScreen(
                                    supplement: firstItem,
                                    quantity: quantity,
                                  ),
                                ),
                              );
                              
                              _loadWishlist();
                            }
                          },
                          child: const Text(
                            'Proceed to Payment',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
