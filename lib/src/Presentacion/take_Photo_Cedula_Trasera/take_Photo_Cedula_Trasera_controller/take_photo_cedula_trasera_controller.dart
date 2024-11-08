
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/client_provider.dart';
import '../../../../providers/storage_provider.dart';
import '../../../models/client.dart';

class TakePhotoCedulaTraseraController {

  late BuildContext context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  late StorageProvider _storageProvider = StorageProvider();
  late MyAuthProvider _authProvider;
  late ClientProvider _clientProvider;
  XFile? pickedFile;
  File? imageFile;
  late Function refresh;

  Future? init (BuildContext context, Function refresh) {
    this.context = context;
    this.refresh = refresh;
    _authProvider = MyAuthProvider();
    _clientProvider = ClientProvider();
    _storageProvider = StorageProvider();
    return null;
  }

  void guardarFotoCedulaTrasera() async {
    showSimpleProgressDialog(context, 'Cargando imagen...');

    if (pickedFile != null) {
      try {
        // Comprimir la imagen antes de subirla a Firestore
        File compressedImage = await compressImage(File(pickedFile!.path));

        // Convertir el archivo comprimido a un objeto PickedFile
        PickedFile compressedPickedFile = PickedFile(compressedImage.path);

        // Subir la imagen comprimida a Firestore
        TaskSnapshot snapshot = await _storageProvider.uploadFotosDocumentos(compressedPickedFile, _authProvider.getUser()!.uid, 'foto_cedula_trasera');
        String imageUrl = await snapshot.ref.getDownloadURL();

        // Actualizar la URL de la imagen en Firestore
        Map<String, dynamic> data = {'foto_cedula_trasera': imageUrl};
        await _clientProvider.update(data, _authProvider.getUser()!.uid);
        updateFotoCedulaTraseraATrue();
        if(context.mounted){
          closeSimpleProgressDialog(context);
        }
        goToVerificandoIdentidad();
      } catch (e) {
        if(context.mounted){
          closeSimpleProgressDialog(context);
        }

      }
    } else {
      closeSimpleProgressDialog(context);
    }
  }

  void showSimpleProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  // Función para comprimir la imagen
  Future<File> compressImage(File imageFile) async {
    try {
      // Comprimir la imagen con una calidad específica (entre 0 y 100)
      List<int> compressedImage = (await FlutterImageCompress.compressWithFile(
        imageFile.path,
        quality: 80, // Calidad de compresión
      )) as List<int>;

      // Guardar la imagen comprimida en un nuevo archivo
      File compressedFile = File('${imageFile.parent.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(compressedImage);

      return compressedFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error al comprimir la imagen: $e');
      }
      // En caso de error, devuelve la imagen original sin comprimir
      return imageFile;
    }
  }

  void closeSimpleProgressDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  void goToVerificandoIdentidad(){
    updateStatusProcesando();
    Navigator.pushNamedAndRemoveUntil(context, "verifying_identity", (route) => false);
  }

  void takePicture() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      pickedFile = image;
      refresh();
    } else {
      if (kDebugMode) {
        print('No se tomó ninguna foto');
      }
    }
  }

  void updateFotoCedulaTraseraATrue() async {
    String userId = _authProvider.getUser()!.uid;

    Client? client = await _clientProvider.getById(userId);
    if (client != null) {
      bool isFotoTomada = client.cedulatraseraTomada;

      Map<String, dynamic> data;
      if (!isFotoTomada) {
        // Si la foto no está tomada, actualiza el estado y marca la foto como tomada
        data = {
          'Verificacion_Status': "foto_tomada",
          '14_Foto_cedula_trasera': "tomada",
          'cedula_trasera_tomada': true,
        };
      } else {
        // Si la foto ya está tomada, actualiza solo el estado a "corregida"
        data = {
          'Verificacion_Status': "corregida",
          '14_Foto_cedula_trasera': "corregida"
        };
      }
      await _clientProvider.update(data, userId);
    }
  }

  void updateStatusProcesando() async {
    String? userId = _authProvider.getUser()?.uid;
    if (userId != null) {

      Client? client = await _clientProvider.getById(userId);
      if (client != null) {
        Map<String, dynamic> data = {
          'Verificacion_Status': "Procesando",
        };
        await _clientProvider.update(data, userId);
      } else {
        if (kDebugMode) {
          print("Error: No se encontró el cliente para el ID $userId");
        }
      }
    } else {
      if (kDebugMode) {
        print("Error: Usuario no autenticado o ID inválido.");
      }
    }
  }
}