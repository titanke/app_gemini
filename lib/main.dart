import 'dart:ffi';
import 'dart:io';
import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/pages/HomePage.dart';
import 'package:app_gemini/pages/PerfilPage.dart';
import 'package:app_gemini/pages/quiz/IntrodutionPage.dart';
import 'package:app_gemini/pages/quiz/QuizStack.dart';
import 'package:app_gemini/pages/quiz/ResultPage.dart';
import 'package:flutter/material.dart';
import 'package:app_gemini/pages/ChatPage.dart';
import 'package:app_gemini/pages/TopicsPage.dart';
import 'package:app_gemini/pages/DetailTopicPage.dart';
import 'package:app_gemini/pages/StorageDetailPage.dart';
import 'package:app_gemini/pages/quiz/QuizPage.dart';
import 'package:app_gemini/login/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:provider/provider.dart';
import 'package:app_gemini/widgets/theme_provider.dart';
import 'package:app_gemini/widgets/FirstTPage.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase. initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load();
  final String defaultLocale = Platform.localeName;
  final localeList = defaultLocale.split('_');
  final deviceLocale = Locale(localeList[0], localeList.length > 1 ? localeList[1] : '');

  runApp(    
    EasyLocalization(
          supportedLocales: [Locale('en', 'US'), Locale('es', 'ES')],
          path: 'assets/trans',
          fallbackLocale: Locale('en', 'US'),
          child: ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MyApp(),
          ),
        ),

    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<User?> _getUser() async {
    return FirebaseAuth.instance.currentUser;
  }
  
  @override
  Widget build(BuildContext context) {
        return FutureBuilder<User?>(
      future: _getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          return MaterialApp(
            title: 'App gemini',
            theme: Provider.of<ThemeProvider>(context).themeData,
            locale: context.locale,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            home: snapshot.hasData ? Menu() : LoginPage(),
            routes: <String, WidgetBuilder>{
              '/home': (context) => Menu(),
              '/detail': (context) => DetailScreen(topic: Topic(name: "",uid: ""),),
              '/storage': (context) => FileStorageScreen(),
              '/quiz': (context) => QuizIntroduction(),
              '/quiz/introduction': (context) => QuizIntroduction(),
              '/quiz/start': (context) => QuizPage(),
              '/quiz/result': (context) => ResultsPage(),
              '/login': (context) => LoginPage(),
              '/ftpage': (context) => FirstTopicsPage(),
            },
          );
        }
      },
    );
  }
}

class Menu extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Menu> {

  int _currentIndex = 0;
  final List<Widget> _children = [Homepage(),Topicspage(), Chatpage(), PerfilPage(),FirstTopicsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home".tr(),       
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book), 
            label: "Topics".tr(),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile".tr(),
          ),
             BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "a".tr(),
          ),
        ],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

