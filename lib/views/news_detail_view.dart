import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/routes/app_pages.dart';

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({super.key});

  NewsArticle? get article => Get.arguments is NewsArticle ? Get.arguments as NewsArticle : null;

  @override
  Widget build(BuildContext context) {
    final currentArticle = article;
    if (currentArticle == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notice'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.newspaper_rounded, size: 64, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'No Article Selected',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Article session was reset (e.g. after hot restart). Please return to home.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Get.offAllNamed(Routes.HOME),
                  child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
            foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: currentArticle.urlToImage ?? NewsArticle.getFallbackImage(currentArticle.title),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                    ),
                    errorWidget: (context, url, error) => CachedNetworkImage(
                      imageUrl: NewsArticle.getFallbackImage(currentArticle.title),
                      fit: BoxFit.cover,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent, Colors.black87],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () => _shareArticle(),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) {
                  switch (value) {
                    case 'copy_link':
                      _copyLink();
                      break;
                    case 'open_browser':
                      _openInBrowser();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'copy_link',
                    child: Row(
                      children: [
                        Icon(Icons.copy_rounded, size: 18),
                        SizedBox(width: 12),
                        Text('Copy Link'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'open_browser',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_browser_rounded, size: 18),
                        SizedBox(width: 12),
                        Text('Open in Browser'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (currentArticle.source?.name != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentArticle.source!.name!,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            ' min read',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (currentArticle.publishedAt != null)
                        Text(
                          timeago.format(DateTime.parse(currentArticle.publishedAt!)),
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (currentArticle.title != null)
                    Text(
                      currentArticle.title!,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  if (currentArticle.content != null || currentArticle.description != null)
                    Text(
                      currentArticle.content ?? currentArticle.description!,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 40),
                  if (currentArticle.url != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _openInBrowser(),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text(
                          'Read Full Article on Web',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareArticle() {
    final currentArticle = article;
    if (currentArticle?.url != null) {
      Share.share('\n\nRead more: ');
    }
  }

  void _copyLink() {
    final currentArticle = article;
    if (currentArticle?.url != null) {
      Clipboard.setData(ClipboardData(text: currentArticle!.url!));
      Get.snackbar(
        'Success',
        'Link copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    }
  }

  void _openInBrowser() async {
    final currentArticle = article;
    if (currentArticle?.url != null) {
      final uri = Uri.parse(currentArticle!.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch URL',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    }
  }
}
