class YoutubeVideo {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String? channelTitle;
  final String? publishedAt;

  YoutubeVideo({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    this.channelTitle,
    this.publishedAt,
  });

  factory YoutubeVideo.fromJson(Map<String, dynamic> json) {
    return YoutubeVideo(
      videoId: json['id']['videoId'],
      title: json['snippet']['title'],
      description: json['snippet']['description'],
      thumbnailUrl: json['snippet']['thumbnails']['medium']['url'],
      channelTitle: json['snippet']['channelTitle'],
      publishedAt: json['snippet']['publishedAt'],
    );
  }
}