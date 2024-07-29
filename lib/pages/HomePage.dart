import 'package:app_gemini/widgets/customcard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:app_gemini/interfaces/TopicInterface.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final String detailScreenRoute = '/detail';
  final FirebaseDatabase db = FirebaseDatabase();

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: StreamBuilder<List<Topic>>( 
        stream: db.getTopicsUser(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final topics = snapshot.data!;

          return Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Texto inicial'),
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
                    onTap: () => _navigateToDetailScreen(topic),
                  );
                },
              ),

              Text("Temas favoritos", textAlign: TextAlign.left),

              SizedBox(
                child: GridView.builder(
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
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

    void _navigateToDetailScreen(Object dato) {
    Navigator.pushNamed(context, '/detail', arguments: dato);
  }
}

