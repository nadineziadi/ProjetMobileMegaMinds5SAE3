import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryFilter extends StatefulWidget {
  final SupplementCategory? selectedCategory;
  final Function(SupplementCategory?) onCategorySelected;

  const CategoryFilter({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = SupplementCategory.values;

    return SizedBox(
      height: 50,
      child: Row(
        children: [
          // Left arrow button
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            minSize: 0,
            onPressed: () {
              if (_scrollController.hasClients && _scrollController.offset > 0) {
                _scrollLeft();
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[800]?.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.chevron_left,
                size: 16,
                color: CupertinoColors.white,
              ),
            ),
          ),
          // Category chips list
          Expanded(
            child: ListView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              children: [
                // "All" option
                _CategoryChip(
                  label: 'All',
                  isSelected: widget.selectedCategory == null,
                  onTap: () => widget.onCategorySelected(null),
                ),
                const SizedBox(width: 8),
                // Category options
                ...categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryChip(
                      label: category.displayName,
                      isSelected: widget.selectedCategory == category,
                      onTap: () => widget.onCategorySelected(category),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Right arrow button
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            minSize: 0,
            onPressed: () {
              if (_scrollController.hasClients) {
                final maxScroll = _scrollController.position.maxScrollExtent;
                if (_scrollController.offset < maxScroll) {
                  _scrollRight();
                }
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[800]?.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFC7F000)
              : const Color(0xFF32383E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC7F000)
                : Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? const Color(0xFF17191C)
                  : CupertinoColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

