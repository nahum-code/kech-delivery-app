import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/contracts/role_selection_actions.dart';
import '../../../../shared/theme/role_selection_tokens.dart';
import '../../../../shared/widgets/role_selection/role_selection_bottom_bar.dart';
import '../../../../shared/widgets/role_selection/role_selection_customer_tile.dart';
import '../../../../shared/widgets/role_selection/role_selection_driver_tile.dart';
import '../../../../shared/widgets/role_selection/role_selection_header_block.dart';
import '../../../../shared/widgets/role_selection/role_selection_or_divider.dart';
import '../../../../shared/widgets/role_selection/role_selection_watermark.dart';

/// Shared role selection UI for customer and driver entry (actions supplied by app shell).
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, required this.actions});

  final RoleSelectionActions actions;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            const RoleSelectionWatermark(),
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      RoleSelectionTokens.horizontalPadding,
                      12,
                      RoleSelectionTokens.horizontalPadding,
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        <Widget>[
                          const RoleSelectionHeaderBlock(),
                          const SizedBox(height: 28),
                          RoleSelectionCustomerTile(onPressed: actions.onContinueAsCustomer),
                          const RoleSelectionOrDivider(),
                          RoleSelectionDriverTile(onPressed: actions.onContinueAsDriver),
                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        RoleSelectionTokens.horizontalPadding,
                        0,
                        RoleSelectionTokens.horizontalPadding,
                        16,
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: RoleSelectionBottomBar(actions: actions),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
