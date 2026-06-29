import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notificaciones_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_widget.dart';
import 'package:intl/intl.dart';

class NotificacionesScreen extends ConsumerWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notisAsync = ref.watch(notificacionesListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(notificacionesListProvider.future),
        child: notisAsync.when(
          loading: () => const LoadingWidget(),
          error: (_, __) => const EmptyWidget(message: 'Error al cargar notificaciones'),
          data: (notis) {
            if (notis.isEmpty) return const EmptyWidget(message: 'No tienes notificaciones');
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notis.length,
              itemBuilder: (_, i) {
                final n = notis[i];
                return Card(
                  elevation: 0,
                  color: n.leida ? AppColors.background : AppColors.primary.withValues(alpha: 0.03),
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: n.leida ? AppColors.border : AppColors.primary.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: (n.tipo == 'alerta' ? AppColors.warning : AppColors.info).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        n.tipo == 'alerta' ? Icons.warning_amber_rounded : Icons.notifications_outlined,
                        size: 22,
                        color: n.tipo == 'alerta' ? AppColors.warning : AppColors.info,
                      ),
                    ),
                    title: Text(n.titulo, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (n.cuerpo != null) Text(n.cuerpo!, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(_formatDate(n.createdAt),
                          style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                      ],
                    ),
                    trailing: n.leida
                        ? null
                        : Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle,
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
