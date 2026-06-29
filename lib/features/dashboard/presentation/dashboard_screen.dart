import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/dashboard_repository.dart';
import 'dashboard_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/loading_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumenAsync = ref.watch(dashboardResumenProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Confianza',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardResumenProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Resumen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            resumenAsync.when(
              loading: () => const LoadingWidget(),
              error: (err, _) => _buildError(context, ref),
              data: (resumen) => Column(
                children: [
                  _buildResumenCards(context, resumen),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenCards(BuildContext context, DashboardResumen resumen) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildCard(
              context,
              icon: Icons.account_balance,
              label: 'Saldo total',
              value: 'S/ ${resumen.saldoTotal.toStringAsFixed(2)}',
              color: AppColors.success,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildCard(
              context,
              icon: Icons.credit_card,
              label: 'Deuda total',
              value: 'S/ ${resumen.deudaTotal.toStringAsFixed(2)}',
              color: AppColors.warning,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildCard(
              context,
              icon: Icons.savings_outlined,
              label: 'Cuentas',
              value: '${resumen.totalCuentas}',
              color: AppColors.info,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildCard(
              context,
              icon: Icons.assignment_outlined,
              label: 'Créditos',
              value: '${resumen.totalCreditos}',
              color: AppColors.secondary,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500,
            )),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Acciones rápidas', style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold, color: AppColors.textPrimary,
        )),
        const SizedBox(height: 12),
        _buildActionItem(context, Icons.account_balance_outlined, AppStrings.misCuentas, '/cuentas'),
        _buildActionItem(context, Icons.assignment_outlined, AppStrings.misCreditos, '/creditos'),
        _buildActionItem(context, Icons.add_circle_outline, AppStrings.solicitarCredito, '/solicitar-credito'),
        _buildActionItem(context, Icons.track_changes_outlined, AppStrings.estadoSolicitudes, '/estado-solicitudes'),
        _buildActionItem(context, Icons.payments_outlined, AppStrings.realizarPago, '/pagos'),
        _buildActionItem(context, Icons.swap_horiz, AppStrings.movimientos, '/movimientos'),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, String route) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: () => context.push(route),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          const Text('Error al cargar datos'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => ref.refresh(dashboardResumenProvider.future),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
