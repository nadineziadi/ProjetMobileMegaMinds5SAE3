import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../models/supplement.dart';
import '../../models/category.dart';
import '../../services/supplement_database_service.dart';

class AddSupplementPage extends StatefulWidget {
  final Supplement? supplement; // null for add, non-null for edit

  const AddSupplementPage({
    super.key,
    this.supplement,
  });

  @override
  State<AddSupplementPage> createState() => _AddSupplementPageState();
}

class _AddSupplementPageState extends State<AddSupplementPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  // Keys for scrolling to invalid fields
  final GlobalKey _imageKey = GlobalKey();
  final GlobalKey _nameKey = GlobalKey();
  final GlobalKey _brandKey = GlobalKey();
  final GlobalKey _typeKey = GlobalKey();
  final GlobalKey _descriptionKey = GlobalKey();
  final GlobalKey _priceKey = GlobalKey();

  File? _selectedImage;
  XFile? _selectedImageFile;
  SupplementCategory? _selectedType;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  // Validation errors
  String? _imageError;
  String? _nameError;
  String? _brandError;
  String? _typeError;
  String? _descriptionError;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    // Preload data if editing existing supplement
    if (widget.supplement != null) {
      _nameController.text = widget.supplement!.name;
      _brandController.text = widget.supplement!.brand;
      _descriptionController.text = widget.supplement!.description;
      _priceController.text = widget.supplement!.price.toInt().toString();
      _selectedType = widget.supplement!.type;
      
      // Load image if it's a file path
      if (widget.supplement!.imageUrl.isNotEmpty) {
        final file = File(widget.supplement!.imageUrl);
        if (file.existsSync()) {
          _selectedImage = file;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Validation helper methods
  bool _isValidName(String name) {
    final trimmed = name.trim();
    if (trimmed.length < 3) return false;
    
    // Check if contains at least 3 letters
    final letterCount = trimmed.split('').where((c) => RegExp(r'[a-zA-Z]').hasMatch(c)).length;
    if (letterCount < 3) return false;
    
    // Check if contains symbols (not allowed)
    if (RegExp(r'[^a-zA-Z0-9\s]').hasMatch(trimmed)) return false;
    
    // Check if not only numbers
    if (RegExp(r'^\d+$').hasMatch(trimmed)) return false;
    
    return true;
  }

  bool _isValidDescription(String description) {
    final trimmed = description.trim();
    if (trimmed.length < 10) return false;
    
    // Check if contains only letters and numbers (no symbols)
    if (RegExp(r'[^a-zA-Z0-9\s]').hasMatch(trimmed)) return false;
    
    // Check if not all numbers
    if (RegExp(r'^\d+$').hasMatch(trimmed.replaceAll(' ', ''))) return false;
    
    return true;
  }

  bool _isValidPrice(String price) {
    final trimmed = price.trim();
    if (trimmed.isEmpty) return false;
    
    // Only numeric digits allowed (no commas, no points, no symbols)
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) return false;
    
    // Must be greater than 0
    final numValue = int.tryParse(trimmed);
    if (numValue == null || numValue <= 0) return false;
    
    return true;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImageFile = image;
        setState(() {
          _selectedImage = File(image.path);
          _imageError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to pick image: $e'),
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

  Future<void> _pickFileFromSystem() async {
    try {
      // Show loading indicator
      if (mounted) {
        showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const CupertinoAlertDialog(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoActivityIndicator(),
                SizedBox(width: 16),
                Text('Opening file browser...'),
              ],
            ),
          ),
        );
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
        allowMultiple: false,
        dialogTitle: 'Select Supplement Image',
      );

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Validate file size (max 10MB)
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          if (mounted) {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('File Too Large'),
                content: const Text('Please select an image smaller than 10MB.'),
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

        setState(() {
          _selectedImage = file;
          _imageError = null;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image selected: ${result.files.single.name}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);
      }
      
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to pick file: $e\n\nPlease try again or contact support if the problem persists.'),
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

  Future<void> _showImageSourceDialog() async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Image Source'),
        actions: [
          // Prioritize file picker for desktop
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickFileFromSystem();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, color: Colors.blue),
                SizedBox(width: 8),
                Text('Browse Files (Recommended)', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library, color: Colors.green),
                SizedBox(width: 8),
                Text('Gallery'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, color: Colors.orange),
                SizedBox(width: 8),
                Text('Camera'),
              ],
            ),
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

  void _showTypePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: const Color(0xFF32383E),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF17191C),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF32383E), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Type',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Color(0xFFC7F000),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: const Color(0xFF32383E),
                itemExtent: 50,
                scrollController: FixedExtentScrollController(
                  initialItem: _selectedType != null
                      ? SupplementCategory.values.indexOf(_selectedType!)
                      : 0,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedType = SupplementCategory.values[index];
                    _typeError = null;
                  });
                },
                children: SupplementCategory.values.map((category) {
                  return Center(
                    child: Text(
                      category.displayName,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    }
  }

  bool _validateForm() {
    bool isValid = true;
    GlobalKey? firstInvalidKey;

    // Validate image
    if (_selectedImage == null) {
      setState(() => _imageError = 'Image is required');
      isValid = false;
      firstInvalidKey ??= _imageKey;
    } else {
      setState(() => _imageError = null);
    }

    // Validate name
    final nameValue = _nameController.text.trim();
    if (nameValue.isEmpty) {
      setState(() => _nameError = 'Supplement name is required');
      isValid = false;
      firstInvalidKey ??= _nameKey;
    } else if (!_isValidName(nameValue)) {
      setState(() => _nameError = 'Name must have at least 3 letters, can include numbers, but no symbols. Cannot be only numbers.');
      isValid = false;
      firstInvalidKey ??= _nameKey;
    } else {
      setState(() => _nameError = null);
    }

    // Validate brand
    final brandValue = _brandController.text.trim();
    if (brandValue.isEmpty) {
      setState(() => _brandError = 'Brand is required');
      isValid = false;
      firstInvalidKey ??= _brandKey;
    } else {
      setState(() => _brandError = null);
    }

    // Validate type
    if (_selectedType == null) {
      setState(() => _typeError = 'Type is required');
      isValid = false;
      firstInvalidKey ??= _typeKey;
    } else {
      setState(() => _typeError = null);
    }

    // Validate description
    final descValue = _descriptionController.text.trim();
    if (descValue.isEmpty) {
      setState(() => _descriptionError = 'Description is required');
      isValid = false;
      firstInvalidKey ??= _descriptionKey;
    } else if (!_isValidDescription(descValue)) {
      setState(() => _descriptionError = 'Description must be at least 10 characters, letters and numbers only, and not all numbers.');
      isValid = false;
      firstInvalidKey ??= _descriptionKey;
    } else {
      setState(() => _descriptionError = null);
    }

    // Validate price
    final priceValue = _priceController.text.trim();
    if (priceValue.isEmpty) {
      setState(() => _priceError = 'Price is required');
      isValid = false;
      firstInvalidKey ??= _priceKey;
    } else if (!_isValidPrice(priceValue)) {
      setState(() => _priceError = 'Price must be numeric digits only (no commas, no points, no symbols)');
      isValid = false;
      firstInvalidKey ??= _priceKey;
    } else {
      setState(() => _priceError = null);
    }

    // Scroll to first invalid field
    if (!isValid && firstInvalidKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToKey(firstInvalidKey!);
      });
    }

    return isValid;
  }

  Future<void> _saveSupplement() async {
    if (!_validateForm()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Mobile only - use file path directly
      final imagePath = _selectedImage!.path;

      final supplement = Supplement(
        id: widget.supplement?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: imagePath,
        type: _selectedType!,
        // Stock field removed - rating defaults to 0.0 for new supplements
        rating: widget.supplement?.rating ?? 0.0,
        reviewCount: widget.supplement?.reviewCount ?? 0,
        createdAt: widget.supplement?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await SupplementDatabaseService.saveSupplement(supplement);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to save supplement: $e'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF17191C),
      navigationBar: CupertinoNavigationBar(
        heroTag: 'nav-add-supplement',
        transitionBetweenRoutes: false,
        middle: Text(
          widget.supplement == null ? 'Add New Supplement' : 'Edit Supplement',
          style: const TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: const Color(0xFF32383E),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
          color: CupertinoColors.white,
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Picker Section
                Container(
                  key: _imageKey,
                  child: GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF32383E),
                        borderRadius: BorderRadius.circular(12),
                        border: _imageError != null
                            ? Border.all(color: CupertinoColors.systemRed, width: 2)
                            : null,
                      ),
                      child: CustomPaint(
                        painter: DashedBorderPainter(
                          color: _imageError != null
                              ? CupertinoColors.systemRed
                              : const Color(0xFFC7F000),
                          strokeWidth: 2,
                        ),
                        child: (_selectedImage != null)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.arrow_up_circle_fill,
                                    size: 60,
                                    color: _imageError != null
                                        ? CupertinoColors.systemRed
                                        : const Color(0xFFC7F000),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    '+ Add Image',
                                    style: TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                if (_imageError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _imageError!,
                    style: const TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Supplement Name Field
                Container(
                  key: _nameKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Supplement Name',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _nameController,
                        placeholder: 'e.g., Whey Protein Gold',
                        placeholderStyle: TextStyle(
                          color: Colors.grey[400],
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF32383E),
                          borderRadius: BorderRadius.circular(12),
                          border: _nameError != null
                              ? Border.all(color: CupertinoColors.systemRed, width: 2)
                              : null,
                        ),
                        style: const TextStyle(
                          color: CupertinoColors.white,
                        ),
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                        },
                      ),
                      if (_nameError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _nameError!,
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Brand Field
                Container(
                  key: _brandKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Brand',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _brandController,
                        placeholder: 'e.g., Optimum Nutrition',
                        placeholderStyle: TextStyle(
                          color: Colors.grey[400],
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF32383E),
                          borderRadius: BorderRadius.circular(12),
                          border: _brandError != null
                              ? Border.all(color: CupertinoColors.systemRed, width: 2)
                              : null,
                        ),
                        style: const TextStyle(
                          color: CupertinoColors.white,
                        ),
                        onChanged: (_) {
                          if (_brandError != null) {
                            setState(() => _brandError = null);
                          }
                        },
                      ),
                      if (_brandError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _brandError!,
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Type Field (Dropdown)
                Container(
                  key: _typeKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Type',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _showTypePicker,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF32383E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _typeError != null
                                  ? CupertinoColors.systemRed
                                  : (_selectedType != null
                                      ? const Color(0xFFC7F000)
                                      : Colors.transparent),
                              width: _typeError != null ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedType?.displayName ?? 'Select supplement type',
                                style: TextStyle(
                                  color: _selectedType != null
                                      ? CupertinoColors.white
                                      : Colors.grey[400],
                                ),
                              ),
                              Icon(
                                CupertinoIcons.chevron_down,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_typeError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _typeError!,
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Description Field
                Container(
                  key: _descriptionKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _descriptionController,
                        placeholder:
                            'Add notes about flavor, serving size, or personal experience...',
                        placeholderStyle: TextStyle(
                          color: Colors.grey[400],
                        ),
                        padding: const EdgeInsets.all(16),
                        maxLines: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF32383E),
                          borderRadius: BorderRadius.circular(12),
                          border: _descriptionError != null
                              ? Border.all(color: CupertinoColors.systemRed, width: 2)
                              : null,
                        ),
                        style: const TextStyle(
                          color: CupertinoColors.white,
                        ),
                        onChanged: (_) {
                          if (_descriptionError != null) {
                            setState(() => _descriptionError = null);
                          }
                        },
                      ),
                      if (_descriptionError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _descriptionError!,
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Price Field
                Container(
                  key: _priceKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _priceController,
                        placeholder: 'e.g., 4999',
                        placeholderStyle: TextStyle(
                          color: Colors.grey[400],
                          decoration: TextDecoration.none,
                        ),
                        padding: const EdgeInsets.all(16),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Only digits
                        ],
                        decoration: BoxDecoration(
                          color: const Color(0xFF32383E),
                          borderRadius: BorderRadius.circular(12),
                          border: _priceError != null
                              ? Border.all(color: CupertinoColors.systemRed, width: 2)
                              : null,
                        ),
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          decoration: TextDecoration.none,
                        ),
                        suffix: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            'DT',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        onChanged: (_) {
                          if (_priceError != null) {
                            setState(() => _priceError = null);
                          }
                        },
                      ),
                      if (_priceError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _priceError!,
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 12,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: const Color(0xFFC7F000),
                    disabledColor: Colors.grey[600]!,
                    onPressed: _isLoading ? null : _saveSupplement,
                    child: _isLoading
                        ? const CupertinoActivityIndicator()
                        : Text(
                            widget.supplement == null ? 'Save Supplement' : 'Update Supplement',
                            style: const TextStyle(
                              color: Color(0xFF17191C),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );

    final dashPath = _dashPath(path, dashWidth, dashSpace);
    canvas.drawPath(dashPath, paint);
  }

  Path _dashPath(Path path, double dashWidth, double dashSpace) {
    final dashPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    return dashPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
