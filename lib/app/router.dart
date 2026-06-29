import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/cuentas/presentation/cuentas_screen.dart';
import '../features/creditos/presentation/creditos_screen.dart';
import '../features/creditos/presentation/cronograma_screen.dart';
import '../features/pagos/presentation/pago_screen.dart';
import '../features/movimientos/presentation/movimientos_screen.dart';
import '../features/notificaciones/presentation/notificaciones_screen.dart';
import '../features/perfil/presentation/perfil_screen.dart';
import '../features/solicitar_credito/presentation/solicitar_credito_screen.dart';
import '../features/estado_solicitudes/presentation/estado_solicitudes_screen.dart';
import '../features/estado_solicitudes/presentation/detalle_solicitud_screen.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

class _ShellScreen extends StatelessWidget {
  final Widget child;
  const _ShellScreen({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    final tabs = [
      ('/inicio', Icons.home_outlined, Icons.home, AppStrings.dashboardTitle),
      ('/creditos', Icons.assignment_outlined, Icons.assignment, AppStrings.misCreditos),
      ('/pagos', Icons.payments_outlined, Icons.payments, AppStrings.realizarPago),
      ('/notificaciones', Icons.notifications_outlined, Icons.notifications, AppStrings.notificaciones),
      ('/perfil', Icons.person_outlined, Icons.person, AppStrings.perfil),
    ];

    int currentIndex = 0;
    for (int i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i].$1)) {
        currentIndex = i;
        break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) {
            final route = tabs[i].$1;
            if (location != route) {
              context.go(route);
            }
          },
          backgroundColor: AppColors.background,
          elevation: 0,
          height: 64,
          destinations: tabs.map((t) {
          return NavigationDestination(
            icon: Icon(t.$2, size: 22),
              selectedIcon: Icon(t.$3, size: 22, color: AppColors.primary),
              label: t.$4,
            );
          }).toList(),
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final goRouter = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.loading || authState.status == AuthStatus.uninitialized;
      final isPublicRoute = state.matchedLocation == '/login' || state.matchedLocation == '/registro';

      if (isLoading && !isPublicRoute) return null;

      if (!isAuthenticated && !isPublicRoute) return '/login';
      if (isAuthenticated && isPublicRoute) return '/inicio';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/registro',
        name: 'registro',
        builder: (_, __) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => _ShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/inicio',
            name: 'inicio',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/creditos',
            name: 'creditos',
            builder: (_, __) => const CreditosScreen(),
            routes: [
              GoRoute(
                path: ':codCredito',
                name: 'cronograma',
                builder: (_, state) => CronogramaScreen(
                  codCuentaCredito: state.pathParameters['codCredito'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/pagos',
            name: 'pagos',
            builder: (_, __) => const PagoScreen(),
          ),
          GoRoute(
            path: '/notificaciones',
            name: 'notificaciones',
            builder: (_, __) => const NotificacionesScreen(),
          ),
          GoRoute(
            path: '/perfil',
            name: 'perfil',
            builder: (_, __) => const PerfilScreen(),
          ),
          GoRoute(
            path: '/solicitar-credito',
            name: 'solicitarCredito',
            builder: (_, __) => const SolicitarCreditoScreen(),
          ),
          GoRoute(
            path: '/estado-solicitudes',
            name: 'estadoSolicitudes',
            builder: (_, __) => const EstadoSolicitudesScreen(),
            routes: [
              GoRoute(
                path: ':solicitudId',
                name: 'detalleSolicitud',
                builder: (_, state) => DetalleSolicitudScreen(
                  solicitudId: state.pathParameters['solicitudId'] ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/cuentas',
        name: 'cuentas',
        builder: (_, __) => const CuentasScreen(),
      ),
      GoRoute(
        path: '/movimientos',
        name: 'movimientos',
        builder: (_, __) => const MovimientosScreen(),
      ),
    ],
    errorBuilder: (_, __) => const Scaffold(
      body: Center(child: Text('Página no encontrada')),
    ),
  );

  ref.listen<AuthState>(authProvider, (_, __) {
    goRouter.refresh();
  });

  return goRouter;
});
