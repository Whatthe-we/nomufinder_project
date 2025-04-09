import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' as parser;
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(MyApp());
}

class NewsItem {
  final String title;
  final String link;
  final String pubDate;

  NewsItem({
    required this.title,
    required this.link,
    required this.pubDate,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'].replaceAll(RegExp(r'<[^>]*>'), ''),
      link: json['link'],
      pubDate: json['pubDate'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '오늘의 뉴스',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: NewsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<NewsItem> _newsList = [];
  int _start = 1;
  final int _display = 3;
  bool _isLoading = false;
  bool _hasMore = true;

  final String clientId = dotenv.env['NAVER_CLIENT_ID']!;
  final String clientSecret = dotenv.env['NAVER_CLIENT_SECRET']!;

  PageController _pageController = PageController(viewportFraction: 0.95);
  int _currentPage = 0;
  late Timer _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    fetchNews();

    _autoSlideTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_newsList.isEmpty) return;

      final nextPage = (_currentPage + 1) % _newsList.length;
      _pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer.cancel();
    super.dispose();
  }

  Future<void> fetchNews() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final url =
        'https://openapi.naver.com/v1/search/news.json?query=노동&display=$_display&start=$_start&sort=date';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['items'];

      if (items.isEmpty) {
        _hasMore = false;
      } else {
        setState(() {
          _newsList.addAll(items.map((item) => NewsItem.fromJson(item)));
          _start += _display;
        });
      }
    } else {
      print('뉴스 로딩 실패: ${response.statusCode}');
    }

    setState(() => _isLoading = false);
  }

  Future<String?> extractImageUrl(String link) async {
    try {
      final response = await http.get(Uri.parse(link));
      if (response.statusCode == 200) {
        final doc = parser.parse(response.body);
        final meta = doc.head?.querySelector("meta[property='og:image']");
        return meta?.attributes['content'];
      }
    } catch (e) {
      print("썸네일 추출 실패: $e");
    }
    return 'https://ssl.pstatic.net/static.news/image/news/og_tag_image.png';
  }

  String formatKoreanDate(String pubDate) {
    try {
      final date =
      DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US").parse(pubDate);
      return DateFormat('yyyy년 MM월 dd일').format(date);
    } catch (e) {
      return pubDate;
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('URL 실행 실패');
    }
  }

  Widget buildNewsCard(NewsItem item) {
    return FutureBuilder<String?>(
      future: extractImageUrl(item.link),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data ??
            'https://ssl.pstatic.net/static.news/image/news/og_tag_image.png';

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _launchURL(item.link),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, size: 60, color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(formatKoreanDate(item.pubDate),
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('오늘의 뉴스'),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _newsList.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: _currentPage == index ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: buildNewsCard(_newsList[index]),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else if (_hasMore)
            Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: ElevatedButton(
                onPressed: fetchNews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('더보기', style: TextStyle(fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }
}