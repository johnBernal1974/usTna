import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../colors/colors.dart';
import '../travel_calification_controller/travel_calification_controller.dart';

class TravelCalificationPage extends StatefulWidget {
  const TravelCalificationPage({super.key});

  @override
  State<TravelCalificationPage> createState() => _TravelCalificationPageState();
}

class _TravelCalificationPageState extends State<TravelCalificationPage> {

  late TravelCalificationController _controller;
  String? tarifaFormatted;
  final ConnectionService connectionService = ConnectionService();
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    _controller = TravelCalificationController();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: blancoCards,
        key: _controller.key,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Asegura que la columna se extienda horizontalmente
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _tituloNotificacion(),
                    SizedBox(height: 30.r),
                    _infoOrigenDestino(),
                    SizedBox(height: 30.r),
                    _tarifa(),
                    SizedBox(height: 30.r),
                    _subtituloCuantasEstrellas(),
                    SizedBox(height: 10.r),
                    _ratingBar ()
                  ],
                ),
              ),
              _botones(), // Mueve los botones fuera del Expanded
            ],
          ),
        ),
      ),
    );
  }

  Widget _subtituloCuantasEstrellas() {
    return Container(
      alignment: Alignment.center,
      child: Text('¿Cuántas estrellas le das al conductor?', style: TextStyle(
          color: primary,
          fontSize: 16.r,
          fontWeight: FontWeight.bold
      ),
      ),
    );
  }

  Widget _tituloNotificacion(){
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: EdgeInsets.only(left: 25.r, right: 25.r, top: 15.r, bottom: 15.r),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(70.r),
              bottomLeft: Radius.circular(70.r)),
          color: primary,
          boxShadow: const [BoxShadow(
            color: gris,
            offset: Offset(5,5),
            blurRadius: 5,
          )]),
      child: Text('Servicio\nFinalizado', style: TextStyle(
              fontSize: 24.r,
              fontWeight: FontWeight.w500,
              color: blanco
          ),
      textAlign: TextAlign.center),
    );
  }

  Widget _infoOrigenDestino(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100.r,
          padding: EdgeInsets.only(left: 10.r, top: 2.r, bottom: 2.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(70.r),
                topRight: Radius.circular(70.r)),
            color: blanco,
          ),
          child: Row(
            children: [
              Image.asset('assets/images/marker_inicio.png', height: 20.r, width: 20.r),
              SizedBox(width: 10.r,),
              Text('Origen', style: TextStyle(
                  fontSize: 14.r,
                  fontWeight: FontWeight.w700,
                  color: negro)),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 35.r, right: 15.r, top: 5.r),
          child: Text(_controller.travelHistory?.from ?? '', style: TextStyle(
              fontWeight: FontWeight.w900,fontSize: 12.r, color: negro), maxLines: 2),
        ),
        SizedBox(height: 10.r),
        const Divider(color: grisMedio,height: 1,indent: 2, endIndent: 2,),
        SizedBox(height: 15.r),
        Container(
          width: 100.r,
          padding: EdgeInsets.only(left: 10.r, top: 2.r, bottom: 2.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(70.r),
                topRight: Radius.circular(70.r)),
            color: blanco,
          ),
          child: Row(
            children: [
              Image.asset('assets/images/marker_destino.png', height: 20.r, width: 20.r),
              SizedBox(width: 10.r,),
              Text('Destino', style: TextStyle(
                  fontSize: 14.r,
                  fontWeight: FontWeight.w700,
                  color: negro)),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 35.r, right: 15.r, top: 5.r),
          child: Text(_controller.travelHistory?.to ?? '', style: TextStyle(
              fontWeight: FontWeight.w900,fontSize: 12.r, color: negro), maxLines: 2),
        ),
        SizedBox(height: 15.r),
        const Divider(color: grisMedio,height: 1,indent: 2, endIndent: 2)
      ],
    );
  }

  void formateartarifa() {
    String tarifa = _controller.travelHistory?.tarifa.toString() ?? '';
    double tarifaDouble = double.tryParse(tarifa) ?? 0.0;
    NumberFormat formatter = NumberFormat('#,###', 'es_ES');
    tarifaFormatted = '\$ ${formatter.format(tarifaDouble)}';
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _ratingBar () {
    return Center(
        child: RatingBar.builder(
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.orange.shade300,
            ),
            itemCount: 5,
            initialRating: 0,
            direction: Axis.horizontal,
            itemSize: 35.r,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.r),
            allowHalfRating: true,
            unratedColor: grisMedio,
            onRatingUpdate: (ratingBar) {
              _controller.calification = ratingBar;
            }
        )
    );
  }

  Widget _tarifa (){
    return Container(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: Column(
        children: [
          Text('Tarifa', style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.bold, color: negro)),
          Text(tarifaFormatted ?? '', style: TextStyle(fontSize: 30.r, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }


  Widget _botones() {
    return Container(
      margin: EdgeInsets.only(bottom: 50.r),
      alignment: Alignment.center,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            flex: 2, // Proporción del primer botón
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shadowColor: gris,
                elevation: 6,
              ),
              onPressed: isLoading
                  ? null // Desactiva el botón si está cargando
                  : () async {
                // Verificar conexión a Internet antes de ejecutar la acción
                bool hasConnection = await connectionService.hasInternetConnection();
                if (hasConnection) {
                  setState(() {
                    isLoading = true; // Muestra el indicador de carga
                  });

                  // Llama a _controller.calificate e intercala el indicador
                  await _controller.calificate(); // Ejecuta calificate y espera que termine

                  setState(() {
                    isLoading = false; // Oculta el indicador de carga
                  });
                } else {
                  alertSinInternet();
                }
              },
              child: isLoading
                  ? const CircularProgressIndicator(
                color: blanco, // Color del indicador
              )
                  : Text(
                'Calificar conductor',
                style: TextStyle(color: blanco, fontSize: 18.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future alertSinInternet (){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sin Internet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),),
          content: const Text('Por favor, verifica tu conexión e inténtalo nuevamente.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void refresh(){
    if(mounted){
      setState(() {
        formateartarifa();
      });
    }
  }
}
