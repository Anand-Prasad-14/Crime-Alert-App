import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';


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

Future<String> uploadXImage({required XFile file}) async {
   final File firebaseFile = File(file.path);
   var fileName = file.path.split('/').last;
   final path = 'postImages/$fileName';
   UploadTask? uploadTask;

   final ref = FirebaseStorage.instance.ref().child(path);
   uploadTask = ref.putFile(firebaseFile);

   final snapshot = await uploadTask.whenComplete(() => null);
   final urlDownload = await snapshot.ref.getDownloadURL();
   return urlDownload;
}

Future<String> uploadFile ({required PlatformFile file}) async {

  final File fileForFirebase = File(file.path!);
  var fileName = fileForFirebase.path.split('/').last;
  final path = 'mediaFiles/$fileName';
  UploadTask? uploadTask;

  final ref = FirebaseStorage.instance.ref().child(path);
  uploadTask = ref.putFile(fileForFirebase);

  final snapshot = await uploadTask.whenComplete((){});

  final urlDownload = await snapshot.ref.getDownloadURL();
  return urlDownload;

}
