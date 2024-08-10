import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_gemini/services/Firebase_database.dart';
import 'package:app_gemini/main.dart';

class AddTopic extends StatefulWidget {
  @override
  _AddTopicState createState() => _AddTopicState();
}

class _AddTopicState extends State<AddTopic> {
  final _formKey = GlobalKey<FormState>();
  bool _isUploading = false;
  final TextEditingController _nameController = TextEditingController();
  final FirebaseDatabase _db = FirebaseDatabase();
  int _currentStep = 0;
  bool _step0Completed = false;
  bool _step1Completed = false;
  bool _step2Completed = false;
  bool _step3Completed = false;

  void _guardarTema() {
  
    if (_formKey.currentState!.validate()) {
          String name = _nameController.text;
          try {
            _db.saveTopic(name); 
            _nameController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Topic succesfully saved").tr()),
            );
              
          } catch (e) {
            print("Error en crear el tema $e");
          }      setState(() {
        _currentStep++;
        _step1Completed = true;
      });
    }
  }

void nexts() async {
       setState(() {
      _currentStep++;
    });

}

void _handleFileUpload() async {
  setState(() {
    _isUploading = true;
  });

  try {
    await _db.pickAndUploadFiles2(lastSavedTopicId);
    setState(() {
      _step2Completed = true;
      _currentStep++;
      _isUploading = false;
    
    });
  } catch (e) {
    setState(() {
      _isUploading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading file").tr()),
      );
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
      key: _formKey,
      child: Stepper(
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
              title: Text("Topic", style: TextStyle(color: Colors.orange)),
            content: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Text("Topic name").tr(),
                    TextFormField(
                      controller: _nameController,
                        decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                       validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a topic name".tr();
                      }
                      return null;
                    },
                      onChanged: (value) {
                        setState(() => _step1Completed = value.isNotEmpty);
                        },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _guardarTema,
                      child: Text("Save".tr()),
                            style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.orange,
                      ),
                    ),
                ],
              ),
            ),
            isActive: _currentStep >= 1,
            state: _step1Completed ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text("File".tr(), style: TextStyle(color: Colors.orange)),
            content: Column(
              children: <Widget>[
                Text("Add files (PDF / JPG)", style: TextStyle(color: const Color.fromARGB(125, 255, 153, 0))).tr(),
                  _isUploading ? CircularProgressIndicator() : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.orange,
                      ),
                    onPressed: _handleFileUpload,
                    child: Text("Upload file").tr(),
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
                Text("What do you want to do?".tr()),
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
                        child: Text("Add other topic".tr()),
                              style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.orange,
                      ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Menu()),
                          );
                        },
                        child: Text("Exit").tr(),
                              style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.orange,
                      ),
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
    ),
    );
  }
}


