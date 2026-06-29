import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/creditos_repository.dart';

final creditosRepositoryProvider = Provider<CreditosRepository>((ref) {
  return CreditosRepository();
});

final creditosListProvider = FutureProvider<List<CreditoModel>>((ref) async {
  return ref.watch(creditosRepositoryProvider).getCreditos();
});

final cronogramaProvider = FutureProvider.family<List<CuotaModel>, String>((ref, codCredito) async {
  return ref.watch(creditosRepositoryProvider).getCronograma(codCredito);
});
