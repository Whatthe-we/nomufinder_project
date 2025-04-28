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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: InkWell(
        onTap: () => _launchYoutube(video.videoId),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 이미지 부분
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
              child: Image.network(
                video.thumbnailUrl,
                width: double.infinity,
                height: 222,
                fit: BoxFit.cover,
              ),
            ),
            // ✅ 제목 부분
            Container(
              width: double.infinity,
              color: Colors.white, // ✅ 흰색 배경
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15),
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