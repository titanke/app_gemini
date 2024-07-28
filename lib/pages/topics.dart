import 'package:app_gemini/services/Firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:app_gemini/main.dart';
import 'package:app_gemini/pages/home.dart';
class Topicspage extends StatefulWidget {
  const Topicspage({Key? key}) : super(key: key);

  @override
  _TopicspageState createState() => _TopicspageState();
}

class _TopicspageState extends State<Topicspage> {

  final FirebaseDatabase db = FirebaseDatabase();

  void _showTemaModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: TemaModal(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
    
      body: Column(

        children: [
          Expanded(
          child:
            FutureBuilder<List<String>>(
              future: db.getTopicsUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No tienes ningun tema, Agrega uno'));
                }

                List<String> datos = snapshot.data!;

                return ListView.builder(
                  itemCount: datos.length,
                  itemBuilder: (context, index) {
                    final topic = datos[index];
                    return InkWell(
                      onTap: () => _navigateToDetailScreen(datos[index]),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          topic,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          ElevatedButton(
            onPressed: () => _showTemaModal(context),
            child: Text('Agregar Tema'),
          ),
        ]
      ),
    );
    
  }
    void _navigateToDetailScreen(String dato) {
    Navigator.pushNamed(context, '/detail', arguments: dato);
  }
}


class TemaModal extends StatefulWidget {
  @override
  _TemaModalState createState() => _TemaModalState();
}

class _TemaModalState extends State<TemaModal> {

  final TextEditingController _nameController = TextEditingController();
  final FirebaseDatabase _db = FirebaseDatabase();

  void _guardarTema() async {
    String name = _nameController.text;
    try {
      _db.saveTopic(name);
    }catch(e){
      print("Error en crear el tema $e");
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarTema,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

