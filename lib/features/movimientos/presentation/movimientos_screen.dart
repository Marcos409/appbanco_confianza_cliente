import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'movimientos_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_widget.dart';
import 'package:intl/intl.dart';

class MovimientosScreen extends ConsumerWidget {
  const MovimientosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movimientosAsync = ref.watch(movimientosListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Historial de Movimientos'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(movimientosListProvider.future),
        child: movimientosAsync.when(
          loading: () => const LoadingWidget(),
          error: (_, __) => const EmptyWidget(message: 'Error al cargar movimientos'),
          data: (movimientos) {
            if (movimientos.isEmpty) return const EmptyWidget(message: 'No hay movimientos registrados');
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: movimientos.length,
              itemBuilder: (_, i) {
                final m = movimientos[i];
                final isCredito = m.tipo == 'CRE' || m.tipo == 'TRF' && m.monto > 0;
                return Card(
                  elevation: 0,
                  color: AppColors.background,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.border, width: 0.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: (isCredito ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isCredito ? Icons.arrow_downward : Icons.arrow_upward,
                            size: 22,
                            color: isCredito ? AppColors.success : AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.concepto ?? m.tipo ?? 'Movimiento',
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(_formatDate(m.fechaOperacion),
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isCredito ? '+' : '-'} S/ ${m.monto.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14,
                                color: isCredito ? AppColors.success : AppColors.textPrimary,
                              ),
                            ),
                            Text(m.moneda ?? 'PEN',
                              style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                          ],
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
