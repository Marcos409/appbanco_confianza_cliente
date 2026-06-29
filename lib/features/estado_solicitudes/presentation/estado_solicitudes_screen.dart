import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_widget.dart';
import '../../solicitar_credito/domain/solicitud_model.dart';
import 'estado_solicitudes_provider.dart';

class EstadoSolicitudesScreen extends ConsumerWidget {
  const EstadoSolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(estadoSolicitudesListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Mis Solicitudes'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(estadoSolicitudesListProvider.future),
        child: asyncData.when(
          loading: () => const LoadingWidget(),
          error: (_, __) => const EmptyWidget(message: 'Error al cargar solicitudes'),
          data: (data) {
            if (data.isEmpty) return const EmptyWidget(
              icon: Icons.assignment_outlined,
              message: 'No tienes solicitudes de crédito',
            );
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (_, i) => _SolicitudTile(solicitud: data[i]),
            );
          },
        ),
      ),
    );
  }
}

class _SolicitudTile extends StatelessWidget {
  final SolicitudModel solicitud;
  const _SolicitudTile({required this.solicitud});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _estadoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_estadoIcon, color: _estadoColor, size: 22),
        ),
        title: Text(
          solicitud.numeroExpediente ?? 'Sin expediente',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(solicitud.montoFormateado,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            _buildEstadoChip(),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: () => context.push('/estado-solicitudes/${solicitud.id}'),
      ),
    );
  }

  Color get _estadoColor {
    switch (solicitud.estado) {
      case 'enviado': return AppColors.info;
      case 'recibido_comite': return AppColors.warning;
      case 'en_evaluacion': return AppColors.warning;
      case 'aprobado': return AppColors.success;
      case 'condicionado': return AppColors.warning;
      case 'rechazado': return AppColors.error;
      case 'desembolsado': return AppColors.success;
      default: return AppColors.textHint;
    }
  }

  IconData get _estadoIcon {
    switch (solicitud.estado) {
      case 'enviado': return Icons.send;
      case 'recibido_comite': return Icons.how_to_vote;
      case 'en_evaluacion': return Icons.search;
      case 'aprobado': return Icons.check_circle;
      case 'condicionado': return Icons.info;
      case 'rechazado': return Icons.cancel;
      case 'desembolsado': return Icons.account_balance;
      default: return Icons.description;
    }
  }

  Widget _buildEstadoChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _estadoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _estadoLabel,
        style: TextStyle(fontSize: 11, color: _estadoColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  String get _estadoLabel {
    switch (solicitud.estado) {
      case 'enviado': return 'Enviado';
      case 'recibido_comite': return 'En comité';
      case 'en_evaluacion': return 'En evaluación';
      case 'aprobado': return 'Aprobado';
      case 'condicionado': return 'Condicionado';
      case 'rechazado': return 'Rechazado';
      case 'desembolsado': return 'Desembolsado';
      default: return solicitud.estado;
    }
  }
}
