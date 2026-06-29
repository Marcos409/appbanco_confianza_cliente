import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _fechaNacimiento;
  final _fechaNacimientoController = TextEditingController();
  String? _estadoCivil;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _aceptoTerminos = false;

  static const _estadosCiviles = [
    'Soltero',
    'Casado',
    'Conviviente',
    'Divorciado',
    'Viudo',
  ];

  @override
  void dispose() {
    _dniController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _fechaNacimientoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final now = DateTime.now();
    final maxDate = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? maxDate,
      firstDate: DateTime(1900),
      lastDate: maxDate,
      helpText: 'Selecciona tu fecha de nacimiento',
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
        _fechaNacimientoController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  int _calcularEdad(DateTime fechaNac) {
    final hoy = DateTime.now();
    int edad = hoy.year - fechaNac.year;
    if (hoy.month < fechaNac.month ||
        (hoy.month == fechaNac.month && hoy.day < fechaNac.day)) {
      edad--;
    }
    return edad;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_aceptoTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Debes aceptar los términos y condiciones'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    ref.read(authProvider.notifier).register(
      numeroDocumento: _dniController.text.trim(),
      nombres: _nombresController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      fechaNacimiento: _fechaNacimiento!,
      estadoCivil: _estadoCivil!,
      email: _emailController.text.trim(),
      telefono: _telefonoController.text.trim(),
      direccion: _direccionController.text.trim(),
      password: _passwordController.text,
      aceptoTerminos: _aceptoTerminos,
    ).then((resp) {
      if (resp != null && resp.status == 'success' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(resp.message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Crear Cuenta',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa tus datos para registrarte',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  _buildDniField(),
                  const SizedBox(height: 14),
                  _buildNombresField(),
                  const SizedBox(height: 14),
                  _buildApellidosField(),
                  const SizedBox(height: 14),
                  _buildEmailField(),
                  const SizedBox(height: 14),
                  _buildTelefonoField(),
                  const SizedBox(height: 14),
                  _buildFechaNacimientoField(),
                  const SizedBox(height: 14),
                  _buildEstadoCivilField(),
                  const SizedBox(height: 14),
                  _buildDireccionField(),
                  const SizedBox(height: 14),
                  _buildPasswordField(),
                  const SizedBox(height: 14),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 12),
                  _buildTerminosCheckbox(),
                  const SizedBox(height: 20),
                  _buildRegisterButton(authState),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDniField() {
    return TextFormField(
      controller: _dniController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      maxLength: 8,
      decoration: const InputDecoration(
        labelText: 'DNI',
        hintText: '8 dígitos',
        prefixIcon: Icon(Icons.badge_outlined),
        counterText: '',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'El DNI es requerido';
        if (v.trim().length != 8) return 'El DNI debe tener 8 dígitos';
        if (!RegExp(r'^\d+$').hasMatch(v.trim())) return 'Solo números';
        return null;
      },
    );
  }

  Widget _buildNombresField() {
    return TextFormField(
      controller: _nombresController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Nombres',
        hintText: 'Ingresa tus nombres',
        prefixIcon: Icon(Icons.person_outline),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Los nombres son requeridos';
        return null;
      },
    );
  }

  Widget _buildApellidosField() {
    return TextFormField(
      controller: _apellidosController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Apellidos',
        hintText: 'Ingresa tus apellidos',
        prefixIcon: Icon(Icons.person_outline),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Los apellidos son requeridos';
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Correo electrónico',
        hintText: 'ejemplo@correo.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'El email es requerido';
        final regex = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
        if (!regex.hasMatch(v.trim())) return 'Email inválido';
        return null;
      },
    );
  }

  Widget _buildTelefonoField() {
    return TextFormField(
      controller: _telefonoController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      maxLength: 9,
      decoration: const InputDecoration(
        labelText: 'Teléfono',
        hintText: '9 dígitos',
        prefixIcon: Icon(Icons.phone_outlined),
        counterText: '',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'El teléfono es requerido';
        if (v.trim().length != 9) return 'El teléfono debe tener 9 dígitos';
        if (!RegExp(r'^\d+$').hasMatch(v.trim())) return 'Solo números';
        return null;
      },
    );
  }

  Widget _buildFechaNacimientoField() {
    return TextFormField(
      controller: _fechaNacimientoController,
      readOnly: true,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Fecha de nacimiento',
        hintText: 'DD/MM/AAAA',
        prefixIcon: Icon(Icons.calendar_today_outlined),
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
      onTap: _seleccionarFecha,
      validator: (v) {
        if (_fechaNacimiento == null) return 'La fecha de nacimiento es requerida';
        final edad = _calcularEdad(_fechaNacimiento!);
        if (edad < 18) return 'Debes ser mayor de 18 años';
        return null;
      },
    );
  }

  Widget _buildEstadoCivilField() {
    return DropdownButtonFormField<String>(
      initialValue: _estadoCivil,
      decoration: const InputDecoration(
        labelText: 'Estado civil',
        hintText: 'Selecciona tu estado civil',
        prefixIcon: Icon(Icons.family_restroom_outlined),
      ),
      items: _estadosCiviles.map((ec) {
        return DropdownMenuItem(value: ec, child: Text(ec));
      }).toList(),
      onChanged: (v) => setState(() => _estadoCivil = v),
      validator: (v) {
        if (v == null || v.isEmpty) return 'El estado civil es requerido';
        return null;
      },
    );
  }

  Widget _buildDireccionField() {
    return TextFormField(
      controller: _direccionController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Dirección',
        hintText: 'Ingresa tu dirección',
        prefixIcon: Icon(Icons.location_on_outlined),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'La dirección es requerida';
        if (v.trim().length < 5) return 'Ingresa una dirección válida (mín. 5 caracteres)';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: AppStrings.password,
        hintText: 'Mínimo 6 caracteres',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'La contraseña es requerida';
        if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirm,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        labelText: 'Confirmar contraseña',
        hintText: 'Repite la contraseña',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Confirma tu contraseña';
        if (v != _passwordController.text) return 'Las contraseñas no coinciden';
        return null;
      },
    );
  }

  Widget _buildTerminosCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _aceptoTerminos,
          onChanged: (v) => setState(() => _aceptoTerminos = v ?? false),
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _aceptoTerminos = !_aceptoTerminos),
            child: Text(
              'Acepto los términos y condiciones',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(AuthState authState) {
    final isDisabled = authState.isLoading;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isDisabled ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: authState.isLoading
            ? const SizedBox(
                height: 22, width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : const Text('Crear cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
