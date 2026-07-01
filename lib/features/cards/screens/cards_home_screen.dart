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

          const SizedBox(height: 16),

          // Cards grid
          Expanded(
            child: _pagedCards.isEmpty
                ? const Center(
                    child: Text(
                      'No cards found',
                      style:
                          TextStyle(color: AppTheme.onSurfaceVariant),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: _pagedCards.length,
                    itemBuilder: (context, index) {
                      return _buildCard(_pagedCards[index]);
                    },
                  ),
          ),

          // Pagination
          if (_totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: AppTheme.onSurfaceVariant),
                    onPressed: _currentPage > 0
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  Text(
                    '${_currentPage + 1} / $_totalPages',
                    style: const TextStyle(
                        color: AppTheme.onSurfaceVariant, fontSize: 13),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: AppTheme.onSurfaceVariant),
                    onPressed: _currentPage < _totalPages - 1
                        ? () => setState(() => _currentPage++)
                        : null,
                  ),
                ],
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(card.emoji,
                style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            // Auto scroll title
            SizedBox(
              height: 36,
              child: _ScrollingText(text: card.title),
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

class _ScrollingTextState extends State<_ScrollingText>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  Future<void> _startScroll() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    while (mounted) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 3),
          curve: Curves.linear,
        );
        await Future.delayed(const Duration(milliseconds: 500));
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
    _animController.dispose();
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
            color: AppTheme.onSurface,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
