import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Errorservice{
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> writeError(String error) async {
    final path = await _localPath;
    final file = File('$path/errors.txt');
    return file.writeAsString('$error\n', mode: FileMode.append);
  }
}