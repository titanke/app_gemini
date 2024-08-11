import 'package:app_gemini/widgets/customcard.dart';
import 'package:app_gemini/widgets/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:app_gemini/interfaces/TopicInterface.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:app_gemini/pages/DetailTopicPage.dart';
import 'package:easy_localization/easy_localization.dart';

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
    return mounted
        ? Scaffold(
            // HEADER
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(150),
              child: AppBar(
                backgroundColor: Color(0xFFFFA500),
                automaticallyImplyLeading: false,
                flexibleSpace: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        // ignore: prefer_const_constructors
                        padding: EdgeInsets.all(16.0),
                        // ignore: prefer_const_constructors
                        child: Text(
                          'Hi..!',
                          // ignore: prefer_const_constructors
                          style: TextStyle(
                            // color: Colors.black,
                            fontSize: 24,
                          ),
                        ).tr(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SvgPicture.asset(
                          'assets/squirrel-svgrepo-com.svg',
                          width: 80,
                          height: 80,

                          // Color responsiveness, en caso de que sea necesario

                          // colorFilter: ColorFilter.mode(
                          //   Theme.of(context).iconTheme.color!,
                          //   BlendMode.srcIn,
                          // ),
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
                                // ignore: prefer_const_constructors
                                return Center(
                                    // ignore: prefer_const_constructors
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                  child: Text(
                                    "Don't have a topic?, add one",
                                    textAlign: TextAlign.center,
                                  ).tr(),
                                );
                              }
                              final topics = snapshot.data!
                                ..sort((a, b) => b.lastInteracted
                                    .compareTo(a.lastInteracted));

                              //
                              return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,  // Add this line
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(20), 
                                    child: const Text(
                                      "Last Topics",
                                      textAlign: TextAlign.left,
                                    ).tr(),
                                  ),

                                  // #//////////////////////////////////////////////////////////////////////////////////////////
                                  // CHIPS INICIO
                                  // ignore: prefer_const_constructors
                                  SingleChildScrollView(
                                    scrollDirection: Axis
                                        .horizontal, // Permite desplazamiento horizontal
                                    child: Row(
                                      children:
                                          List.generate(topics.length, (index) {
                                        final topic = topics[index];

                                        // Crear la forma del chip con un borde vacío
                                        final shape = RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          side: const BorderSide(
                                              color: Color(
                                                  0xFFFFB84D)), // Eliminar el borde
                                        );

                                        // Imprimir el color del borde actual en la consola
                                        // print(
                                        //     "Color del borde actual: ${shape.side.color}");

                                        return Padding(
                                            padding: EdgeInsets.only(
                                              left: index == 0
                                                  ? 16.0
                                                  : 0, // Margen izquierdo de 16 dp solo para el primer chip
                                              right:
                                                  8.0, // Separación de 8 dp entre los chips
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  topic.lastInteracted =
                                                      DateTime.now();
                                                });
                                                _navigateToDetailScreen(topic);
                                              },
                                              child: Container(
                                                constraints: BoxConstraints(
                                                  maxWidth:
                                                      120, // Ajusta el ancho máximo del chip según sea necesario
                                                ),
                                                child: Chip(
                                                  label: Text(
                                                    topic.name,
                                                    overflow: TextOverflow
                                                        .ellipsis, // Abrevia el texto con puntos suspensivos si es necesario
                                                  ),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    side: BorderSide(
                                                        color:
                                                            Color(0xFFFFB84D),
                                                        width:
                                                            2.5), // Borde transparente
                                                  ),
                                                ),
                                              ),
                                            ));
                                      }),
                                    ),
                                  ),

                                  // CHIPS FIN

                                  // Sección de favoritos
                                  // =>
                                  Padding(
                                    padding: const EdgeInsets.all(
                                        20), // Margen superior de 8 dp
                                    child: const Text(
                                      "Favorite topics",
                                      textAlign: TextAlign.left,
                                    ).tr(),
                                  ),

                                  // ##
                                  // Grid builder
                                  Container(
                                    margin: const EdgeInsets.all(
                                        16.0), 
                                    child: Column(children: [

                                      (topics.isNotEmpty && favoriteTopics.isNotEmpty)
                                        ? GridView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                            ),
                                            itemCount: favoriteTopics.length,
                                            itemBuilder: (context, index) {
                                              final topicId = favoriteTopics[index];
                                              final topic = topics.firstWhere((t) => t.uid == topicId, orElse: () => Topic(uid: '', name: 'Unknown'));
                                              if (topic != null) {
                                                return CustomCard(
                                                  title: topic.name,
                                                  bgcolor: Colors.grey,
                                                  onTap: () => _navigateToDetailScreen(topic),
                                                );
                                              } else {
                                                return SizedBox(
                                                  child: Container(
                                                    padding: EdgeInsets.all(16.0),
                                                    child: Text('Add your favorite topic here').tr(),
                                                  ),
                                                );
                                              }
                                            },
                                          )
                                        : Container(
                                            width: screenWidth,
                                            height: screenHeight / 2,
                                            child: Center(
                                              child: Text('Add your favorite topic here').tr(),
                                            ),
                                          ),

                                    ],)
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      )
                    : Text('Loading..').tr(),
              ],
            ),
          )
        : Text('Cargando');
  }

  void _navigateToDetailScreen(Object dato) {
    Navigator.pushNamed(context, '/detail', arguments: dato as Topic);
    //Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(topic: dato as Topic)));
  }
}
