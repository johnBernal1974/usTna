
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageProvider {

  Future<TaskSnapshot> uploadProfilePhoto(PickedFile file, String userId) async {
    String name = 'profile_photo.jpg'; // Nombre fijo para la foto de perfil

    Reference ref = FirebaseStorage.instance
        .ref()
        .child('images')
        .child('clientes') // Agregar la carpeta 'clientes'
        .child(userId) // Agregar la carpeta del usuario
        .child(name);

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': file.path},
    );

    UploadTask uploadTask = ref.putFile(File(file.path), metadata);
    return uploadTask;
  }

  Future<TaskSnapshot> uploadFotosDocumentos(PickedFile file, String userId, String documentType) async {
    String name = '$documentType.jpg'; // Nombre fijo para las fotos de documentos

    Reference ref = FirebaseStorage.instance
        .ref()
        .child('images')
        .child('clientes') // Agregar la carpeta 'clientes'
        .child(userId) // Agregar la carpeta del usuario
        .child('documentos') // Agregar la carpeta 'documentos'
        .child(name);

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': file.path},
    );

    UploadTask uploadTask = ref.putFile(File(file.path), metadata);
    return uploadTask;
  }

}
