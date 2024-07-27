import 'package:app_gemini/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:app_gemini/pages/chat.dart';
import 'package:app_gemini/pages/topics.dart';
import 'package:app_gemini/pages/detailT.dart';
import 'package:app_gemini/pages/storage.dart';
import 'package:app_gemini/pages/quiz.dart';
import 'package:app_gemini/login/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async{


  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


final colorper = Color.fromRGBO(7, 3, 49, 1);



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
      //home:  Menu(),
      home: AuthenticationWrapper(),
      routes: {
        '/home': (context) => Menu(),
        '/detail': (context) => DetailScreen(),
        '/storage': (context) => Storagepage(),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return Menu();
        }
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

  int _currentIndex = 1;
  final List<Widget> _children = [Topicspage(),Homepage(), Chatpage()];
  final _titles = ['Temas', 'Inicio', 'Chat'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                                  backgroundColor: Color.fromARGB(255, 58, 89, 127),

        title: Text(_titles[_currentIndex],style: TextStyle(color: Colors.white),),
       
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book), 
            label: 'Temas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
        selectedItemColor: colorper, 
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}