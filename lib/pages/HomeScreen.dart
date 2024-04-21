// ignore_for_file: unused_local_variable
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newsapp/model/liked.dart';
import 'package:newsapp/model/newsModelHeadline.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<String> categories = ['Technology', 'science', 'sports', 'politics'];
  // List<String> likedArticle = [];

  final String apiUrl =
      // 'https://newsapi.org/v2/top-headlines?country=us&apiKey=96b9899434d04821acdb41e4e74be3ce';
      "https://newsapi.org/v2/everything?sources=the-times-of-india&apiKey=f920a5d9981e42de91c052c8471db7a2";

  List<Article> newsData = [];
  List<Article> newsEver = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchRandomNews();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = data['articles'] as List<dynamic>;

      setState(() {
        newsData = articles.map((dynamic e) => Article.fromJson(e)).toList();
      });
    } else {
      throw Exception('Failed to load news data');
    }
  }

  String getRandomCategory() {
    final random = Random();

    final randomIndex = random.nextInt(categories.length);
    print(randomIndex);
    return categories[randomIndex];
  }

  Future<void> fetchRandomNews() async {
    setState(() {
      isLoading = true;
    });
    try {
      final randomCategory = getRandomCategory();

      final response = await http.get(
        Uri.parse(
            // 'https://newsapi.org/v2/top-headlines?country=us&category=$randomCategory&apiKey=96b9899434d04821acdb41e4e74be3ce'),
            // "https://newsapi.org/v2/everything?sources=the-times-of-india&apiKey=f920a5d9981e42de91c052c8471db7a2";
            apiUrl),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        isLoading = true;
        setState(() {
          newsEver = data['articles']
              .map<Article>((evernew) => (Article.fromJson(evernew)))
              .toList();
          // print(newsEver);
        });
        Provider.of<LikedArticlesProvider>(context, listen: false)
            .initLikedStates(newsEver.length);
      }
    } catch (error) {
      print('Error fetching news: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _liked = false;
  bool _unliked = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final likedProvider = Provider.of<LikedArticlesProvider>(context);

    return isLoading
        ? Center(
            child: CircularProgressIndicator(
            color: Colors.blue,
          ))
        : Scaffold(
            appBar: AppBar(
              title: const Text('Newss'),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overScroll) {
                        overScroll.disallowIndicator();
                        return true;
                      },
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: newsEver.length,
                        itemBuilder: (context, index) {
                          final item = newsEver[index];
                          return InkWell(
                              onTap: () async {
                                final url = Uri.parse(item.url);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  // ignore: avoid_print
                                  print("Can't launch $url");
                                }

                                // Navigator.of(context).push(MaterialPageRoute(
                                //     builder: (context) => NewsDetailPage(
                                //           title: item.title,
                                //           description: item.description,
                                //           sourceName: item.sourceName,
                                //           urlToImage: item.urlToImage,
                                //           content: item.content,
                                //           publishedAt: item.publishedAt,
                                //           author: item.author,
                                //           url: item.url,
                                //         )));
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide.none,
                                ),
                                elevation: 5.0,
                                margin: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                      child: Image.network(
                                        item.urlToImage,
                                        fit: BoxFit.cover,
                                        height: 200,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            item.description ??
                                                "No Description Available",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 10.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  likedProvider
                                                          .isItemLiked(index)
                                                      ? Icons.favorite
                                                      : Icons
                                                          .favorite_border_outlined,
                                                  color: likedProvider
                                                          .isItemLiked(index)
                                                      ? Colors.red
                                                      : Colors.grey,
                                                ),
                                                onPressed: () {
                                                  String title = item.title;
                                                  likedProvider
                                                      .toggleItemLiked(index);
                                                  if (!_liked) {
                                                    Provider.of<LikedArticlesProvider>(
                                                            context,
                                                            listen: false)
                                                        .addLikedArticle(title);
                                                    List<String> likedArticles =
                                                        Provider.of<LikedArticlesProvider>(
                                                                context,
                                                                listen: false)
                                                            .likedArticles;
                                                    print(likedArticles);
                                                  } else {
                                                    Provider.of<LikedArticlesProvider>(
                                                            context,
                                                            listen: false)
                                                        .removeArticle(title);
                                                    List<String> likedArticles =
                                                        Provider.of<LikedArticlesProvider>(
                                                                context,
                                                                listen: false)
                                                            .likedArticles;
                                                    print(likedArticles);
                                                  }
                                                  setState(() {
                                                    _liked = !_liked;
                                                  });
                                                },
                                              ),
                                              // IconButton(
                                              //   icon: Icon(Icons.thumb_down,
                                              //       color: _unliked
                                              //           ? Colors.blue
                                              //           : Colors.black

                                              //       // : Colors.white,
                                              //       ),
                                              //   onPressed: () {
                                              //     String title = item.title;
                                              //     if (!_liked) {
                                              //       Provider.of<LikedArticlesProvider>(
                                              //               context,
                                              //               listen: false)
                                              //           .removeArticle(title);
                                              //       List<String> likedArticles =
                                              //           Provider.of<LikedArticlesProvider>(
                                              //                   context,
                                              //                   listen: false)
                                              //               .likedArticles;
                                              //       print(likedArticles);
                                              //     } else {}
                                              //     setState(() {
                                              //       _unliked = !_unliked;
                                              //     });
                                              //     // print('Liked: $title');
                                              //   },
                                              // ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
