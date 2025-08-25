import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/home_bloc.dart';

class ServicesModuleWidget extends StatelessWidget {
  final BuildContext cont;

  const ServicesModuleWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final homeBloc = context.read<HomeBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: size.width * 0.02, bottom: size.width * 0.03),
          child: MyText(
            text: AppLocalizations.of(context)!.service,
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColorDark,
                ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
          child: Row(
            children: [
              if (context.read<HomeBloc>().userData != null &&
                  (context
                              .read<HomeBloc>()
                              .userData!
                              .enableModulesForApplications ==
                          'taxi' ||
                      context
                              .read<HomeBloc>()
                              .userData!
                              .enableModulesForApplications ==
                          'both'))
                _buildServiceCard(
                  context: context,
                  size: size,
                  index: 0,
                  image: context.read<HomeBloc>().serviceTypeImages[0],
                  title: AppLocalizations.of(context)!.ride,
                  isSelected: context.read<HomeBloc>().selectedServiceType == 0,
                ),
              if (context.read<HomeBloc>().userData != null &&
                  (context
                              .read<HomeBloc>()
                              .userData!
                              .enableModulesForApplications ==
                          'delivery' ||
                      context
                              .read<HomeBloc>()
                              .userData!
                              .enableModulesForApplications ==
                          'both'))
                _buildServiceCard(
                  context: context,
                  size: size,
                  index: 1,
                  image: context.read<HomeBloc>().serviceTypeImages[1],
                  title: AppLocalizations.of(context)!.delivery,
                  isSelected: context.read<HomeBloc>().selectedServiceType == 1,
                ),
              if (homeBloc.userData != null &&
                  (homeBloc.userData!.showRentalRide ||
                      homeBloc.userData!.showTaxiRentalRide ||
                      homeBloc.userData!.showDeliveryRentalRide))
                _buildServiceCard(
                  context: context,
                  size: size,
                  index: 2,
                  image: context.read<HomeBloc>().serviceTypeImages[2],
                  title: AppLocalizations.of(context)!.rental,
                  isSelected: context.read<HomeBloc>().selectedServiceType == 2,
                ),
              if (context.read<HomeBloc>().userData != null &&
                  (context
                          .read<HomeBloc>()
                          .userData!
                          .showOutstationRideFeature ==
                      '1'))
                _buildServiceCard(
                  context: context,
                  size: size,
                  index: 3,
                  image: context.read<HomeBloc>().serviceTypeImages[3],
                  title: AppLocalizations.of(context)!.outStation,
                  isSelected: context.read<HomeBloc>().selectedServiceType == 3,
                  onTap: () {
                    if (context.read<HomeBloc>().pickupAddressList.isNotEmpty) {
                      context
                          .read<HomeBloc>()
                          .add(ServiceTypeChangeEvent(serviceTypeIndex: 3));
                    }
                  },
                ),
            ],
          ),
        ),

        // Quick Actions Section
        SizedBox(height: size.width * 0.05),
        _buildQuickActionsSection(context, size),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: size.width * 0.02,
            bottom: size.width * 0.03,
          ),
          child: MyText(
            text: "Quick Actions",
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColorDark,
                ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.02),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.03),
            child: Column(
              children: [
                // Quick Ride Options
                _buildQuickActionRow(
                  context,
                  size,
                  [
                    _buildQuickActionItem(
                      context,
                      size,
                      icon: Icons.home_outlined,
                      title: "Home",
                      subtitle: "Go to saved home",
                      onTap: () {
                        // Navigate to home destination
                        context.read<HomeBloc>().add(
                              DestinationSelectEvent(isPickupChange: false),
                            );
                      },
                    ),
                    _buildQuickActionItem(
                      context,
                      size,
                      icon: Icons.work_outline,
                      title: "Work",
                      subtitle: "Go to office",
                      onTap: () {
                        // Navigate to work destination
                        context.read<HomeBloc>().add(
                              DestinationSelectEvent(isPickupChange: false),
                            );
                      },
                    ),
                  ],
                ),
                SizedBox(height: size.width * 0.03),
                // Popular Destinations
                _buildQuickActionRow(
                  context,
                  size,
                  [
                    _buildQuickActionItem(
                      context,
                      size,
                      icon: Icons.shopping_bag_outlined,
                      title: "Mall",
                      subtitle: "Shopping centers",
                      onTap: () {
                        // Navigate to mall
                        context.read<HomeBloc>().add(
                              DestinationSelectEvent(isPickupChange: false),
                            );
                      },
                    ),
                    _buildQuickActionItem(
                      context,
                      size,
                      icon: Icons.local_airport_outlined,
                      title: "Airport",
                      subtitle: "Flight terminals",
                      onTap: () {
                        // Navigate to airport
                        context.read<HomeBloc>().add(
                              DestinationSelectEvent(isPickupChange: false),
                            );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionRow(
    BuildContext context,
    Size size,
    List<Widget> children,
  ) {
    return Row(
      children: children.map((child) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
            child: child,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context,
    Size size, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.03),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.02),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(width: size.width * 0.025),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: title,
                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 14,
                        ),
                  ),
                  SizedBox(height: size.width * 0.005),
                  MyText(
                    text: subtitle,
                    textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .primaryColorDark
                              .withOpacity(0.6),
                          fontSize: 11,
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

  Widget _buildServiceCard({
    required BuildContext context,
    required Size size,
    required int index,
    required String image,
    required String title,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: size.width * 0.04),
      child: InkWell(
        onTap: onTap ??
            () {
              context
                  .read<HomeBloc>()
                  .add(ServiceTypeChangeEvent(serviceTypeIndex: index));
            },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: size.width * 0.22,
          width: size.width * 0.18,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(size.width * 0.02),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Theme.of(context).dividerColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  image,
                  height: size.width * 0.08,
                  width: size.width * 0.08,
                ),
              ),
              SizedBox(height: size.width * 0.02),
              MyText(
                text: title,
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColorDark,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
