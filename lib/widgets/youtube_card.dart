import 'package:flutter/material.dart';
import '../models/youtube_video.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html_unescape/html_unescape.dart'; // ✅ 추가

class YoutubeCard extends StatelessWidget {
  final YoutubeVideo video;

  const YoutubeCard({Key? key, required this.video}) : super(key: key);

  void _launchYoutube(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unescape = HtmlUnescape();
    final decodedTitle = unescape.convert(video.title);

    return Card(
      color: Colors.white, // ✅ 카드 전체 배경을 흰색으로 통일
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: InkWell(
        onTap: () => _launchYoutube(video.videoId),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 썸네일 이미지 부분
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.network(
                video.thumbnailUrl,
                width: double.infinity,
                height: 225,
                fit: BoxFit.cover,
              ),
            ),
            // ✅ 제목 부분
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
              child: Text(
                decodedTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14, // 제목 글씨는 약간 작게 유지
                  color: Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}