import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/utils/constants.dart';

class NewsController extends GetxController {
  final NewsService _newsService = NewsService();
  final GetStorage _storage = GetStorage();

  // Observable variables
  final _isLoading = false.obs;
  final _isLoadingMore = false.obs;
  final _articles = <NewsArticle>[].obs;
  final _favoriteArticles = <NewsArticle>[].obs;
  final _selectedCategory = 'general'.obs;
  final _currentIndex = 0.obs;
  final _error = ''.obs;

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  int _searchRequestId = 0;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  List<NewsArticle> get articles => _articles;
  List<NewsArticle> get favoriteArticles => _favoriteArticles;
  String get selectedCategory => _selectedCategory.value;
  int get currentIndex => _currentIndex.value;
  String get error => _error.value;
  List<String> get categories => Constants.categories;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
    fetchTopHeadlines();
  }

  void changeTabIndex(int index) {
    _currentIndex.value = index;
  }

  Future<void> fetchTopHeadlines({String? category}) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      _currentPage = 1;
      _hasMore = true;

      final response = await _newsService.getTopHeadlines(
        category: category ?? _selectedCategory.value,
        page: _currentPage,
        pageSize: _pageSize,
      );

      // Restore favorite status
      for (var article in response.articles) {
        article.isFavorite = _favoriteArticles.any(
          (fav) => fav.url == article.url,
        );
      }

      _articles.value = response.articles;
      if (response.articles.length < _pageSize) {
        _hasMore = false;
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load news: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadMoreNews() async {
    if (_isLoadingMore.value || !_hasMore) return;

    try {
      _isLoadingMore.value = true;
      _currentPage++;

      final response = await _newsService.getTopHeadlines(
        category: _selectedCategory.value,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (response.articles.isEmpty) {
        _hasMore = false;
      } else {
        for (var article in response.articles) {
          article.isFavorite = _favoriteArticles.any(
            (fav) => fav.url == article.url,
          );
        }
        _articles.addAll(response.articles);
        if (response.articles.length < _pageSize) {
          _hasMore = false;
        }
      }
    } catch (e) {
      _currentPage--;
      Get.snackbar(
        'Error',
        'Failed to load more news',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingMore.value = false;
    }
  }

  Future<void> refreshNews() async {
    await fetchTopHeadlines();
  }

  void selectCategory(String category) {
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;
      fetchTopHeadlines(category: category);
    }
  }

  Future<void> searchNews(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;
    final requestId = ++_searchRequestId;

    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _newsService.searchNews(query: normalizedQuery);
      if (requestId != _searchRequestId) return;

      for (var article in response.articles) {
        article.isFavorite = _favoriteArticles.any(
          (fav) => fav.url == article.url,
        );
      }

      _articles.value = response.articles;
    } catch (e) {
      if (requestId != _searchRequestId) return;
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to search news: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (requestId == _searchRequestId) {
        _isLoading.value = false;
      }
    }
  }

  void loadFavorites() {
    try {
      final List<dynamic>? storedFavorites = _storage.read<List<dynamic>>(
        'favorites',
      );
      if (storedFavorites != null) {
        _favoriteArticles.value = storedFavorites
            .map(
              (item) => NewsArticle.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  void saveFavorites() {
    try {
      final listToStore = _favoriteArticles
          .map((article) => article.toJson())
          .toList();
      _storage.write('favorites', listToStore);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  void toggleFavorite(NewsArticle article) {
    article.isFavorite = !article.isFavorite;

    if (article.isFavorite) {
      if (!_favoriteArticles.any((fav) => fav.url == article.url)) {
        _favoriteArticles.add(article);
      }
      Get.snackbar(
        'Bookmarked',
        'Added to your bookmarks',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } else {
      _favoriteArticles.removeWhere((fav) => fav.url == article.url);
      Get.snackbar(
        'Removed Bookmark',
        'Removed from your bookmarks',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }

    saveFavorites();
    _articles.refresh();
    _favoriteArticles.refresh();
  }

  bool isArticleFavorite(NewsArticle article) {
    return _favoriteArticles.any((fav) => fav.url == article.url);
  }
}
