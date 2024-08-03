import 'package:app_gemini/widgets/customcard.dart';
import 'package:app_gemini/widgets/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:app_gemini/pages/DetailTopicPage.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final String detailScreenRoute = '/detail';
  final FirebaseDatabase db = FirebaseDatabase();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteTopics = Provider.of<ThemeProvider>(context).favoriteTopics;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // HEADER

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: AppBar(
          backgroundColor: Colors.orange[400],
          flexibleSpace: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Hola!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SvgPicture.asset(
                    'assets/squirrel-svgrepo-com.svg',
                    width: 80,
                    height: 80,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          mounted
              ? Expanded(
                  child: SingleChildScrollView(
                    child: StreamBuilder<List<Topic>>(
                      stream: db.getTopicsUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No tienes ningún tema, agrega uno',
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        final topics = snapshot.data!
                          ..sort((a, b) =>
                              b.lastInteracted.compareTo(a.lastInteracted));
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('Bienvenido empieza a practiar :)'),
                              ),
                            ),
                            Text("Temas recientes", textAlign: TextAlign.left),
                            CarouselSlider.builder(
                              options: CarouselOptions(
                                height: 120.0,
                                viewportFraction: 0.3,
                                enableInfiniteScroll: true,
                                autoPlay: true,
                              ),
                              itemCount: topics.length,
                              itemBuilder: (context, index, realIndex) {
                                final topic = topics[index];
                                return CustomCard(
                                    title: topic.name,
                                    bgcolor: Colors.blueGrey,
                                    onTap: () {
                                      setState(() {
                                        topic.lastInteracted = DateTime.now();
                                      });
                                      _navigateToDetailScreen(topic);
                                    });
                              },
                            ),
                            Text("Temas favoritos", textAlign: TextAlign.left),
                            favoriteTopics.isNotEmpty
                                ? GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                    ),
                                    itemCount: favoriteTopics.length,
                                    itemBuilder: (context, index) {
                                      final topicId = favoriteTopics[index];
                                      final topic = topics
                                          .firstWhere((t) => t.uid == topicId);

                                      if (topic != null) {
                                        return CustomCard(
                                          title: topic.name,
                                          bgcolor: Colors.grey,
                                          onTap: () =>
                                              _navigateToDetailScreen(topic),
                                        );
                                      } else {
                                        return SizedBox(
                                          child: Container(
                                            padding: EdgeInsets.all(
                                                16.0), // Ajusta el valor de padding según tus necesidades
                                            child: Text(
                                                'No tienes ningún tema favorito, Empieza agregando uno.'),
                                          ),
                                        );
                                      }
                                    },
                                  )
                                : Container(
                                    width: screenWidth,
                                    height: screenHeight / 2,
                                    child: Center(
                                      child: Text(
                                          'No tienes ningún tema favorito\n Empieza agregando uno.'),
                                    ),
                                  ),
                          ],
                        );
                      },
                    ),
                  ),
                )
              : Text('cargando'),
        ],
      ),
    );
  }

  void _navigateToDetailScreen(Object dato) {
    Navigator.pushNamed(context, '/detail', arguments: dato);
    //Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(topic: dato as Topic)));
  }
}

/*
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemCount: topics.length,
                        itemBuilder: (context, index) {
                          final topic = topics[index];
                          return CustomCard(
                            title: topic.name,
                            bgcolor: Colors.grey,
                            onTap: () => _navigateToDetailScreen(topic),
                          );
                        },
                      ),*/