import 'package:flutter/material.dart';
import '../models/story_card_model.dart';
import '../data/story_cards_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../chat/screens/chat_screen.dart';

class CardsHomeScreen extends StatefulWidget {
  const CardsHomeScreen({super.key});

  @override
  State<CardsHomeScreen> createState() => _CardsHomeScreenState();
}

class _CardsHomeScreenState extends State<CardsHomeScreen> {
  final Set<String> _selectedGenres = {};
  int _currentPage = 0;
  static const int _perPage = 10;

  List<StoryCardModel> get _filteredCards {
    if (_selectedGenres.isEmpty) return StoryCardsData.cards;
    return StoryCardsData.cards
        .where((c) => _selectedGenres.contains(c.genre))
        .toList();
  }

  List<StoryCardModel> get _pagedCards {
    final all = _filteredCards;
    final start = _currentPage * _perPage;
    final end = (start + _perPage).clamp(0, all.length);
    if (start >= all.length) return [];
    return all.sublist(start, end);
  }

  int get _totalPages => (_filteredCards.length / _perPage).ceil();

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final genres = StoryCardsData.genres;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Story Tellers'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category horizontal scroll
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: genres.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = genres[index];
                final selected = _selectedGenres.contains(genre);
                return GestureDetector(
                  onTap: () => _toggleGenre(genre),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      genre,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppTheme.onSurfaceVariant,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Cards grid — sirf upar niche scroll
          Expanded(
            child: _pagedCards.isEmpty
                ? const Center(
                    child: Text(
                      'No cards found',
                      style: TextStyle(color: AppTheme.onSurfaceVariant),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    physics: const ClampingScrollPhysics(), // left-right swipe band
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: _filteredCards.length,
                    itemBuilder: (context, index) {
                      return _buildCard(_filteredCards[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(StoryCardModel card) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(storyCard: card),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withValues(alpha: 0.2),
              AppTheme.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Title upar box mein — auto scroll
            Container(
              width: double.infinity,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              alignment: Alignment.center,
              child: _ScrollingText(text: card.title),
            ),

            // Emoji center mein
            Expanded(
              child: Center(
                child: Text(
                  card.emoji,
                  style: const TextStyle(fontSize: 38),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollingText extends StatefulWidget {
  final String text;
  const _ScrollingText({required this.text});

  @override
  State<_ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<_ScrollingText> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  Future<void> _startScroll() async {
    await Future.delayed(const Duration(seconds: 1));
    while (mounted) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 3),
          curve: Curves.linear,
        );
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        await Future.delayed(const Duration(seconds: 1));
      } else {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          widget.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
