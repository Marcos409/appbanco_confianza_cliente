import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pagos_repository.dart';

final pagosRepositoryProvider = Provider<PagosRepository>((ref) {
  return PagosRepository();
});

final cuentasOrigenProvider = FutureProvider<List<CuentaOrigen>>((ref) async {
  return ref.watch(pagosRepositoryProvider).getCuentasOrigen();
});

final creditoInfoProvider = FutureProvider.family<CreditoDestino, String>((ref, codCredito) async {
  return ref.watch(pagosRepositoryProvider).getCreditoInfo(codCredito);
});
