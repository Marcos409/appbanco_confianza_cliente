import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../solicitar_credito/presentation/solicitar_credito_provider.dart';
import '../../solicitar_credito/domain/solicitud_model.dart';

final estadoSolicitudesListProvider = FutureProvider<List<SolicitudModel>>((ref) async {
  return ref.watch(solicitudesRepositoryProvider).listarSolicitudes();
});
