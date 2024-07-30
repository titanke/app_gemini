import 'package:flutter/material.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:app_gemini/main.dart';

class FirstTopicsPage extends StatefulWidget {
  @override
  _FirstTopicsPageState createState() => _FirstTopicsPageState();
}

class _FirstTopicsPageState extends State<FirstTopicsPage> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseDatabase _db = FirebaseDatabase();
  int _currentStep = 0;
  bool _step0Completed = false;
  bool _step1Completed = false;
  bool _step2Completed = false;
  bool _step3Completed = false;

void _guardarTema() async {
  String name = _nameController.text;
  try {
     _db.saveTopic(name); 
    _nameController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tema guardado exitosamente')),
    );
       setState(() {
      _currentStep++;
    });
  } catch (e) {
    print("Error en crear el tema $e");
  }
}
void nexts() async {
       setState(() {
      _currentStep++;
    });

}
bool _isUploading = false;

void _handleFileUpload() async {
  setState(() {
    _isUploading = true;
  });

  try {
    await _db.pickAndUploadFiles(lastSavedTopicId);
    setState(() {
      _step2Completed = true;
      _currentStep++;
      _isUploading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Archivo subido correctamente')),
      );
    });
  } catch (e) {
    setState(() {
      _isUploading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir el archivo: $e')),
      );
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepTapped: null,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep += 1);
          } else {
            setState(() => _step3Completed = true);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: [
          Step(
            title: Text(''),
            content: Column(
              children: <Widget>[
                Text(
                  '¡Hola!',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Antes de empezar, primero agrega con un curso y su material.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                  
                ),
                 ElevatedButton(
                    onPressed:  nexts,
                    child: Text('Aceptar'),
                  ),
              ],
            ),
            isActive: _currentStep >= 0,
            state: _step0Completed ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text('Curso'),
            content: Column(
              children: <Widget>[
                Text('Nombre del Curso'),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    onChanged: (value) {
                      setState(() => _step1Completed = value.isNotEmpty);
                      },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _guardarTema,
                    child: Text('Guardar'),
                  ),
              ],
            ),
            isActive: _currentStep >= 1,
            state: _step1Completed ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text('Mate'),
            content: Column(
              children: <Widget>[
                Text('Agregar Archivos (PDF / JPG)'),
                  _isUploading ? CircularProgressIndicator() : ElevatedButton(
                    onPressed: _handleFileUpload,
                    child: Text('Subir archivo'),
                  ),

              ],
            ),
            isActive: _currentStep >= 2,
            state: _step2Completed ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text(''),
            content: Column(
              children: <Widget>[
                Text('Que deseas hacer ahora?'),
              
                SizedBox(height: 20),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep = 1;
                            _step0Completed = false;
                            _step1Completed = false;
                            _step2Completed = false;
                            _step3Completed = false;
                          });
                        },
                        child: Text('Agregar otro cursos'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Menu()),
                          );
                        },
                        child: Text('Iniciar con la aventura'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 3,
            state: _step3Completed ? StepState.complete : StepState.indexed,
          ),
        ],
        controlsBuilder: (BuildContext context, ControlsDetails controls) {
            return SizedBox.shrink();
          },
      ),
    );
  }
}


