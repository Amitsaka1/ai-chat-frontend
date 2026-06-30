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
  late final PageController _pageController;
  static const int _loopMultiplier = 1000;

  @override
  void initState() {
    super.initState();
    final realCount = StoryCardsData.cards.length;
    final startIndex = (_loopMultiplier ~/ 2) * realCount;
    _pageController = PageController(
      viewportFraction: 0.78,
      initialPage: startIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openCard(StoryCardModel card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(storyCard: card),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = StoryCardsData.cards;
    final realCount = cards.length;
    final virtualCount = realCount * _loopMultiplier;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Tellers'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            'choose your storyteller',
            style: TextStyle(
              color: AppTheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: virtualCount,
              itemBuilder: (context, index) {
                final card = cards[index % realCount];
                return _buildCard(card);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(StoryCardModel card) {
    return GestureDetector(
      onTap: () => _openCard(card),
      child: AnimatedBuilder(
        animation: _pageController,
        builder: (context, child) {
          double scale = 1.0;
          if (_pageController.position.haveDimensions) {
            final page = _pageController.page ?? 0;
            final delta = (page - _pageController.page!.roundToDouble()).abs();
            scale = 1.0;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.25),
                    AppTheme.surface,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    card.emoji,
                    style: const TextStyle(fontSize: 72),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      card.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
