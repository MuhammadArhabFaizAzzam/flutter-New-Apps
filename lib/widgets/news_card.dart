import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:news_app/models/news_article.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/utils/app_colors.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsCard({super.key, required this.article, required this.onTap});

  void _showTeaserBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.secondary),
                      SizedBox(width: 6),
                      Text(
                        'AI SUMMARY TEASER',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (article.source?.name != null)
                  Text(
                    article.source!.name!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              article.title ?? 'No title available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              article.description ?? 'Tap below to read the full story and discover why this matters.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkDivider : AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '💡 Why read this? Uncovers key insights and breaking context behind this headline.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.divider),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Dismiss', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onTap();
                    },
                    child: const Text('Read Full Article', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final NewsController controller = Get.find<NewsController>();
    final hasValidImage = article.urlToImage != null && article.urlToImage!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkDivider.withOpacity(0.6) : AppColors.divider.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : const Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _showTeaserBottomSheet(context, isDark),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail with robust Image.network fallback instead of failing on strict CORS/cache issues
                Hero(
                  tag: article.url ?? article.title ?? 'news_img',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: hasValidImage
                        ? Image.network(
                            article.urlToImage!,
                            width: 95,
                            height: 95,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 95,
                                height: 95,
                                color: isDark ? Colors.grey[850] : Colors.grey[100],
                                child: Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail(isDark),
                          )
                        : _buildFallbackThumbnail(isDark),
                  ),
                ),
                
                const SizedBox(width: 16),

                // Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (article.source?.name != null)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(0.12),
                                      AppColors.primary.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  article.source!.name!,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Obx(() {
                            final isFav = controller.isArticleFavorite(article);
                            return Material(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                onTap: () => controller.toggleFavorite(article),
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                    size: 18,
                                    color: isFav ? AppColors.secondary : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (article.title != null)
                        Text(
                          article.title!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          if (article.publishedAt != null)
                            Text(
                              timeago.format(DateTime.parse(article.publishedAt!)),
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail(bool isDark) {
    final fallbackUrl = NewsArticle.getFallbackImage(article.title);
    return CachedNetworkImage(
      imageUrl: fallbackUrl,
      width: 95,
      height: 95,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: 95,
        height: 95,
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: 95,
        height: 95,
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        child: const Center(
          child: Icon(Icons.newspaper_rounded, size: 32, color: AppColors.primary),
        ),
      ),
    );
  }
}
