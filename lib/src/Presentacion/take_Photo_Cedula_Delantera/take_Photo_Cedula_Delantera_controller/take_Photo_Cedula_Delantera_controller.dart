
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tayrona_usuario/providers/storage_provider.dart';
import 'package:tayrona_usuario/src/models/client.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/client_provider.dart';

class TakePhotoCedulaDelanteraController {

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
  }

  void guardarFotoCedulaDelantera() async {
    showSimpleProgressDialog(context, 'Cargando imagen...');

    if (pickedFile != null) {
      try {
        // Comprimir la imagen antes de subirla a Firestore
        File compressedImage = await compressImage(File(pickedFile!.path));

        // Convertir el archivo comprimido a un objeto PickedFile
        PickedFile compressedPickedFile = PickedFile(compressedImage.path);

        // Subir la imagen comprimida a Firestore
        TaskSnapshot snapshot = await _storageProvider.uploadFotosDocumentos(compressedPickedFile, _authProvider.getUser()!.uid, 'foto_cedula_delantera');
        String imageUrl = await snapshot.ref.getDownloadURL();

        // Actualizar la URL de la imagen en Firestore
        Map<String, dynamic> data = {'foto_cedula_delantera': imageUrl};
        await _clientProvider.update(data, _authProvider.getUser()!.uid);
        updateFotoCedulaDelanteraATrue();

        print('URL de la foto: $imageUrl');
        // Ocultar el progreso una vez que se haya cargado en Firebase
        closeSimpleProgressDialog(context);
        verificarCedulaTrasera();

      } catch (e) {
        print('Error al cargar la imagen: $e');
        // Asegúrate de cerrar el progreso en caso de que ocurra un error
        closeSimpleProgressDialog(context);
      }
    } else {
      print('No se ha seleccionado ninguna foto');
      // Asegúrate de cerrar el progreso en caso de que no se seleccione ninguna foto
      closeSimpleProgressDialog(context);
    }
  }

  void verificarCedulaTrasera(){
    _authProvider.verificarFotosCedulaTrasera(context);
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
      print('Error al comprimir la imagen: $e');
      // En caso de error, devuelve la imagen original sin comprimir
      return imageFile;
    }
  }

  void closeSimpleProgressDialog(BuildContext context) {
    Navigator.of(context).pop();
  }


  void goToTakePhotoCedulaTrasera(){
    Navigator.pushNamed(context, 'take_photo_cedula_trasera_page');
  }


  void takePicture() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      pickedFile = image;
      refresh();
    } else {
      print('No se tomó ninguna foto');
    }
  }

  void updateFotoCedulaDelanteraATrue() async {
    String userId = _authProvider.getUser()!.uid;

    Client? _client = await _clientProvider.getById(userId);
    if (_client != null) {
      bool isFotoTomada = _client.ceduladelanteraTomada;

      Map<String, dynamic> data;
      if (!isFotoTomada) {
        // Si la foto no está tomada, actualiza el estado y marca la foto como tomada
        data = {
          'Verificacion_Status': "foto_tomada",
          '13_Foto_cedula_delantera': "tomada",
          'cedula_delantera_tomada': true,
        };
      } else {
        // Si la foto ya está tomada, actualiza solo el estado a "corregida"
        data = {
          'Verificacion_Status': "corregida",
          '13_Foto_cedula_delantera': "corregida"
        };
      }
      await _clientProvider.update(data, userId);
    }
  }
}