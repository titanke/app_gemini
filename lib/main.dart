import 'package:app_gemini/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:app_gemini/pages/chat.dart';
import 'package:app_gemini/pages/topics.dart';
void main() {
  runApp(const MyApp());
}
final colorper = Color.fromRGBO(7, 3, 49, 1);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App gemini',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home:  Menu(),
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