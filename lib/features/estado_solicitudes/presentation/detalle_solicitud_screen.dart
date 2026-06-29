import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../solicitar_credito/domain/solicitud_model.dart';
import '../../solicitar_credito/presentation/solicitar_credito_provider.dart';
import 'firma_screen.dart';

class DetalleSolicitudScreen extends ConsumerWidget {
  final String solicitudId;
  const DetalleSolicitudScreen({super.key, required this.solicitudId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(solicitudDetalleProvider(solicitudId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Detalle de Solicitud'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: asyncData.when(
        loading: () => const LoadingWidget(),
        error: (_, __) => const Center(child: Text('Error al cargar detalle')),
        data: (detalle) => RefreshIndicator(
          onRefresh: () => ref.refresh(solicitudDetalleProvider(solicitudId).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(detalle),
              const SizedBox(height: 16),
              _buildInfoCard('Información General', [
              ('Expediente', detalle.numeroExpediente ?? '—'),
              ('Cliente', detalle.clienteNombre),
              ('Estado', _estadoLabel(detalle.estado)),
              ('Creado', _formatDate(detalle.createdAt) ?? '—'),
              ('Actualizado', _formatDate(detalle.updatedAt) ?? '—'),
              ]),
              const SizedBox(height: 12),
              _buildInfoCard('Detalle del Crédito', [
                ('Monto solicitado', detalle.montoFormateado),
                ('Monto aprobado', detalle.montoAprobadoFormateado),
                ('Plazo', '${detalle.plazoMeses} meses'),
                ('Moneda', detalle.moneda),
                ('Tipo de cuota', _tipoCuotaLabel(detalle.tipoCuota)),
                ('Garantía', _garantiaLabel(detalle.garantia)),
              ]),
              if (detalle.destinoCredito != null) ...[
                const SizedBox(height: 12),
                _buildInfoCard('Destino', [
                  ('Destino del crédito', detalle.destinoCredito!),
                ]),
              ],
              if (detalle.motivoRechazo != null) ...[
                const SizedBox(height: 12),
                _buildInfoCard('Motivo de Rechazo', [
                  ('Observación', detalle.motivoRechazo!),
                ], color: AppColors.error),
              ],
              if (detalle.condicionAdicional != null) ...[
                const SizedBox(height: 12),
                _buildInfoCard('Condición Adicional', [
                  ('Detalle', detalle.condicionAdicional!),
                ], color: AppColors.warning),
              ],
              if (detalle.estado == 'aprobado') ...[
                const SizedBox(height: 20),
                _buildFirmarButton(context, ref, detalle),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirmarButton(BuildContext context, WidgetRef ref, SolicitudDetalleModel detalle) {
    return Column(
      children: [
        Card(
          elevation: 0,
          color: AppColors.success.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Crédito aprobado!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tu crédito de ${detalle.montoAprobadoFormateado} está listo. '
                        'Firma para aceptar las condiciones y recibir el desembolso.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _confirmarFirma(context, ref, detalle),
            icon: const Icon(Icons.edit_note, size: 22),
            label: const Text('Aceptar y firmar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmarFirma(BuildContext context, WidgetRef ref, SolicitudDetalleModel detalle) async {
    final firmaBase64 = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => FirmaScreen(montoFormateado: detalle.montoAprobadoFormateado),
      ),
    );
    if (firmaBase64 == null || firmaBase64.isEmpty) return;
    try {
      await ref.read(solicitudesRepositoryProvider).firmarSolicitud(
        solicitudId,
        firmaBase64: firmaBase64,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Crédito aceptado! Revisa tu cronograma de pagos.'),
          backgroundColor: AppColors.success,
        ),
      );
      ref.invalidate(solicitudDetalleProvider(solicitudId));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al firmar: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Widget _buildHeader(SolicitudDetalleModel detalle) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(_estadoIcon(detalle.estado), size: 48, color: _estadoColor(detalle.estado)),
            const SizedBox(height: 12),
            Text(detalle.montoFormateado, style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
            )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _estadoColor(detalle.estado).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _estadoLabel(detalle.estado),
                style: TextStyle(fontWeight: FontWeight.w600, color: _estadoColor(detalle.estado)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<(String, String)> items, {Color? color}) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color ?? AppColors.border, width: color != null ? 0.5 : 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
            )),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(item.$1, style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary,
                    )),
                  ),
                  Expanded(
                    child: Text(item.$2, style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
                    )),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _estadoColor(String estado) {
    switch (estado) {
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

  IconData _estadoIcon(String estado) {
    switch (estado) {
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

  String _estadoLabel(String estado) {
    switch (estado) {
      case 'enviado': return 'Enviado';
      case 'recibido_comite': return 'En comité';
      case 'en_evaluacion': return 'En evaluación';
      case 'aprobado': return 'Aprobado';
      case 'condicionado': return 'Condicionado';
      case 'rechazado': return 'Rechazado';
      case 'desembolsado': return 'Desembolsado';
      default: return estado;
    }
  }

  String? _formatDate(String? iso) {
    if (iso == null) return null;
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  String _tipoCuotaLabel(String tipo) {
    switch (tipo) {
      case 'mensual': return 'Mensual';
      case 'quincenal': return 'Quincenal';
      case 'semanal': return 'Semanal';
      default: return tipo;
    }
  }

  String _garantiaLabel(String garantia) {
    switch (garantia) {
      case 'sin_garantia': return 'Sin garantía';
      case 'prendaria': return 'Prendaria';
      case 'hipotecaria': return 'Hipotecaria';
      case 'aval': return 'Con aval';
      default: return garantia;
    }
  }
}
