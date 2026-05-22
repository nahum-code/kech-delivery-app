import 'package:flutter/material.dart';

import '../../../../../shared/theme/driver_app_tokens.dart';
import '../../../../../shared/theme/driver_task_tokens.dart';

/// Centered empty state for Tasks sub-tabs (mockup layout).
class DriverTasksTabEmptyState extends StatelessWidget {
  const DriverTasksTabEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.onCheckUpdates,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onCheckUpdates;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: DriverTaskTokens.routeBox,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: DriverAppTokens.emptyIconBorder, width: 1.5),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 40,
                  color: DriverTaskTokens.primary,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: DriverTaskTokens.ink,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: DriverAppTokens.emptySubtitle,
                  ),
                ),
              ),
              if (onCheckUpdates != null) ...<Widget>[
                const SizedBox(height: 28),
                Material(
                  color: DriverTaskTokens.routeBox,
                  borderRadius: BorderRadius.circular(28),
                  child: InkWell(
                    onTap: onCheckUpdates,
                    borderRadius: BorderRadius.circular(28),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.sync, size: 20, color: DriverTaskTokens.primary),
                          const SizedBox(width: 10),
                          Text(
                            'CHECK FOR UPDATES',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.4,
                              color: DriverTaskTokens.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
