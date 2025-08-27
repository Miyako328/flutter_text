import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum SupportState {
  unknown,
  supported,
  unsupported,
}

class LocalAuthController extends GetxController {
  final LocalAuthentication auth = LocalAuthentication();
  Rx<SupportState> supportState = SupportState.unknown.obs;
  RxBool canCheckBiometrics = false.obs;
  RxList<BiometricType> availableBiometrics = <BiometricType>[].obs;
  RxString authorized = 'Not Authorized'.obs;
  RxBool isAuthenticating = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _checkDeviceSupport();
  }
  
  Future<void> _checkDeviceSupport() async {
    try {
      final bool isSupported = await auth.isDeviceSupported();
      supportState.value = isSupported ? SupportState.supported : SupportState.unsupported;
    } catch (e) {
      print('Error checking device support: $e');
      supportState.value = SupportState.unsupported;
    }
  }

  Future<void> checkBiometrics() async {
    try {
      final bool canCheck = await auth.canCheckBiometrics;
      canCheckBiometrics.value = canCheck;
    } on PlatformException catch (e) {
      canCheckBiometrics.value = false;
      print('Platform exception: $e');
    }
  }

  Future<void> getAvailableBiometrics() async {
    try {
      final List<BiometricType> biometrics = await auth.getAvailableBiometrics();
      availableBiometrics.value = biometrics;
    } on PlatformException catch (e) {
      availableBiometrics.value = <BiometricType>[];
      print('Platform exception: $e');
    }
  }

  Future<void> authenticate() async {
    try {
      isAuthenticating.value = true;
      authorized.value = 'Authenticating';
      
      final bool authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
      );
      
      authorized.value = authenticated ? 'Authorized' : 'Not Authorized';
    } on PlatformException catch (e) {
      print('Authentication error: $e');
      authorized.value = "Error - ${e.message}";
    } finally {
      isAuthenticating.value = false;
    }
  }

  Future<void> authenticateWithBiometrics() async {
    try {
      isAuthenticating.value = true;
      authorized.value = 'Authenticating';
      
      final bool authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      authorized.value = authenticated ? 'Authorized' : 'Not Authorized';
    } on PlatformException catch (e) {
      print('Biometric authentication error: $e');
      authorized.value = "Error - ${e.message}";
    } finally {
      isAuthenticating.value = false;
    }
  }
  
  void resetAuth() {
    authorized.value = 'Not Authorized';
  }
  
  bool get isSupported => supportState.value == SupportState.supported;
  bool get hasBiometrics => availableBiometrics.isNotEmpty;
}
