class YoutubeVideo {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;

  YoutubeVideo({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
  });

  factory YoutubeVideo.fromJson(Map<String, dynamic> json) {
    return YoutubeVideo(
      videoId: json['id']['videoId'],
      title: json['snippet']['title'],
      description: json['snippet']['description'],
      thumbnailUrl: json['snippet']['thumbnails']['medium']['url'],
    );
  }
}