
import 'dart:convert';

Client clientFromJson(String str) => Client.fromJson(json.decode(str));

String clientToJson(Client data) => json.encode(data.toJson());

class Client {
  String id;
  String the01Nombres;
  String the02Apellidos;
  String the03TipoDeDocumento;
  String the04NumeroDocumento;
  String the05FechaExpedicionDocumento;
  String the06Email;
  String the07Celular;
  String the08FechaNacimiento;
  String the09Genero;
  bool the10EstaActivado;
  String the11FechaActivacion;
  String the12NombreActivador;
  String the13FotoCedulaDelantera;
  String the14FotoCedulaTrasera;
  String the15FotoPerfilUsuario;
  bool the16EstaBloqueado;
  int the17Bono;
  double the18Calificacion;
  int the19Viajes;
  String the20Rol;
  String the21FechaDeRegistro;
  String token;
  String image;
  String fotoCedulaDelantera;
  String fotoCedulaTrasera;
  String verificacionStatus;
  bool the00isTraveling;
  int the22Cancelaciones;
  bool the41SuspendidoPorCancelaciones;
  bool ceduladelanteraTomada;
  bool cedulatraseraTomada;
  bool fotoPerfilTomada;

  Client({
    required this.id,
    required this.the01Nombres,
    required this.the02Apellidos,
    required this.the03TipoDeDocumento,
    required this.the04NumeroDocumento,
    required this.the05FechaExpedicionDocumento,
    required this.the06Email,
    required this.the07Celular,
    required this.the08FechaNacimiento,
    required this.the09Genero,
    required this.the10EstaActivado,
    required this.the11FechaActivacion,
    required this.the12NombreActivador,
    required this.the13FotoCedulaDelantera,
    required this.the14FotoCedulaTrasera,
    required this.the15FotoPerfilUsuario,
    required this.the16EstaBloqueado,
    required this.the17Bono,
    required this.the18Calificacion,
    required this.the19Viajes,
    required this.the20Rol,
    required this.the21FechaDeRegistro,
    required this.token,
    required this.image,
    required this.fotoCedulaDelantera,
    required this.fotoCedulaTrasera,
    required this.verificacionStatus,
    required this.the00isTraveling,
    required this.the22Cancelaciones,
    required this.the41SuspendidoPorCancelaciones,
    required this.ceduladelanteraTomada,
    required this.cedulatraseraTomada,
    required this.fotoPerfilTomada,

  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    id: json["id"] ?? '',
    the01Nombres: json["01_Nombres"]  ?? '',
    the02Apellidos: json["02_Apellidos"]  ?? '',
    the03TipoDeDocumento: json["03_Tipo_de_documento"]  ?? '',
    the04NumeroDocumento: json["04_Numero_documento"]  ?? '',
    the05FechaExpedicionDocumento: json["05_Fecha_expedicion_documento"]  ?? '',
    the06Email: json["06_Email"]  ?? '',
    the07Celular: json["07_Celular"]  ?? '',
    the08FechaNacimiento: json["08_Fecha_nacimiento"]  ?? '',
    the09Genero: json["09_Genero"]  ?? '',
    the10EstaActivado: json["10_Esta_activado"]  ?? '',
    the11FechaActivacion: json["11_Fecha_activacion"]  ?? '',
    the12NombreActivador: json["12_Nombre_activador"]  ?? '',
    the13FotoCedulaDelantera: json["13_Foto_cedula_delantera"]  ?? '',
    the14FotoCedulaTrasera: json["14_Foto_cedula_trasera"]  ?? '',
    the15FotoPerfilUsuario: json["15_Foto_perfil_usuario"]  ?? '',
    the16EstaBloqueado: json["16_Esta_bloqueado"]  ?? '',
    the17Bono: json["17_Bono"]  ?? '',
    the18Calificacion: json["18_Calificacion"]?.toDouble()  ?? '',
    the19Viajes: json["19_Viajes"]  ?? '',
    the20Rol: json["20_Rol"]  ?? '',
    the21FechaDeRegistro: json["21_Fecha_de_registro"]  ?? '',
    token: json["token"]  ?? '',
    image: json["image"]  ?? '',
    fotoCedulaDelantera: json["foto_cedula_delantera"]  ?? '',
    fotoCedulaTrasera: json["foto_cedula_trasera"]  ?? '',
    verificacionStatus: json["Verificacion_Status"]  ?? '',
    the00isTraveling: json["00_is_traveling"]  ?? '',
    the22Cancelaciones: json["22_cancelaciones"]  ?? '',
    the41SuspendidoPorCancelaciones: json["41_Suspendido_Por_Cancelaciones"]  ?? '',
    ceduladelanteraTomada: json["cedula_delantera_tomada"]  ?? '',
    cedulatraseraTomada: json["cedula_trasera_tomada"]  ?? '',
    fotoPerfilTomada: json["foto_perfil_tomada"]  ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "01_Nombres": the01Nombres,
    "02_Apellidos": the02Apellidos,
    "03_Tipo_de_documento": the03TipoDeDocumento,
    "04_Numero_documento": the04NumeroDocumento,
    "05_Fecha_expedicion_documento": the05FechaExpedicionDocumento,
    "06_Email": the06Email,
    "07_Celular": the07Celular,
    "08_Fecha_nacimiento": the08FechaNacimiento,
    "09_Genero": the09Genero,
    "10_Esta_activado": the10EstaActivado,
    "11_Fecha_activacion": the11FechaActivacion,
    "12_Nombre_activador": the12NombreActivador,
    "13_Foto_cedula_delantera": the13FotoCedulaDelantera,
    "14_Foto_cedula_trasera": the14FotoCedulaTrasera,
    "15_Foto_perfil_usuario": the15FotoPerfilUsuario,
    "16_Esta_bloqueado": the16EstaBloqueado,
    "17_Bono": the17Bono,
    "18_Calificacion": the18Calificacion,
    "19_Viajes": the19Viajes,
    "20_Rol": the20Rol,
    "21_Fecha_de_registro": the21FechaDeRegistro,
    "token": token,
    "image": image,
    "foto_cedula_delantera": fotoCedulaDelantera,
    "foto_cedula_trasera": fotoCedulaTrasera,
    "Verificacion_Status": verificacionStatus,
    "00_is_traveling": the00isTraveling,
    "22_cancelaciones": the22Cancelaciones,
    "41_Suspendido_Por_Cancelaciones": the41SuspendidoPorCancelaciones,
    "cedula_delantera_tomada": ceduladelanteraTomada,
    "cedula_trasera_tomada": cedulatraseraTomada,
    "foto_perfil_tomada": fotoPerfilTomada,
  };
}
