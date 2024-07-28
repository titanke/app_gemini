class Topic {
  final String name;
  final String uid;


  Topic({
    required this.name,
    required this.uid,
  });


  // Método para convertir una instancia de Document a un mapa de datos
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'uid': uid,
    };
  }
}
