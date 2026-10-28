import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pertemuan4/article_model.dart';

class ApiService {
  static const baseUrl = 'https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=a0fa2a6c6bf34652a0d5557bb954ceda';
 
  Future<List<Article>> fetchArticle() async {
    final response = await http.get(Uri.parse(baseUrl));

    if(response.statusCode != 200){
      throw Exception('Gagal Mengambil Berita');
    }

    final data = jsonDecode(response.body);

    return (data['articles'] as List)
    .map((item) => Article.fromJson(item))
    .toList();
  }
}