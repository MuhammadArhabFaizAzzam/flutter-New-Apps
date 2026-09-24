class NewsArticle {
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;
  final Source? source;
  bool isFavorite;

  static const List<String> fallbackImages = [
    'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=800&auto=format&fit=crop&q=60', // Newspaper / Journal
    'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800&auto=format&fit=crop&q=60', // Media / Press
    'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop&q=60', // Global Tech
    'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&auto=format&fit=crop&q=60', // Business / Skyline
    'https://images.unsplash.com/photo-1495020689067-958852a7765e?w=800&auto=format&fit=crop&q=60', // Breaking News
    'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?w=800&auto=format&fit=crop&q=60', // Finance & Markets
    'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&auto=format&fit=crop&q=60', // Technology & Science
    'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800&auto=format&fit=crop&q=60', // Modern Office
  ];

  static String getFallbackImage(String? seed) {
    if (seed == null || seed.isEmpty) return fallbackImages[0];
    final int index = seed.hashCode.abs() % fallbackImages.length;
    return fallbackImages[index];
  }

  NewsArticle({
    this.title,
    this.description,
    this.url,
    String? urlToImage,
    this.publishedAt,
    this.content,
    this.source,
    this.isFavorite = false,
  }) : urlToImage = (urlToImage == null || urlToImage.isEmpty || !urlToImage.startsWith('http') || urlToImage.contains('removed'))
          ? getFallbackImage(title)
          : urlToImage;

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    String? rawImage = json['urlToImage'];
    final title = json['title'] as String?;
    if (rawImage == null || rawImage.isEmpty || !rawImage.startsWith('http') || rawImage.contains('removed')) {
      rawImage = getFallbackImage(title);
    }

    return NewsArticle(
      title: title,
      description: json['description'],
      url: json['url'],
      urlToImage: rawImage,
      publishedAt: json['publishedAt'],
      content: json['content'],
      source: json['source'] != null ? Source.fromJson(json['source']) : null,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
      'source': source?.toJson(),
      'isFavorite': isFavorite,
    };
  }
}

class Source {
  final String? id;
  final String? name;

  Source({this.id, this.name});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
