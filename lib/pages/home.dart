import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Lista dinámica para el contenido
  List<String> datos = ['Dato 1', 'Dato 2', 'Dato 3', 'Dato 4', 'Dato 5', 'Dato 6'];

  // Ruta para la pantalla de detalle
  final String detailScreenRoute = '/detail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      body: Column(
        children: [
          // Card inicial con texto
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Texto inicial'),
            ),
          ),

          // Carrusel de cards
          SizedBox(
            child: CarouselSlider.builder(
              itemCount: datos.length <= 4 ? datos.length : 4,
              itemBuilder: (context, index, carouselController) {
                return GestureDetector(
                  onTap: () => _navigateToDetailScreen(datos[index]),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(datos[index]),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                viewportFraction: 5,
                initialPage: 0,
                enableInfiniteScroll: false,
                autoPlay: true,
              
        
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),


          // Card Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: datos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _navigateToDetailScreen(datos[index]),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(datos[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetailScreen(String dato) {
    Navigator.pushNamed(context, detailScreenRoute, arguments: dato);
  }
}
