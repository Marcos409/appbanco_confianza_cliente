import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'creditos_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_widget.dart';

class CreditosScreen extends ConsumerWidget {
  const CreditosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditosAsync = ref.watch(creditosListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Mis Créditos'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(creditosListProvider.future),
        child: creditosAsync.when(
          loading: () => const LoadingWidget(),
          error: (_, __) => const EmptyWidget(message: 'Error al cargar créditos'),
          data: (creditos) {
            if (creditos.isEmpty) return const EmptyWidget(message: 'No tienes créditos activos');
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: creditos.length,
              itemBuilder: (_, i) {
                final c = creditos[i];
                final isMora = c.diasMora > 0;
                return Card(
                  elevation: 0,
                  color: AppColors.background,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isMora ? AppColors.error.withValues(alpha: 0.3) : AppColors.border, width: 0.5),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.push('/creditos/${c.codCuentaCredito}'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: (isMora ? AppColors.error : AppColors.secondary).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.assignment_outlined, size: 22,
                                  color: isMora ? AppColors.error : AppColors.secondary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.producto ?? 'Crédito',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  Text(c.codCuentaCredito,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              )),
                              if (isMora)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('${c.diasMora}d mora',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.error)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabel('Saldo', 'S/ ${c.saldoTotal?.toStringAsFixed(2) ?? '0.00'}'),
                              _buildLabel('Desembolsado', 'S/ ${c.montoDesembolsado?.toStringAsFixed(2) ?? '0.00'}'),
                              if (c.cuotasTotal != null)
                                _buildLabel('Cuotas', '${c.cuotasPagadas ?? 0}/${c.cuotasTotal}'),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildLabel(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
