
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:newsapp2/Models/chat_message.dart';
import 'package:newsapp2/Provider/databse.dart';
import '../Models/News.dart';
final Map<String, List<News>> _cachedNews = {};
class NewsService {
  // Caching mechanism
  
  
Future<List<News>> fetchNewsByCategory(String category) async {
    if (_cachedNews.containsKey(category)) {
      return _cachedNews[category]!;
    }
    List<News> articles=[];
    articles=await ApiService(category);
    _cachedNews[category] = articles;
    // print(_cachedNews);
    return articles;
  }
}
Future<List<News>> ApiService (String category)async{

  const String baseUrl = 'https://newsdata.io/api/1/news';
  final Dio dio = Dio();

      final response = await dio.get(
        baseUrl,
        options: Options(
          headers: {'X-ACCESS-KEY':'pub_2848047eb8285da33f8d4c7b511110ded2a47',},
        ),
        queryParameters: {
          'image':1,
          'full_content':1,
          'language':'hi',
          'category':category
          // 'timeframe':3
        },
      );
      if (response.statusCode == 200) {
        List newslist = response.data['results'];
        return newslist.map((item) => News(
          authorName:'',
          title: item['title'],
          publishedTime: item['pubDate'],
          imageUrl: item['image_url'],
          webUrl: item['link'],
          description: item['content']??'',
        )).toList();
      } 
      return [];
}    




final selectedCategoryProvider = StateProvider<String>((ref) => 'World'); // Default category is 'Sports'

final newsCategoryProvider=Provider<List<String>>((ref) => [
      'World',
    'Entertainment',
    'Business',
    'Technology',
    'Sports',
    'Environment',
    'Headlines',
    'Science',
    'Food',
    'Health',
    'Politics',
    'Tourism'

  ]);
final newsProvider = FutureProvider<List<News>>((ref) async {
  final category=ref.watch(selectedCategoryProvider);
  print('newsProvider fetching news for category: $category');
  if(category=="Headlines"){
return await NewsService().fetchNewsByCategory("Top");
  }
  return await NewsService().fetchNewsByCategory(category);
});


final bookmarkedNotifierProvider = StateNotifierProvider<BookmarkNotifier, bool>((ref) {
  return BookmarkNotifier();
});
final bookmarkedProvider = FutureProvider.family<bool, String>((ref, title) async {
  return await DatabaseHelper.instance.isBookmarked(title);
});

final voiceProvier=ChangeNotifierProvider((ref){
  return VoiceProvider();
});

class BookmarkNotifier extends StateNotifier<bool> {
  BookmarkNotifier() : super(false);

  void toggle() {
    state = !state;
  }
}

class VoiceProvider extends ChangeNotifier {
  final FlutterTts flutterTts = FlutterTts();
  String? currentTitleSpeaking;


  FlutterTts get tts => flutterTts;

  String? get currentTitle => currentTitleSpeaking;

  void speakText(String text)async {
    if (currentTitleSpeaking != null) {
      if(currentTitleSpeaking==text){
        currentTitleSpeaking=null;
        flutterTts.stop();
        notifyListeners();
        return;
      }
      await flutterTts.stop();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    currentTitleSpeaking = text;
    flutterTts.speak(text).then((value) {
      currentTitleSpeaking=null;
      notifyListeners();
    });
    notifyListeners();
  }
}
class Chats extends ChangeNotifier{
  List<ChatMessage> chats = [ChatMessage('Hello, how can I help?', false)];

  addChats(ChatMessage chat){
    chats.add(chat);
    notifyListeners();
  }
}
final chatProvider=ChangeNotifierProvider((ref) => Chats());
