/// Rich lesson model mapped from the `assets/data/lessons.json` file.
///
/// Contains all fields needed by the lesson detail screen (video URL,
/// description, category, tags, etc.). Kept separate from [Lesson]
/// which is a lightweight model used by the mood-suggestion pipeline.
class LessonDetail {
  /// Unique identifier (e.g. `lesson-baby-blues-101`).
  final String id;

  /// URL-friendly slug (e.g. `understanding-baby-blues`).
  final String slug;

  /// Full lesson title.
  final String title;

  /// Content category (e.g. "Postpartum Wellness").
  final String category;

  /// Searchable tags.
  final List<String> tags;

  /// Human-readable video duration (e.g. "04:15").
  final String duration;

  /// Estimated reading time for the description text.
  final String readTime;

  /// Direct URL to the lesson video (.mp4).
  final String videoUrl;

  /// Optional thumbnail image URL.
  final String thumbnailUrl;

  /// Full lesson description / body content.
  final String description;

  const LessonDetail({
    required this.id,
    required this.slug,
    required this.title,
    required this.category,
    required this.tags,
    required this.duration,
    required this.readTime,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.description,
  });

  /// Constructs a [LessonDetail] from a decoded JSON map.
  factory LessonDetail.fromJson(Map<String, dynamic> json) {
    return LessonDetail(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      duration: json['duration'] as String,
      readTime: json['readTime'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      description: json['description'] as String,
    );
  }
}
