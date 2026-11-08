class AppConstants {
  AppConstants._();

  static const String catalogoMesasUrl = String.fromEnvironment(
    'CATALOGO_URL',
    defaultValue: 'https://reservas-g62-2.web.app/api/mesas.json',
  );

  static const Duration httpTimeout = Duration(seconds: 10);
  static const Duration firestoreTimeout = Duration(seconds: 10);

  // Reglas del caso G62-2
  static const int minPersonas = 1;
  static const int maxPersonas = 8;
  static const Duration duracionFranja = Duration(minutes: 90);
  static const Duration margenLlegada = Duration(minutes: 15);
  static const Duration plazoCancelacion = Duration(hours: 2);

  static const int diasReservables = 30;
}
