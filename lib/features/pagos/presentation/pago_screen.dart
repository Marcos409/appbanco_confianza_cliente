import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/pagos_repository.dart';
import 'pagos_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/loading_widget.dart';

class PagoScreen extends ConsumerStatefulWidget {
  const PagoScreen({super.key});

  @override
  ConsumerState<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends ConsumerState<PagoScreen> {
  final _montoController = TextEditingController();
  String? _cuentaOrigenSeleccionada;
  String? _creditoDestinoSeleccionado;
  bool _isLoading = false;

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _realizarPago() async {
    if (_cuentaOrigenSeleccionada == null || _creditoDestinoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecciona cuenta origen y crédito destino'),
        backgroundColor: AppColors.warning,
      ));
      return;
    }
    final monto = double.tryParse(_montoController.text.replaceAll(',', '.'));
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ingresa un monto válido'),
        backgroundColor: AppColors.warning,
      ));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(pagosRepositoryProvider).realizarPago(
        cuentaOrigen: _cuentaOrigenSeleccionada!,
        creditoDestino: _creditoDestinoSeleccionado!,
        monto: monto,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(AppStrings.pagoExitoso),
        backgroundColor: AppColors.success,
      ));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${AppStrings.pagoFallido}: ${e.toString().replaceFirst('Exception: ', '')}'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cuentasAsync = ref.watch(cuentasOrigenProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(AppStrings.realizarPago),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: cuentasAsync.when(
        loading: () => const LoadingWidget(),
        error: (_, __) => const Center(child: Text('Error al cargar datos')),
        data: (cuentas) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCuentaOrigenSelector(cuentas),
            const SizedBox(height: 16),
            _buildCreditoDestinoSelector(),
            const SizedBox(height: 16),
            _buildMontoField(),
            const SizedBox(height: 24),
            _buildPagarButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCuentaOrigenSelector(List<CuentaOrigen> cuentas) {
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
            const Text('Cuenta de origen',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _cuentaOrigenSeleccionada,
              decoration: const InputDecoration(
                hintText: 'Selecciona una cuenta',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: cuentas.map((c) => DropdownMenuItem(
                value: c.codCuenta,
                child: Text('${c.codCuenta} - S/ ${c.saldo.toStringAsFixed(2)}'),
              )).toList(),
              onChanged: (v) => setState(() => _cuentaOrigenSeleccionada = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditoDestinoSelector() {
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
            const Text('Crédito destino',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Código del crédito',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _creditoDestinoSeleccionado = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMontoField() {
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
            const Text('Monto a pagar',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: 'S/ ',
                hintText: '0.00',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagarButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _realizarPago,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(height: 22, width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : const Text(AppStrings.confirmarPago,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
