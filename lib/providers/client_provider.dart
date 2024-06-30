

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tayrona_usuario/src/models/client.dart';

class ClientProvider{

  late CollectionReference _ref;

  ClientProvider (){
    _ref = FirebaseFirestore.instance.collection('Clients');
  }

  Future<void> create(Client client){
    String errorMessage;

    try{
      return _ref.doc(client.id).set(client.toJson());
    }on FirebaseFirestore catch(error){
      errorMessage = error.hashCode as String;
    }

    if(errorMessage != null){
      return Future.error(errorMessage);
    }

    return Future.value();

  }
  Stream<DocumentSnapshot> getByIdStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<Client?> getById(String id) async {
    DocumentSnapshot document = await _ref.doc(id).get();
    if(document.exists){
      Client? client= Client.fromJson(document.data() as Map<String, dynamic>);
      return client;
    }
    else{
      return null;
    }

  }

  Future<void> update(Map<String, dynamic> data, String id) {
    return _ref.doc(id).update(data);
  }

  Future<String?> getVerificationStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await _ref.doc(user.uid).get();
        if (snapshot.exists) {
          Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
          return userData['Verificacion_Status'];
        }
      }
      return null;
    } catch (error) {
      print('Error al obtener el estado de verificación: $error');
      return null;
    }
  }

  Future<String> verificarFotoPerfil() async {
    try {
      // Obtener la referencia del usuario actual
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtener el estado de la foto de perfil del usuario actual desde la base de datos
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Clients').doc(user.uid).get();
        if (snapshot.exists) {
          // Verificar si la foto de perfil está verificada o no
          Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
          String fotoPerfil = userData['15_Foto_perfil_usuario'];
          print('foto perfil*************************** $fotoPerfil');
          return fotoPerfil;
        } else {
          // Si no se encuentra el documento del usuario, la foto de perfil no está verificada
          return "false";
        }
      } else {
        // Si no hay usuario autenticado, retornar false
        return "false";
      }
    } catch (error) {
      print('Error al verificar la foto de perfil: $error');
      return "false";
    }
  }

  Future<String> verificarFotoCedulaDelantera() async {
    try {
      // Obtener la referencia del usuario actual
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtener el estado de la foto de perfil del usuario actual desde la base de datos
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Clients').doc(user.uid).get();
        if (snapshot.exists) {
          // Verificar si la foto de perfil está verificada o no
          Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
          String fotoCedulaDelantera = userData['13_Foto_cedula_delantera'];
          print('foto cedulaDelantera*************************** $fotoCedulaDelantera');
          return fotoCedulaDelantera;
        } else {
          // Si no se encuentra el documento del usuario, la foto de perfil no está verificada
          return "false";
        }
      } else {
        // Si no hay usuario autenticado, retornar false
        return "false";
      }
    } catch (error) {
      print('Error al verificar la foto cedula delantera: $error');
      return "false";
    }
  }

  Future<String> verificarFotoCedulaTrasera() async {
    try {
      // Obtener la referencia del usuario actual
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtener el estado de la foto de perfil del usuario actual desde la base de datos
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Clients').doc(user.uid).get();
        if (snapshot.exists) {
          // Verificar si la foto de perfil está verificada o no
          Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
          String fotoCedulaTrasera = userData['14_Foto_cedula_trasera'];
          print('foto cedulaTrasera*************************** $fotoCedulaTrasera');
          return fotoCedulaTrasera;
        } else {
          // Si no se encuentra el documento del usuario, la foto de perfil no está verificada
          return "false";
        }
      } else {
        // Si no hay usuario autenticado, retornar false
        return "false";
      }
    } catch (error) {
      print('Error al verificar la foto cedula trasera: $error');
      return "false";
    }
  }

}