import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  /// Verifica si el dispositivo soporta biometría
  Future<bool> isAvailable() async {
    try {
      return await auth.canCheckBiometrics || await auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Verifica si hay biometrías registradas en el dispositivo
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final canCheckBiometrics = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics && !isDeviceSupported) {
        return false;
      }

      try {
        final biometrics = await auth.getAvailableBiometrics();
        return biometrics.isNotEmpty;
      } catch (e) {
        // Si falla getAvailableBiometrics pero el dispositivo soporta biometría,
        // asumimos que está disponible
        return canCheckBiometrics || isDeviceSupported;
      }
    } catch (e) {
      return false;
    }
  }

  /// Autentica al usuario con biometría
  Future<bool> authenticate() async {
    try {
      final canAuthenticate = await isAvailable();
      if (!canAuthenticate) return false;

      final didAuthenticate = await auth.authenticate(
        localizedReason: "Confirma tu identidad para ingresar",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }
}
