import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:local_auth/local_auth.dart';

class LoginController extends GetxController {
  bool isDeviceSupport = false;
  List<BiometricType>? availableBiometrics;
  LocalAuthentication? auth;

  @override
  void onReady() {
    super.onReady();
    auth = LocalAuthentication();
    deviceCapability();
    _getAvailableBiometric();
  }

  void deviceCapability() async {
    final bool isCapable = await auth!.canCheckBiometrics;
    isDeviceSupport = isCapable || await auth!.isDeviceSupported();
  }

  Future<void> _getAvailableBiometric() async {
    try {
      availableBiometrics = await auth?.getAvailableBiometrics();
      print("BioMetric: $availableBiometrics");

      if (availableBiometrics!.contains(BiometricType.strong) ||
          availableBiometrics!.contains(BiometricType.fingerprint)) {
        final bool didAuthenticate = await auth!.authenticate(
          localizedReason:
              'Unlock your screen with PIN, pattern, password, face or finger print',
          options: const AuthenticationOptions(
              biometricOnly: true, stickyAuth: true),
          // authMessages: const <AuthMessages>[
          //   AndroidAuthMessages(
          //     signInTitle: 'Unlock Ideal Group',
          //     cancelButton: 'No thanks',
          //   ),
          //   IOSAuthMessages(
          //     cancelButton : 'No thanks'
          //   ),
          // ]
        );
        if (!didAuthenticate) {
          exit(0);
        } else if (availableBiometrics!.contains(BiometricType.weak) ||
            availableBiometrics!.contains(BiometricType.face)) {
          final bool didAuthenticate = await auth!.authenticate(
            localizedReason:
                'Unlock your screen with PIN, pattern, password, face or finger print',
            options: const AuthenticationOptions(stickyAuth: true),
          );
          if (!didAuthenticate) {
            exit(0);
          }
        }
      }
    } on PlatformException catch (e) {
      print("error: $e");
    }
  }
  // void deviceCapability() async {
  //   final bool isCapable = await auth!.canCheckBiometrics;
  //   isDeviceSupport = isCapable || await auth!.isDeviceSupported();
  // }
}
