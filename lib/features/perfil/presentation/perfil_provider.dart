import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/perfil_repository.dart';

final perfilRepositoryProvider = Provider<PerfilRepository>((ref) {
  return PerfilRepository();
});

final perfilProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(perfilRepositoryProvider).getPerfil();
});
