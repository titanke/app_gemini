import 'dart:ffi';
import 'dart:io';
import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:app_gemini/pages/HomePage.dart';
import 'package:app_gemini/pages/PerfilPage.dart';
import 'package:app_gemini/pages/quiz/IntrodutionPage.dart';
import 'package:app_gemini/pages/quiz/QuizStack.dart';
import 'package:app_gemini/pages/quiz/ResultPage.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:app_gemini/pages/ChatPage.dart';
import 'package:app_gemini/pages/TopicsPage.dart';
import 'package:app_gemini/pages/DetailTopicPage.dart';
import 'package:app_gemini/pages/StorageDetailPage.dart';
import 'package:app_gemini/pages/quiz/QuizPage.dart';
import 'package:app_gemini/login/LoginPage.dart';
import 'package:app_gemini/widgets/AddTopic.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:app_gemini/widgets/theme_provider.dart';
import 'package:app_gemini/widgets/FirstTPage.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load();
  final String defaultLocale = Platform.localeName;
  final localeList = defaultLocale.split('_');
  final deviceLocale =
      Locale(localeList[0], localeList.length > 1 ? localeList[1] : '');

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
              '/detail': (context) => DetailScreen(),
              '/storage': (context) => FileStorageScreen(),
              '/quiz': (context) => QuizIntroduction(),
              '/quiz/introduction': (context) => QuizIntroduction(),
              '/quiz/start': (context) => QuizPage(),
              '/quiz/result': (context) => ResultsPage(),
              '/login': (context) => LoginPage(),
              '/ftpage': (context) => FirstTopicsPage(),
              '/Addtopic': (context) => AddTopic(),
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
  final _formKey = GlobalKey<FormState>();
  final FirebaseDatabase db = FirebaseDatabase();
  final TextEditingController _nameController = TextEditingController();
  int _currentIndex = 0;
  final List<Widget> _children = [
    Homepage(),
    Topicspage(),
    Chatpage(),
    PerfilPage(),
    FirstTopicsPage()
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: _currentIndex,
          children: _children,
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavBarItem(Icons.home, "Home".tr(), 0),
              buildNavBarItem(Icons.book, "Topics".tr(), 1),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange[400], // Background color of the circle
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.pushNamed(context, '/Addtopic');
                  },
                ),
              ),
              buildNavBarItem(Icons.chat, "Chat".tr(), 2),
              buildNavBarItem(Icons.person, "Profile".tr(), 3),
            ],
          ),
        ));
  }

  Widget buildNavBarItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () => _onTap(index),
      customBorder: CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(4.0),
        width: 70,
        height: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: _currentIndex == index
                  ? Colors.orange[400]
                  : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                color: _currentIndex == index
                    ? Colors.orange[400]
                    : Colors.grey,
                fontSize: 12, // Tamaño fijo del texto
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/*
* ottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(8.0), // Ajusta el margen aquí
              child:Icon(Icons.home),
            ),
            label: "Home".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Topics".tr(),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile".tr(),
          ),

        ],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
*
* FloatingActionButton(
        child: Icon(Icons.add),
        shape: CircleBorder(),
        onPressed: (){

        },
      )
* */