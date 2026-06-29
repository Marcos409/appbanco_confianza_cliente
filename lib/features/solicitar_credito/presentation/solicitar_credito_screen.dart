import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'solicitar_credito_provider.dart';

class SolicitarCreditoScreen extends ConsumerStatefulWidget {
  const SolicitarCreditoScreen({super.key});

  @override
  ConsumerState<SolicitarCreditoScreen> createState() => _SolicitarCreditoScreenState();
}

class _SolicitarCreditoScreenState extends ConsumerState<SolicitarCreditoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  final _montoController = TextEditingController();
  final _plazoController = TextEditingController();
  final _ingresosController = TextEditingController();
  final _gastosController = TextEditingController();
  final _patrimonioController = TextEditingController();
  final _negocioController = TextEditingController();
  final _direccionController = TextEditingController();

  String _destinoCredito = 'capital_trabajo';
  String _tipoNegocio = 'comercio';
  int _antiguedadAnios = 0;
  int _antiguedadMeses = 0;
  bool _sending = false;

  final _destinos = [
    ('capital_trabajo', 'Capital de trabajo'),
    ('inversion', 'Inversión'),
    ('consolidacion', 'Consolidación de deudas'),
    ('mejora_vivienda', 'Mejora de vivienda'),
    ('vehiculo', 'Vehículo'),
    ('otros', 'Otros'),
  ];

  final _tiposNegocio = [
    ('comercio', 'Comercio'),
    ('servicios', 'Servicios'),
    ('produccion', 'Producción'),
    ('agricultura', 'Agricultura'),
    ('ganaderia', 'Ganadería'),
    ('transporte', 'Transporte'),
    ('otros', 'Otros'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _montoController.dispose();
    _plazoController.dispose();
    _ingresosController.dispose();
    _gastosController.dispose();
    _patrimonioController.dispose();
    _negocioController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      final data = {
        'numero_documento': '',
        'nombres': '',
        'apellidos': '',
        'monto_solicitado': double.parse(_montoController.text),
        'plazo_meses': int.parse(_plazoController.text),
        'ingresos_estimados': double.tryParse(_ingresosController.text),
        'gastos_mensuales': double.tryParse(_gastosController.text),
        'patrimonio': double.tryParse(_patrimonioController.text),
        'destino_credito': _destinoCredito,
        'tipo_negocio': _tipoNegocio,
        'nombre_negocio': _negocioController.text.isNotEmpty ? _negocioController.text : null,
        'direccion_negocio': _direccionController.text.isNotEmpty ? _direccionController.text : null,
        'antiguedad_anios': _antiguedadAnios,
        'antiguedad_meses': _antiguedadMeses,
      };
      await ref.read(solicitudesRepositoryProvider).crearSolicitud(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud enviada con éxito'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      String msg = 'Error al enviar la solicitud';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          msg = data['detail'] ?? data['message'] ?? msg;
        } else {
          msg = data.toString();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Solicitar Crédito'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildStepper(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildDatosCredito(),
                  _buildDatosNegocio(),
                  _buildResumen(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.background,
      child: Row(
        children: [
          _stepIndicator(1, 'Crédito', _currentPage >= 0),
          _stepLine(_currentPage >= 1),
          _stepIndicator(2, 'Negocio', _currentPage >= 1),
          _stepLine(_currentPage >= 2),
          _stepIndicator(3, 'Confirmar', _currentPage >= 2),
        ],
      ),
    );
  }

  Widget _stepIndicator(int number, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : AppColors.border,
          ),
          child: Center(child: Text('$number', style: TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold,
          ))),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
          fontSize: 11, color: active ? AppColors.primary : AppColors.textHint,
        )),
      ],
    );
  }

  Widget _stepLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: active ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildDatosCredito() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Información del Crédito', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
        )),
        const SizedBox(height: 20),
        TextFormField(
          controller: _montoController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Monto solicitado',
            prefixText: 'S/ ',
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ingrese el monto';
            final n = double.tryParse(v);
            if (n == null || n < 100) return 'Monto mínimo S/ 100';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _plazoController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Plazo (meses)'),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ingrese el plazo';
            final n = int.tryParse(v);
            if (n == null || n < 1 || n > 120) return 'Plazo entre 1 y 120 meses';
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _destinoCredito,
          decoration: const InputDecoration(labelText: 'Destino del crédito'),
          items: _destinos.map((d) => DropdownMenuItem(value: d.$1, child: Text(d.$2))).toList(),
          onChanged: (v) => setState(() => _destinoCredito = v!),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ingresosController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Ingresos estimados mensuales', prefixText: 'S/ '),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _gastosController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Gastos mensuales', prefixText: 'S/ '),
        ),
      ],
    );
  }

  Widget _buildDatosNegocio() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Información del Negocio', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
        )),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          initialValue: _tipoNegocio,
          decoration: const InputDecoration(labelText: 'Tipo de negocio'),
          items: _tiposNegocio.map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2))).toList(),
          onChanged: (v) => setState(() => _tipoNegocio = v!),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _negocioController,
          decoration: const InputDecoration(labelText: 'Nombre del negocio'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _direccionController,
          decoration: const InputDecoration(labelText: 'Dirección del negocio'),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _antiguedadAnios,
                decoration: const InputDecoration(labelText: 'Años'),
                items: List.generate(31, (i) => DropdownMenuItem(value: i, child: Text('$i años'))),
                onChanged: (v) => setState(() => _antiguedadAnios = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _antiguedadMeses,
                decoration: const InputDecoration(labelText: 'Meses'),
                items: List.generate(12, (i) => DropdownMenuItem(value: i, child: Text('$i meses'))),
                onChanged: (v) => setState(() => _antiguedadMeses = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _patrimonioController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Patrimonio estimado', prefixText: 'S/ '),
        ),
      ],
    );
  }

  Widget _buildResumen() {
    final monto = _montoController.text;
    final plazo = _plazoController.text;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Confirmar Solicitud', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
        )),
        const SizedBox(height: 20),
        _resumenItem('Monto solicitado', 'S/ ${double.tryParse(monto)?.toStringAsFixed(2) ?? monto}'),
        _resumenItem('Plazo', '$plazo meses'),
        _resumenItem('Destino', _destinos.firstWhere((d) => d.$1 == _destinoCredito).$2),
        _resumenItem('Tipo de negocio', _tiposNegocio.firstWhere((t) => t.$1 == _tipoNegocio).$2),
        _resumenItem('Ingresos', 'S/ ${_ingresosController.text.isNotEmpty ? _ingresosController.text : '—'}'),
        _resumenItem('Gastos', 'S/ ${_gastosController.text.isNotEmpty ? _gastosController.text : '—'}'),
        if (_antiguedadAnios > 0 || _antiguedadMeses > 0)
          _resumenItem('Antigüedad', '${_antiguedadAnios}a ${_antiguedadMeses}m'),
      ],
    );
  }

  Widget _resumenItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300), curve: Curves.easeInOut,
                ),
                child: const Text('Anterior'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 12),
          Expanded(
            child: _currentPage < 2
                ? ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Siguiente', style: TextStyle(color: Colors.white)),
                  )
                : ElevatedButton(
                    onPressed: _sending ? null : _enviarSolicitud,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    child: _sending
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Enviar Solicitud', style: TextStyle(color: Colors.white)),
                  ),
          ),
        ],
      ),
    );
  }
}
