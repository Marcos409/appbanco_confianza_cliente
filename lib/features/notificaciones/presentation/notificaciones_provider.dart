import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notificaciones_repository.dart';

final notificacionesRepositoryProvider = Provider<NotificacionesRepository>((ref) {
  return NotificacionesRepository();
});

final notificacionesListProvider = FutureProvider<List<NotificacionModel>>((ref) async {
  return ref.watch(notificacionesRepositoryProvider).getNotificaciones();
});
