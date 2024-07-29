import 'package:app_gemini/pages/HomePage.dart';
import 'package:app_gemini/pages/PerfilPage.dart';
import 'package:flutter/material.dart';
import 'package:app_gemini/pages/ChatPage.dart';
import 'package:app_gemini/pages/TopicsPage.dart';
import 'package:app_gemini/pages/DetailTopicPage.dart';
import 'package:app_gemini/pages/StorageDetailPage.dart';
import 'package:app_gemini/pages/Quiz/QuizPage.dart';
import 'package:app_gemini/login/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase. initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load();
  runApp(const MyApp());
}


final colorper = Color.fromRGBO(7, 3, 49, 1);
List<String> datos = ['Dato 1', 'Dato 2', 'Dato 3', 'Dato 4', 'Dato 5', 'Dato 6'];


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
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: AuthenticationWrapper(),
      routes: <String, WidgetBuilder>{
        '/home': (context) => Menu(),
        '/detail': (context) => DetailScreen(),
        '/storage': (context) => FileStorageScreen(),
        '/quiz': (context) => QuizPage(dato: ""),
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
  final List<Widget> _children = [Homepage(),Topicspage(), Chatpage(), PerfilPage() ];

  @override
  Widget build(BuildContext context) {
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
        selectedItemColor: colorper,
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