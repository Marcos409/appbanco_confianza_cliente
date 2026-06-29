import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'creditos_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_widget.dart';
import 'package:intl/intl.dart';

class CronogramaScreen extends ConsumerWidget {
  final String codCuentaCredito;

  const CronogramaScreen({super.key, required this.codCuentaCredito});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cronogramaAsync = ref.watch(cronogramaProvider(codCuentaCredito));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Cronograma de Pagos'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(cronogramaProvider(codCuentaCredito).future),
        child: cronogramaAsync.when(
          loading: () => const LoadingWidget(),
          error: (_, __) => const EmptyWidget(message: 'Error al cargar cronograma'),
          data: (cuotas) {
            if (cuotas.isEmpty) return const EmptyWidget(message: 'No hay cuotas registradas');
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cuotas.length,
              itemBuilder: (_, i) {
                final cuota = cuotas[i];
                final isPagada = cuota.estadoCuota?.toLowerCase() == 'pagada' || cuota.fechaPago != null;
                final isVencida = !isPagada && _isOverdue(cuota.fechaVencimiento);
                return Card(
                  elevation: 0,
                  color: AppColors.background,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isPagada ? AppColors.success.withValues(alpha: 0.3)
                          : isVencida ? AppColors.error.withValues(alpha: 0.3)
                          : AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: isPagada ? AppColors.success.withValues(alpha: 0.1)
                                : isVencida ? AppColors.error.withValues(alpha: 0.1)
                                : AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: Text('${cuota.nroCuota}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14,
                              color: isPagada ? AppColors.success
                                  : isVencida ? AppColors.error
                                  : AppColors.info,
                            ),
                          )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('S/ ${cuota.montoCuota?.toStringAsFixed(2) ?? '0.00'}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(_formatDate(cuota.fechaVencimiento),
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isPagada ? AppColors.success : isVencida ? AppColors.error : AppColors.warning).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isPagada ? 'Pagado' : (isVencida ? 'Vencido' : 'Pendiente'),
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: isPagada ? AppColors.success : isVencida ? AppColors.error : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  bool _isOverdue(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return date.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
