import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final ValueNotifier<bool> offline;

  const OfflineBanner({super.key, required this.offline});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ValueListenableBuilder<bool>(
      valueListenable: offline,
      builder: (context, sinRed, _) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: !sinRed
              ? const SizedBox(width: double.infinity)
              : Container(
                  width: double.infinity,
                  color: colors.errorContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, size: 18, color: colors.onErrorContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sin conexion. Las solicitudes se guardan en el telefono y se envian al volver la red.',
                          style: TextStyle(color: colors.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
