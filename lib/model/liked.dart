import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LikedArticlesProvider extends ChangeNotifier {
  List<String> _likedArticles = [];
  List<bool> _likedStates =
      []; // List to store liked/disliked state for thumbs-up
  // List<bool> _dislikedStates = [];

  // int likedStatesLength = 0;

  void initLikedStates(int length) {
    // Initialize liked/disliked state for each item
    _likedStates = List.filled(length, false);
    // _dislikedStates = List.filled(length, false);
    notifyListeners();
  }

  List<String> get likedArticles => _likedArticles;

  void addLikedArticle(String articleTitle) {
    _likedArticles.add(articleTitle);
    notifyListeners();
  }

  void removeArticle(String article) {
    _likedArticles.remove(article);
    notifyListeners();
  }

  bool isItemLiked(int index) {
    return _likedStates[index] ?? false;
  }

  // bool isItemDisliked(int index) {
  //   return _dislikedStates[index] ?? false;
  // }

  void toggleItemLiked(int index) {
    _likedStates[index] = !_likedStates[index];
    // if (_likedStates[index]) {
    //   _dislikedStates[index] =
    //       false; // If thumbs-up is selected, unselect thumbs-down
    // }
    notifyListeners();
  }

  // void toggleItemDisliked(int index) {
  //   _dislikedStates[index] = !_dislikedStates[index];
  //   if (_dislikedStates[index]) {
  //     _likedStates[index] =
  //         false; // If thumbs-down is selected, unselect thumbs-up
  //   }
  //   notifyListeners();
  // }
}
