# SUPPLEMENT MODULE INTEGRATION STATUS

## ✅ COMPLETED PHASES

### Phase 1: Dependencies & Configuration ✓
- [x] Updated `pubspec.yaml` with new dependencies:
  - `flutter_stripe: ^11.5.0`
  - `flutter_dotenv: ^5.2.1`
  - `file_picker: ^8.0.0+1`
  - Updated `image_picker` to `^1.0.7`
- [x] Created `.env` file in project root
- [x] Added `.env` to assets in `pubspec.yaml`

### Phase 2: Services ✓
- [x] Copied and renamed `database_service.dart` → `supplement_database_service.dart`
- [x] Copied and renamed `notification_service.dart` → `supplement_notification_service.dart`
- [x] Copied `recommendation_service.dart` (updated imports)
- [x] Copied `stripe_payment_service.dart`
- [x] Copied `stripe_api_service.dart`
- [x] Copied `email_api_service.dart`

### Phase 3: Models & Widgets ✓
- [x] Copied all models:
  - `category.dart`
  - `supplement.dart`
  - `review.dart`
  - `purchase_history.dart`
- [x] Copied all widgets:
  - `supplement_card.dart` (updated imports)
  - `category_filter.dart`
  - `rating_stars.dart`
  - `interactive_rating_stars.dart`
  - `review_widget.dart`

### Phase 4: Admin Pages (Partial) ✓
- [x] Created folder structure: `lib/pages/supplements/pages/admin/`
- [x] Copied all admin pages:
  - `add_supplement_page.dart`
  - `admin_supplement_page.dart`
  - `supplements_list_page.dart`
  - `supplement_detail_page.dart`
  - `wishlist_page.dart`
  - `payment_screen.dart`
  - `recommendations_page.dart`

## ⚠️ REMAINING TASKS

### Phase 4-5: Update Imports in Admin Pages
**CRITICAL:** All admin pages need import updates:

Replace in ALL admin page files:
```dart
// OLD:
import '../services/database_service.dart';
import '../services/notification_service.dart';

// NEW:
import '../../services/supplement_database_service.dart';
import '../../services/supplement_notification_service.dart';
```

Also update class references:
- `DatabaseService` → `SupplementDatabaseService`
- `NotificationService` → `SupplementNotificationService`

**Files to update:**
1. `add_supplement_page.dart`
2. `admin_supplement_page.dart`
3. `supplements_list_page.dart`
4. `supplement_detail_page.dart`
5. `wishlist_page.dart`
6. `payment_screen.dart`
7. `recommendations_page.dart`

### Phase 5: Create User Pages
Create simplified versions in `lib/pages/supplements/pages/user/`:

1. **user_supplements_list_page.dart** (from `supplements_list_page.dart`)
   - Remove: Add button (FloatingActionButton)
   - Remove: Edit/Delete buttons on cards
   - Keep: Browse, search, filter, view details

2. **user_supplement_detail_page.dart** (from `supplement_detail_page.dart`)
   - Remove: Delete review button
   - Remove: Edit supplement button
   - Keep: View details, add review, like reviews, add to wishlist

3. **user_wishlist_page.dart** (from `wishlist_page.dart`)
   - Remove: Modify/Delete supplement buttons (admin control)
   - Keep: View wishlist, remove from MY wishlist, proceed to payment

4. **Copy as-is:**
   - `payment_screen.dart` → user folder (user-only feature)
   - `recommendations_page.dart` → can be shared or in user folder

### Phase 6: Update Widgets for Role-Based Rendering
Update `supplement_card.dart`:
```dart
class SupplementCard extends StatelessWidget {
  final Supplement supplement;
  final VoidCallback onTap;
  final bool isAdminView;  // ADD THIS
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onModify;   // Only show if isAdminView
  final VoidCallback? onDelete;   // Only show if isAdminView
  
  // Show edit/delete buttons only if isAdminView == true
}
```

Update `review_widget.dart`:
```dart
class ReviewWidget extends StatelessWidget {
  final Review review;
  final bool canDelete;  // ADD THIS
  
  // Show delete button only if canDelete == true
}
```

### Phase 7: Create Router (supplements_page.dart)
Replace the placeholder with:
```dart
import 'package:flutter/material.dart';
import 'package:gymini/pages/user/services/user_service.dart';
import 'pages/admin/supplements_list_page.dart';
import 'pages/user/user_supplements_list_page.dart';

class SupplementsPage extends StatefulWidget {
  const SupplementsPage({super.key});

  @override
  State<SupplementsPage> createState() => _SupplementsPageState();
}

class _SupplementsPageState extends State<SupplementsPage> {
  Future<bool> _checkUserRole() async {
    final userService = UserService();
    final currentUser = await userService.getCurrentUser();
    return currentUser?.isAdmin ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isAdmin = snapshot.data ?? false;

        if (isAdmin) {
          return const AdminSupplementsListPage();
        } else {
          return const UserSupplementsListPage();
        }
      },
    );
  }
}
```

### Phase 8: Update main.dart
Add to `main()` function BEFORE `runApp()`:

```dart
// Add imports at top:
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/supplements/services/supplement_database_service.dart';
import 'pages/supplements/services/supplement_notification_service.dart';
import 'pages/supplements/services/recommendation_service.dart';

// In main() function:
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('🚀 Starting GYMINI App...');

  // ✅ Load environment variables for Stripe
  try {
    await dotenv.load();
    debugPrint('✓ Environment variables loaded');
  } catch (e) {
    debugPrint('⚠ Warning: .env file not found or could not be loaded');
  }

  // ✅ Initialize Stripe
  final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  if (stripeKey.isNotEmpty) {
    Stripe.publishableKey = stripeKey;
    debugPrint('✓ Stripe initialized');
  } else {
    debugPrint('⚠ WARNING: STRIPE_PUBLISHABLE_KEY not found in .env');
  }

  // ... existing SQLite FFI initialization ...

  // ... existing notification initialization ...

  // ... existing nutrition database initialization ...

  // ... existing exercise library seeding ...

  // ✅ Initialize Supplement Services
  try {
    await SupplementDatabaseService.init();
    debugPrint('✓ SupplementDatabaseService initialized');
  } catch (e) {
    debugPrint('✗ SupplementDatabaseService initialization failed: $e');
  }

  try {
    await SupplementNotificationService.init();
    debugPrint('✓ SupplementNotificationService initialized');
  } catch (e) {
    debugPrint('✗ SupplementNotificationService initialization failed: $e');
  }

  try {
    await RecommendationService.init();
    debugPrint('✓ RecommendationService initialized');
  } catch (e) {
    debugPrint('✗ RecommendationService initialization failed: $e');
  }

  // ... existing UserService initialization ...

  runApp(...);
}
```

### Phase 9: Backend Setup
1. Navigate to `stripe_backend` folder
2. Update `.env` with:
   ```
   STRIPE_SECRET_KEY=sk_test_your_secret_key
   EMAIL_USER=your-email@gmail.com
   EMAIL_PASS=your-app-password
   PORT=5000
   ```
3. Run: `npm install`
4. Start server: `node server.js`
5. Update combined project's `.env` with: `BACKEND_URL=http://localhost:5000`

### Phase 10: Testing Checklist
- [ ] Run `flutter pub get` in combined project
- [ ] Build project: `flutter build windows` (or your platform)
- [ ] Test admin login → supplements tab
- [ ] Test user login → supplements tab
- [ ] Verify admin can add/edit/delete supplements
- [ ] Verify user cannot add/edit/delete supplements
- [ ] Test payment flow (user only)
- [ ] Test wishlist functionality
- [ ] Test recommendations
- [ ] Test notifications

## 📝 NOTES

### Import Path Pattern
From admin/user pages to services:
```dart
import '../../services/supplement_database_service.dart';
import '../../services/supplement_notification_service.dart';
import '../../services/recommendation_service.dart';
import '../../services/stripe_payment_service.dart';
import '../../services/stripe_api_service.dart';
import '../../services/email_api_service.dart';
```

From admin/user pages to models:
```dart
import '../../models/supplement.dart';
import '../../models/review.dart';
import '../../models/category.dart';
import '../../models/purchase_history.dart';
```

From admin/user pages to widgets:
```dart
import '../../widgets/supplement_card.dart';
import '../../widgets/review_widget.dart';
import '../../widgets/category_filter.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/interactive_rating_stars.dart';
```

### User ID Integration
Update services to get user ID from UserService:
```dart
// In supplement_database_service.dart, update:
static String get _currentUserId {
  // TODO: Get from UserService
  final userService = UserService();
  final user = userService.getCurrentUser();
  return user?.id ?? 'user_default';
}
```

## 🚀 NEXT STEPS

1. **Update all admin page imports** (manual or script)
2. **Create user pages** by copying admin pages and removing privileges
3. **Update widgets** for role-based rendering
4. **Create router** in supplements_page.dart
5. **Update main.dart** with initialization code
6. **Test thoroughly** with both admin and user accounts

## 📂 FINAL STRUCTURE

```
lib/pages/supplements/
├── models/
│   ├── category.dart
│   ├── supplement.dart
│   ├── review.dart
│   └── purchase_history.dart
├── services/
│   ├── supplement_database_service.dart
│   ├── supplement_notification_service.dart
│   ├── recommendation_service.dart
│   ├── stripe_payment_service.dart
│   ├── stripe_api_service.dart
│   └── email_api_service.dart
├── widgets/
│   ├── supplement_card.dart
│   ├── category_filter.dart
│   ├── rating_stars.dart
│   ├── interactive_rating_stars.dart
│   └── review_widget.dart
├── pages/
│   ├── admin/
│   │   ├── add_supplement_page.dart
│   │   ├── admin_supplement_page.dart
│   │   ├── supplements_list_page.dart (admin version)
│   │   ├── supplement_detail_page.dart (admin version)
│   │   └── wishlist_page.dart (admin version)
│   └── user/
│       ├── user_supplements_list_page.dart
│       ├── user_supplement_detail_page.dart
│       ├── user_wishlist_page.dart
│       ├── payment_screen.dart
│       └── recommendations_page.dart
└── supplements_page.dart (router)
```
