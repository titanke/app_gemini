import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final Color bgcolor;
  final Color borderColor;
  final VoidCallback onTap;

  const CustomCard({
    super.key,
    required this.title,
    this.bgcolor = Colors.yellow,
    this.borderColor = Colors.black,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgcolor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor, // Usa la propiedad borderColor
            width: 2.0, // Grosor del borde
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.transparent,
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
