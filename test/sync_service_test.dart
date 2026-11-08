import 'package:final_movil/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el reintento espera cada vez mas, con tope de 2 minutos', () {
    expect(SyncService.esperaParaIntento(0), const Duration(seconds: 5));
    expect(SyncService.esperaParaIntento(1), const Duration(seconds: 10));
    expect(SyncService.esperaParaIntento(2), const Duration(seconds: 20));
    expect(SyncService.esperaParaIntento(10), const Duration(minutes: 2));
  });
}
