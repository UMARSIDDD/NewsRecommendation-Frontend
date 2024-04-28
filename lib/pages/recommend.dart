import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newsapp/constant/constant.dart';
import 'package:newsapp/model/liked.dart';
import 'package:provider/provider.dart';
import 'package:newsapp/model/liked.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationScreen extends StatefulWidget {
  final List<String>? likedarticle;
  const RecommendationScreen({Key? key, this.likedarticle}) : super(key: key);

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  TextEditingController _activityController = TextEditingController();
  List<String> _userActivities = [];
  List<Map<String, dynamic>> _recommendedArticles = [];
  bool _isSearching = true; // Track if user is searching
  bool isLoading = false;

  void someFunction(BuildContext context) {}

  Future<void> _getRecommendations(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    List<String> likedArticles =
        Provider.of<LikedArticlesProvider>(context, listen: false)
            .likedArticles;
    String apiUrl =
        '${Apiurl.backendUrl}//recommend_news/'; // Update with your FastAPI server address

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(likedArticles),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Ensure the response is a list of maps with 'title' and 'description' keys
        if (jsonResponse is List &&
            jsonResponse.every((element) =>
                element is Map &&
                element.containsKey('title') &&
                element.containsKey('description'))) {
          setState(() {
            _recommendedArticles =
                List<Map<String, dynamic>>.from(jsonResponse);
            _isSearching = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load recommendations');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // print(LikedArticlesProvider().likedArticles[0]);
    _getRecommendations(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              title: const Text('Recommendation Screen'),
            ),
            body:  isLoading
        ? Center(
            child: CircularProgressIndicator(
            color: Colors.blue,
          ))
        : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  // Visibility(
                  //   visible: _isSearching,
                  //   // Show search bar only if user is searching

                  //   child: TextField(
                  //     controller: _activityController,
                  //     decoration: InputDecoration(
                  //       hintText: "Enter Your User Activity",
                  //       border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(18),
                  //           borderSide: BorderSide.none),
                  //       fillColor: Colors.purple.withOpacity(0.1),
                  //       filled: true,
                  //     ),
                  //     onChanged: (value) {
                  //       // Add or remove user activities based on user input
                  //       if (value.isNotEmpty && !_userActivities.contains(value)) {
                  //         setState(() {
                  //           _userActivities.add(value);
                  //         });
                  //       } else if (value.isEmpty && _userActivities.isNotEmpty) {
                  //         setState(() {
                  //           _userActivities.clear();
                  //         });
                  //       }
                  //     },
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 60,
                  // ),
                  // ElevatedButton(
                  //   onPressed: () {},
                  //   child: const Text(
                  //     'Get Recommendations',
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  //   style: ButtonStyle(
                  //     backgroundColor:
                  //         MaterialStateProperty.all<Color>((Colors.purple)),
                  //   ),
                  // ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _recommendedArticles.length,
                      itemBuilder: (context, index) {
                        final article = _recommendedArticles[index];
                        return InkWell(
                          onTap: () async {
        final url = Uri.parse(article['url']); 
        // ignore: deprecated_member_use
        if (await canLaunch(url.toString())) {
          // ignore: deprecated_member_use
          await launch(url.toString());
        } else {
          print("Can't launch $url");
        }
      },
      
                          child: Container(
                             margin: EdgeInsets.symmetric(vertical: 20),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide.none,
                              ),
                              elevation: 5,
                              margin:
                                  EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (article.containsKey('urlToImage') &&
                                      article['urlToImage'] != null)
                                    Image.network(
                                      article['urlToImage'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 200,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                            child: Text('Image not available'));
                                      },
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article['title'] ?? 'No Title',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          article['description'] ?? '',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
