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
      case 'law': // 👉 법률정보용
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        );
      case 'news': // 👉 뉴스용
        return const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        );
      case 'edu': // 👉 법정의무교육용
        return const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        );
      default: // 👉 기본
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        );
    }
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _getTitleStyle(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      decodedDesc,
                      maxLines: 2,
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
                height: variant == 'law' ? 70 : null, // 법률정보 글자칸 높이 조절
                width: variant == 'law' ? width : null,  // 법률정보 글자칸 너비 조절
                alignment: Alignment.centerLeft,
                child: Text(
                  decodedTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _getTitleStyle(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}