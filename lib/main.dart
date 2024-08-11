import 'dart:io';
import 'package:app_gemini/pages/HomePage.dart';
import 'package:app_gemini/pages/PerfilPage.dart';
import 'package:app_gemini/pages/quiz/IntrodutionPage.dart';
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
import 'package:easy_localization/easy_localization.dart';
import 'package:app_gemini/pages/IntroPage.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load();
  final String defaultLocale = Platform.localeName;
  final localeList = defaultLocale.split('_');
  final deviceLocale = Locale(localeList[0]);

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
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.black), // Color blanco, si lo deseas
            ),
          );
        } else {
          String initialRoute = snapshot.hasData ? '/home' : '/login';
          print(initialRoute);
          return PopScope(
            canPop: false,
            child: MaterialApp(
              title: 'App Gemini',
              theme: Provider.of<ThemeProvider>(context).themeData,
              locale: context.locale,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              initialRoute: initialRoute,
              routes: <String, WidgetBuilder>{
                '/home': (context) => Menu(),
                '/detail': (context) => DetailScreen(),
                '/storage': (context) => FileStorageScreen(),
                '/quiz': (context) => QuizIntroduction(),
                '/quiz/introduction': (context) => QuizIntroduction(),
                '/quiz/start': (context) => QuizPage(),
                '/quiz/result': (context) => ResultsPage(),
                '/login': (context) => LoginPage(),
                '/Addtopic': (context) => AddTopic(),
                '/IntroPage': (context) => IntroPage(),

              },
            ),
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
  final FirebaseDatabase db = FirebaseDatabase();
  int _currentIndex = 0;
  final List<Widget> _children = [Homepage(),Topicspage(),Chatpage(),PerfilPage()];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: IndexedStack(
              index: _currentIndex,
              children: _children,
            ),
            floatingActionButton: Transform.translate(
              offset: const Offset(0, 24),
              child: ClipOval(
                child: Material(
                  color: Colors.orange[400],
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/Addtopic');
                    },
                    child: const SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(
                        Icons.add,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildNavBarItem(Icons.home, "Home".tr(), 0),
                  buildNavBarItem(Icons.book, "Topics".tr(), 1),
                  const SizedBox(width: 60),
                  buildNavBarItem(Icons.chat, "Chat".tr(), 2),
                  buildNavBarItem(Icons.person, "Profile".tr(), 3),
                ],
              ),
            )));
/*
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(0, 255, 255, 255),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildNavBarItem(Icons.home, "Home".tr(), 0),
            buildNavBarItem(Icons.book, "My Topics".tr(), 1),

            // Add the icon with a circled border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange[400], // Background color of the circle
                border: Border.all(
                  color: Colors.white, // Border color
                  width: 2, // Border width
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.pushNamed(context, '/Addtopic');
                },
              ),
            ),

            buildNavBarItem(Icons.chat, "Chat".tr(), 2),
            buildNavBarItem(Icons.person, "Profile".tr(), 3),
          ],
        ),
      ),
    );
*/
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
                  : Color(0xFFFFE0B2),
            ),
            Text(
              label,
              style: TextStyle(
                color: _currentIndex == index
                    ? Colors.orange[400]
                    : Color(0xFFFFE0B2),
                fontSize: 11, // Tamaño fijo del texto
              ),
            ),
          ],
        ),
      ),
    );
  }
}

