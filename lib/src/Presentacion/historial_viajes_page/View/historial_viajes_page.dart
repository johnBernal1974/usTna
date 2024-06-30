import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart'; // Importar el paquete intl
import 'package:tayrona_usuario/src/Presentacion/historial_viajes_page/historial_viajes_controller/historial_viajes_controller.dart';
import 'package:tayrona_usuario/src/models/travelHistory.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';

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
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _controller.key,
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 26),
        title: headerText(
          text: "Historial de Viajes",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: negro,
        ),
        actions: const <Widget>[
          Image(
            height: 40.0,
            width: 60.0,
            image: AssetImage('assets/images/historial.png'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _controller.getAll(),
        builder: (context, AsyncSnapshot<List<TravelHistory>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Muestra un indicador de progreso mientras se carga la información
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: gris,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Cargando información...',
                    style: TextStyle(fontSize: 12),
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
                return _cardHistoryInfo(
                  snapshot.data![index].from ?? '',
                  snapshot.data![index].to ?? '',
                  snapshot.data![index].nameDriver ?? '',
                  snapshot.data![index].apellidosDriver ?? '',
                  snapshot.data![index].placa ?? '',
                  snapshot.data![index].finalViaje ?? '',
                  snapshot.data![index].tarifa ?? 0,
                  snapshot.data![index].id ?? '',
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

  Widget _cardHistoryInfo(
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
      onTap: (){
        _controller.goToDetailHistory(idTravelHistory);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: blanco,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: grisMedio,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/posicion_destino.png', height: 15, width: 15),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                             'Destino: ${to ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 11,
                              ),
                              maxLines: 1, // Máximo de 1 línea
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 5),
              child: const Divider(height: 1, color: grisMedio),
            ),
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                'Hora finalización : ${fechaViaje ?? ''}',
                style: const TextStyle(
                  color: gris,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatter.format(tarifa), // Formatear la tarifa con NumberFormat
                  style: const TextStyle(
                    color: negro,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
