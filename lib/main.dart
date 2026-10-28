import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';
import 'article_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'news pois-corner',
      home: const NewsScreen(),
      theme: base.copyWith(
        textTheme: GoogleFonts.montserratTextTheme(base.textTheme),
        primaryTextTheme:
            GoogleFonts.montserratTextTheme(base.primaryTextTheme),
      ),
    );
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<Article>> articles;

  final ScrollController _scrollController = ScrollController();

  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();

    articles = ApiService().fetchArticle();

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final shouldShow = _scrollController.offset > 300;

    if (shouldShow != _showScrollToTop && mounted) {
      setState(() {
        _showScrollToTop = shouldShow;
      });
    }
  }

  Future<void> _refreshArticles() async {
    final newArticles = ApiService().fetchArticle();

    setState(() {
      articles = newArticles;
    });

    try {
      await newArticles;
    } catch (_) {
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _messageList(
    BuildContext context,
    Widget child,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(child: child),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.newspaper,
          color: Colors.white,
        ),
        title: const Text(
          'News Pois-corner',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),

      body: RefreshIndicator(
        onRefresh: _refreshArticles,
        color: Colors.white,
        child: FutureBuilder<List<Article>>(
          future: articles,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _messageList(
                context,
                const CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return _messageList(
                context,
                Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            final data = snapshot.data ?? [];

            if (data.isEmpty) {
              return _messageList(
                context,
                const Text(
                  'Tidak Ada Berita',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final article = data[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: article.urlToImage != null
                        ? Image.network(
                            article.urlToImage!,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          )
                        : const Icon(Icons.newspaper),
                    title: Text(article.judul),
                    subtitle: Text(
                      article.deskripsi ?? 'Tidak Ada Deskripsi',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              tooltip: 'Kembali ke atas',
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}
