import 'package:app_gemini/global/common/toast.dart';
import 'package:app_gemini/login/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:app_gemini/widgets/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class PerfilPage extends StatefulWidget {

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {

    bool _isDarkTheme = true;
    Map<String, dynamic> _userData = {};

  Future<void> _getUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  
  if (user != null) {
    final uid = user.uid;
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      setState(() {
        _userData = userDoc.data() as Map<String, dynamic>;

      });
    } else {
      print('User document not found');
    }
  } else {
    print('User is not signed in');
  }
}

  Future<void> _signOut(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await FirebaseAuth.instance.signOut();
      await prefs.setString('user_id', "");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print(e);
      showToast(message: "some error signing out occured $e");
    }
  }

    @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      //appBar: AppBar(title: Text("Perfil"),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/300'), 
                  ),
                  SizedBox(width: 16),
                  Text('${_userData['email']}'),
                ],
              ),
              SizedBox(height: 20),
              Text("Account Data", style: TextStyle(fontWeight: FontWeight.bold)).tr(),
              ExpansionTile(
                title: Text("Personal information").tr(),
                children: [
                    ListTile(
                      title: Text(
                        '${("Age: ").tr()} ${_userData['age']}',
                      ),
                    ),     
                    ListTile(
                      title: Text(
                        '${("Country: ").tr()} ${_userData['country']}',
                      ),
                    ), 
                    ListTile(
                      title: Text(
                        '${("Interests: ").tr()} ${_userData['interests']}',
                      ),
                    ),              
              
                ],
              ),
                  Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)).tr(),
             /* ExpansionTile(
                title: Text('Ajustes de Conocimiento'),
                children: [
                    ExpansionTile(
                      title: Text('Nivel de conocimiento'),
                      children: [
                        ListTile(title: Text('Rudo')),
                        ListTile(title: Text('Normal')),
                        ListTile(title: Text('Pasivo')),
                      ],
                    ),
                  ],
              ),*/
                ExpansionTile(
                  title: Text('App Settings').tr(),
                  children: [
            Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Change Theme").tr(),
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Switch(
                      value: themeProvider.isDarkTheme,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    );
                  },
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Change Languaje").tr(),
                ),
                Consumer<ThemeProvider>(
                  builder: (context, provider, child) {
                    return DropdownButton<Locale>(
                      value: provider.locale,
                      onChanged: (Locale? newLocale) {
                        if (newLocale != null) {
                          provider.setLocale(newLocale);
                          context.setLocale(newLocale);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: Locale('en', 'US'),
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: Locale('es', 'ES'),
                          child: Text('Español'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
                  ],
                ),

                GestureDetector(
                  onTap: () {
                    themeProvider.signOut();
                    _signOut(context);
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)).tr(),
                ),            
              ],
          ),
        ),
      ),
    );
  }
}
