class StoryCardModel {
  final String id;
  final String title;
  final String emoji;
  final String genre;
  final String systemPrompt;

  const StoryCardModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.genre,
    required this.systemPrompt,
  });
}
