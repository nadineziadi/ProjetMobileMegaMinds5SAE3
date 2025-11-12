import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/supplement.dart';
import '../../services/supplement_database_service.dart';
import '../../services/supplement_notification_service.dart';
import '../../widgets/supplement_card.dart';
import 'payment_screen.dart';
import 'supplement_detail_page.dart';

enum SortOption {
  priceLowHigh,
  priceHighLow,
  rating,
  name,
}

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Supplement> _wishlist = [];
  List<Supplement> _filteredWishlist = [];
  bool _isLoading = true;
  SortOption _sortOption = SortOption.name;
  // Track quantity for each supplement by ID
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
        // Initialize quantities to 1 for new items
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
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text('Failed to remove from wishlist: $e'),
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

  Future<void> _handleBuyNow(Supplement supplement) async {
    if (!mounted) return;
    
    final quantity = _quantities[supplement.id] ?? 1;
    
    // Navigate to payment screen with quantity
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => PaymentScreen(
          supplement: supplement,
          quantity: quantity,
        ),
      ),
    );
    
    // Reload wishlist after returning (in case item was purchased)
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

  Future<void> _handleAddToCart() async {
    if (_filteredWishlist.isEmpty) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Empty Wishlist'),
            content: const Text('Your wishlist is empty. Add supplements to your wishlist first.'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // For now, process the first item in the wishlist
    // TODO: Implement multi-item checkout in the future
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
      
      // Reload wishlist after returning
      _loadWishlist();
    }
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
        heroTag: 'nav-wishlist',
        transitionBetweenRoutes: false,
        middle: const Text(
          'Wishlist',
          style: TextStyle(color: CupertinoColors.white),
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
            // Wishlist items list
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
                                  fontSize: 18,
                                  color: Colors.grey[400],
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Add supplements to your wishlist!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
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
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF32383E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  // Image and Name area (clickable)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) => SupplementDetailPage(
                                              supplement: supplement,
                                            ),
                                          ),
                                        ).then((_) {
                                          _loadWishlist();
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          // Image
                                          _buildSupplementImage(
                                            supplement.imageUrl,
                                            80,
                                            80,
                                          ),
                                          const SizedBox(width: 12),
                                          // Name and Price
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  supplement.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: CupertinoColors.white,
                                                    decoration: TextDecoration.none,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${supplement.price.toInt()}DT',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFFC7F000),
                                                    decoration: TextDecoration.none,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Quantity selector and buttons
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Quantity selector: [ - ] quantity [ + ]
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Decrease button
                                          CupertinoButton(
                                            padding: const EdgeInsets.all(4),
                                            minSize: 0,
                                            color: const Color(0xFF32383E),
                                            onPressed: () => _decreaseQuantity(supplement.id),
                                            child: const Icon(
                                              CupertinoIcons.minus,
                                              color: CupertinoColors.white,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Quantity display
                                          Text(
                                            '${_getQuantity(supplement.id)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: CupertinoColors.white,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Increase button
                                          CupertinoButton(
                                            padding: const EdgeInsets.all(4),
                                            minSize: 0,
                                            color: const Color(0xFF32383E),
                                            onPressed: () => _increaseQuantity(supplement.id),
                                            child: const Icon(
                                              CupertinoIcons.plus,
                                              color: CupertinoColors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Buy Now button
                                      CupertinoButton(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        minSize: 0,
                                        color: const Color(0xFFC7F000),
                                        onPressed: () => _handleBuyNow(supplement),
                                        child: const Text(
                                          'Buy Now',
                                          style: TextStyle(
                                            color: Color(0xFF17191C),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Remove from wishlist button (heart)
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        minSize: 0,
                                        onPressed: () => _removeFromWishlist(supplement),
                                        child: const Icon(
                                          CupertinoIcons.heart_fill,
                                          color: CupertinoColors.systemRed,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            // Total and Add to Cart button
            if (!_isLoading && _filteredWishlist.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF32383E),
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFF17191C),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Total
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${total.toInt()}DT',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC7F000),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    // Validate Checkout button
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      color: const Color(0xFFC7F000),
                      onPressed: _handleAddToCart,
                      child: const Text(
                        'Validate Checkout',
                        style: TextStyle(
                          color: Color(0xFF17191C),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
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
