import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/solicitudes_repository.dart';
import '../domain/solicitud_model.dart';

final solicitudesRepositoryProvider = Provider<SolicitudesRepository>((ref) {
  return SolicitudesRepository();
});

final crearSolicitudProvider = FutureProvider.family<SolicitudCreadaResponse, Map<String, dynamic>>(
  (ref, data) async {
    return ref.watch(solicitudesRepositoryProvider).crearSolicitud(data);
  },
);

final solicitudesListProvider = FutureProvider<List<SolicitudModel>>((ref) async {
  return ref.watch(solicitudesRepositoryProvider).listarSolicitudes();
});

final solicitudDetalleProvider = FutureProvider.family<SolicitudDetalleModel, String>(
  (ref, id) async {
    return ref.watch(solicitudesRepositoryProvider).obtenerSolicitud(id);
  },
);
