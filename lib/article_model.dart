class Article {
  final String judul;
  final String? deskripsi;
  final String? urlToImage;

  Article ({
    required this.judul, this.deskripsi, this.urlToImage,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      judul: json['title'] ?? 'Tanpa Judul',
      deskripsi: json['description'],
      urlToImage: json['urlToImage'],
    );
  }
}