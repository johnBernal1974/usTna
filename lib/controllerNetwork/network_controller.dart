import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../src/colors/colors.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  Rx<ConnectivityResult> _lastResult = ConnectivityResult.wifi.obs;

  ConnectivityResult get currentStatus => _lastResult.value;

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _lastResult.value = result;
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      Get.rawSnackbar(
        message: 'No hay señal de Internet',
        isDismissible: false,
        duration: Duration(days: 1),
        backgroundColor: Colors.red[700]!,
        icon: const Icon(Icons.wifi_off, color: Colors.white, size: 35),
        margin: EdgeInsets.zero,
        snackStyle: SnackStyle.GROUNDED,
      );
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}
