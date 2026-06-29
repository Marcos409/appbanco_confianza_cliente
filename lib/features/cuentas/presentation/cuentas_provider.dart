import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/cuentas_repository.dart';

final cuentasRepositoryProvider = Provider<CuentasRepository>((ref) {
  return CuentasRepository();
});

final cuentasListProvider = FutureProvider<List<CuentaModel>>((ref) async {
  return ref.watch(cuentasRepositoryProvider).getCuentas();
});
