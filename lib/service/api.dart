import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadImage({required File file}) async {
  var fileName = file.path.split('/').last;
  final path = 'images/$fileName';
  UploadTask? uploadTask;

  final databaseReference = FirebaseStorage.instance.ref().child(path);
  uploadTask = databaseReference.putFile(file);

  final snapshot = await uploadTask.whenComplete(() => null);
  final url = await snapshot.ref.getDownloadURL();
  return url;
}
