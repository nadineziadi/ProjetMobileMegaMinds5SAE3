import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/supplement.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/supplement_card.dart';
import 'supplement_detail_page.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  List<Supplement> _recommendations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    // Only show loading if we don't have cached data
    if (_recommendations.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      // Load recommendations (will use cache if available)
      final recommendations = await RecommendationService.getRecommendations(
        limit: 20,
      );
      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load recommendations: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _toggleFavorite(String supplementId) {
    // This will be handled by the card widget
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF17191C),
      navigationBar: const CupertinoNavigationBar(
        heroTag: 'nav-recommendations',
        transitionBetweenRoutes: false,
        middle: Text('Recommendations'),
        backgroundColor: Color(0xFF32383E),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(
                child: CupertinoActivityIndicator(radius: 20),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        CupertinoButton(
                          onPressed: _loadRecommendations,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _recommendations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.sparkles,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No recommendations yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Start browsing and purchasing to get personalized recommendations!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : CustomScrollView(
                        slivers: [
                          CupertinoSliverRefreshControl(
                            onRefresh: () async {
                              // Clear cache on pull-to-refresh to force reload
                              RecommendationService.clearCache();
                              await _loadRecommendations();
                            },
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Recommended for You',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                          ),
                          SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final supplement = _recommendations[index];
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
                                      _loadRecommendations();
                                    });
                                  },
                                  onFavoriteToggle: () =>
                                      _toggleFavorite(supplement.id),
                                );
                              },
                              childCount: _recommendations.length,
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}

