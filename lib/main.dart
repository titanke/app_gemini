import 'dart:ffi';

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
void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase. initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load();
  runApp(    
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
      ),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {

        print('User is currently signed out!');
      } else {
        print('User is signed in!');

      }
    });

    return MaterialApp(
      title: 'App gemini',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: AuthenticationWrapper(),
      routes: <String, WidgetBuilder>{
        '/home': (context) => Menu(),
        '/detail': (context) => DetailScreen(),
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
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return Menu();
        } else
          return LoginPage();
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
  final List<Widget> _children = [Homepage(),Topicspage(), Chatpage(), PerfilPage()];

  @override
  Widget build(BuildContext context) {
    //_currentIndex = ModalRoute.of(context)?.settings.arguments as int??0;
    return Scaffold(
      /*appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 58, 89, 127),
        title: Text(_titles[_currentIndex],style: TextStyle(color: Colors.white),),
       
      ),*/
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book), 
            label: 'Temas',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
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