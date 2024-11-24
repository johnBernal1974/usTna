import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // Importar el paquete intl
import '../../../colors/colors.dart';
import '../../../models/travelHistory.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';
import '../historial_viajes_controller/historial_viajes_controller.dart';

class HistorialViajesPage extends StatefulWidget {
  const HistorialViajesPage({Key? key}) : super(key: key);

  @override
  State<HistorialViajesPage> createState() => _HistorialViajesPageState();
}

class _HistorialViajesPageState extends State<HistorialViajesPage> {
  late HistorialViajesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HistorialViajesController();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Scaffold(
      backgroundColor: blancoCards,
      key: _controller.key,
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: IconThemeData(color: negro, size: 26.r),
        title: headerText(
          text: "Historial de Viajes",
          fontSize: 20.r,
          fontWeight: FontWeight.w600,
          color: negro,
        ),

      ),
      body: FutureBuilder(
        future: _controller.getAll(),
        builder: (context, AsyncSnapshot<List<TravelHistory>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Muestra un indicador de progreso mientras se carga la información
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: gris,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cargando información...',
                    style: TextStyle(fontSize: 12.r),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // Maneja el caso de un error
            return const Center(
              child: Text('Error al cargar los datos'),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            // Muestra un mensaje si no hay viajes realizados
            return const Center(
              child: Text('Aún no has realizado ningún viaje'),
            );
          } else {
            // Muestra la lista de viajes
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                String fechaFormateada = '';
                if (snapshot.data![index].finalViaje != null) {
                  DateTime finalDate =
                  (snapshot.data![index].finalViaje as Timestamp).toDate();
                  fechaFormateada =
                      DateFormat('dd/MM/yyyy hh:mm a').format(finalDate);
                }
                return _historyInfo(
                  snapshot.data![index].from,
                  snapshot.data![index].to,
                  snapshot.data![index].nameDriver,
                  snapshot.data![index].apellidosDriver,
                  snapshot.data![index].placa,
                  fechaFormateada,
                  snapshot.data![index].tarifa,
                  snapshot.data![index].id,
                );
              },
            );
          }
        },
      ),
    );
  }
  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget _historyInfo(
      String from,
      String to,
      String name,
      String apellidosDriver,
      String placa,
      String fechaViaje,
      double tarifa,
      String idTravelHistory,
      ) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO', // Establecer el locale a Colombia
      symbol: '\$ ', // Símbolo de pesos
      decimalDigits: 0, // Sin decimales
      name: '', // No queremos mostrar el nombre de la moneda
      customPattern: '\u00A4#,##0', // Patrón de formato personalizado para colocar el símbolo al principio
    );

    return GestureDetector(
      onTap: () {
        _controller.goToDetailHistory(idTravelHistory);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5), // Espacio vertical entre registros
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del destino
            Row(
              children: [
                Image.asset('assets/images/marker_destino.png', height: 15.r, width: 15.r),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    to,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 14.r,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Hora de finalización
            Text(
              'Hora finalización : $fechaViaje',
              style: TextStyle(
                color: gris,
                fontWeight: FontWeight.w400,
                fontSize: 12.r,
              ),
            ),

            // Tarifa y botón de eliminar
            Text(
              formatter.format(tarifa), // Formatear la tarifa con NumberFormat
              style: TextStyle(
                color: negro,
                fontSize: 16.r,
                fontWeight: FontWeight.w900,
              ),
            ),

            // Espacio entre registros
            const SizedBox(height: 5),
            const Divider()// Espacio entre cada registro
          ],
        ),
      ),
    );
  }

}
