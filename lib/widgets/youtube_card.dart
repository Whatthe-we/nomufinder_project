import 'package:flutter/material.dart';
import '../models/youtube_video.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html_unescape/html_unescape.dart';

class YoutubeCard extends StatelessWidget {
  final YoutubeVideo video;
  final double width;
  final double height;
  final double thumbnailHeight;
  final double thumbnailWidth;
  final bool isHorizontal;
  final String variant; // 'news', 'law', 'edu', 'default'
  final EdgeInsets margin;
  final EdgeInsets padding;

  const YoutubeCard({
    Key? key,
    required this.video,
    this.width = 320,
    this.height = 220,
    this.thumbnailHeight = 140,
    this.thumbnailWidth = 120,
    this.isHorizontal = false,
    this.variant = 'default',
    this.margin = const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
  }) : super(key: key);

  void _launchYoutube(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  TextStyle _getTitleStyle() {
    switch (variant) {
      case 'law':
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        );
      case 'news':
        return const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        );
      case 'edu':
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        );
      default:
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        );
    }
  }

  String _formatPublishedAt(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final unescape = HtmlUnescape();
    final decodedTitle = unescape.convert(video.title);
    final decodedDesc = unescape.convert(video.description ?? "");

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 2,
      margin: margin,
      child: InkWell(
        onTap: () => _launchYoutube(video.videoId),
        child: Padding(
          padding: padding,
          child: isHorizontal
              ? Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: thumbnailWidth,
                  height: thumbnailHeight,
                  child: Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      decodedTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _getTitleStyle(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      decodedDesc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: SizedBox(
                  width: width,
                  height: thumbnailHeight,
                  child: Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: variant == 'law' ? 70 : null,
                width: variant == 'law' ? width : null,
                alignment: Alignment.centerLeft,
                child: Text(
                  decodedTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _getTitleStyle(),
                ),
              ),
              const Spacer(), // 하단 고정 효과를 위한 공간 확보
              if (variant == 'news') // 뉴스에만 출처+업로드일 표시
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 10.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (video.publishedAt != null)
                        Text(
                          _formatPublishedAt(DateTime.parse(video.publishedAt!)),
                          style: TextStyle(fontSize: 9, color: Colors.grey[700]),
                        ),
                      Text(
                        video.channelTitle ?? '',
                        style: TextStyle(fontSize: 9, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}