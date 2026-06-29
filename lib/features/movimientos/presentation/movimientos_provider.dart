import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/movimientos_repository.dart';

final movimientosRepositoryProvider = Provider<MovimientosRepository>((ref) {
  return MovimientosRepository();
});

final movimientosListProvider = FutureProvider<List<MovimientoModel>>((ref) async {
  return ref.watch(movimientosRepositoryProvider).getMovimientos();
});
