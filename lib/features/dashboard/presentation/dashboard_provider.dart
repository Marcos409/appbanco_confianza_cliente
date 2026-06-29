import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardResumenProvider = FutureProvider<DashboardResumen>((ref) async {
  return ref.watch(dashboardRepositoryProvider).getResumen();
});
