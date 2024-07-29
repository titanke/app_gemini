import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:app_gemini/widgets/customcard.dart';
import 'package:app_gemini/main.dart';
class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  // Ruta para la pantalla de detalle
  final String detailScreenRoute = '/detail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      body: SingleChildScrollView(
        child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Texto inicial'),
            ),
          ),
          Text("Temas recientes",textAlign:TextAlign.left,),

CarouselSlider.builder(
  options: CarouselOptions(
    height: 120.0,
    viewportFraction: 0.3,
    enableInfiniteScroll: true,
    autoPlay: true,
  ),
  itemCount: datos.length,
  itemBuilder: (context, index, realIndex) {
    return CustomCard(
      title: datos[index], 
      bgcolor: Colors.blueGrey,
      onTap: () => _navigateToDetailScreen(datos[index]),
    );
  },
),

          Text("Temas favoritos",textAlign:TextAlign.left,),

SizedBox(
  child: GridView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, 
    ),
    itemCount: datos.length,
    itemBuilder: (context, index) {
           return CustomCard(
              title: datos[index],
              bgcolor: Colors.grey,
              onTap: () => _navigateToDetailScreen(datos[index]),
            );
    },
  ),
)
        ],
        
      ),
      )
    );
  }

  void _navigateToDetailScreen(String dato) {
    Navigator.pushNamed(context, '/detail', arguments: dato);
  }
}
