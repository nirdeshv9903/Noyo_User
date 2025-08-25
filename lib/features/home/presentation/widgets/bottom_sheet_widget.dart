import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_divider.dart';
import '../../../../core/utils/custom_navigation_icon.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../application/home_bloc.dart';
import '../../domain/models/user_details_model.dart';
import 'banner_widget.dart';
import 'home_on_going_rides.dart';
import 'recent_search_places_widget.dart';
import 'services_module_widget.dart';

class BottomSheetWidget extends StatelessWidget {
  final BuildContext cont;

  const BottomSheetWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
        value: cont.read<HomeBloc>(),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Container(
              height: size.height,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  if (!context.read<HomeBloc>().isSheetAtTop) ...[
                    SizedBox(height: size.width * 0.04),
                    Center(
                        child: Container(
                      height: 4,
                      width: size.width * 0.15,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )),
                    SizedBox(height: size.width * 0.03),
                  ],

                  // Top spacing when sheet is at top
                  if (context.read<HomeBloc>().isSheetAtTop)
                    SizedBox(height: size.width * 0.08),

                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.04),
                      child: BlocBuilder<HomeBloc, HomeState>(
                        builder: (context, state) {
                          final homeBloc = context.read<HomeBloc>();
                          if (homeBloc.userData == null) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with menu and search
                              _buildHeader(context, size),

                              // Banner (only when sheet is not at top)
                              if (context.read<HomeBloc>().isSheetAtTop ==
                                      false &&
                                  context.read<HomeBloc>().userData != null &&
                                  homeBloc.userData!.bannerImage != null &&
                                  context
                                      .read<HomeBloc>()
                                      .userData!
                                      .bannerImage
                                      .data
                                      .isNotEmpty) ...[
                                SizedBox(height: size.width * 0.04),
                                BannerWidget(cont: context),
                              ],

                              // Service Modules
                              if (context.read<HomeBloc>().userData != null &&
                                  ((context
                                              .read<HomeBloc>()
                                              .userData!
                                              .enableModulesForApplications ==
                                          'both') ||
                                      (context
                                                  .read<HomeBloc>()
                                                  .userData!
                                                  .enableModulesForApplications ==
                                              'taxi' &&
                                          context
                                              .read<HomeBloc>()
                                              .userData!
                                              .showRentalRide) ||
                                      (context
                                                  .read<HomeBloc>()
                                                  .userData!
                                                  .enableModulesForApplications ==
                                              'delivery' &&
                                          context
                                              .read<HomeBloc>()
                                              .userData!
                                              .showRentalRide))) ...[
                                SizedBox(height: size.width * 0.05),
                                ServicesModuleWidget(cont: cont),
                              ],

                              // ON GOING RIDES
                              if (context.read<HomeBloc>().isMultipleRide) ...[
                                SizedBox(height: size.width * 0.05),
                                _buildSectionHeader(
                                  context,
                                  AppLocalizations.of(context)!.onGoingRides,
                                ),
                                SizedBox(height: size.width * 0.02),
                                HomeOnGoingRidesWidget(cont: context),
                              ],

                              // Recent search places
                              if (context
                                  .read<HomeBloc>()
                                  .recentSearchPlaces
                                  .isNotEmpty) ...[
                                SizedBox(height: size.width * 0.05),
                                _buildSectionHeader(
                                  context,
                                  "Recent Searches",
                                ),
                                SizedBox(height: size.width * 0.02),
                                RecentSearchPlacesWidget(cont: context),
                              ],

                              // Bottom spacing
                              SizedBox(height: size.width * 0.08),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // Banner when sheet is at top
                  if (context.read<HomeBloc>().isSheetAtTop == true &&
                      context.read<HomeBloc>().userData != null &&
                      context.read<HomeBloc>().userData!.bannerImage != null &&
                      context
                          .read<HomeBloc>()
                          .userData!
                          .bannerImage
                          .data
                          .isNotEmpty) ...[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.04),
                      child: BannerWidget(cont: context),
                    ),
                    SizedBox(height: size.width * 0.04),
                  ],
                ],
              ),
            );
          },
        ));
  }

  Widget _buildHeader(BuildContext context, Size size) {
    return Row(
      children: [
        // Menu button (only when sheet is at top)
        if (context.read<HomeBloc>().isSheetAtTop == true &&
            context.read<HomeBloc>().userData != null)
          NavigationIconWidget(
            icon: InkWell(
              onTap: () {
                Navigator.pushNamed(context, AccountPage.routeName,
                        arguments: AccountPageArguments(
                            userData: context.read<HomeBloc>().userData!))
                    .then((value) {
                  if (!context.mounted) return;
                  context.read<HomeBloc>().add(GetDirectionEvent());
                  if (value != null) {
                    context.read<HomeBloc>().userData = value as UserDetail;
                    context.read<HomeBloc>().add(UpdateEvent());
                  }
                });
              },
              child: Icon(
                Icons.menu,
                size: 24,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            isShadowWidget: true,
          ),

        if (context.read<HomeBloc>().isSheetAtTop)
          SizedBox(width: size.width * 0.03),

        // Search bar
        Expanded(
          child: _buildSearchBar(context, size),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, Size size) {
    return InkWell(
      onTap: () {
        final homeBloc = context.read<HomeBloc>();
        if (homeBloc.userData != null) {
          if (homeBloc.userData!.enableModulesForApplications == 'both' ||
              homeBloc.userData!.enableModulesForApplications == 'taxi') {
            homeBloc.add(DestinationSelectEvent(isPickupChange: false));
          } else {
            homeBloc.add(ServiceTypeChangeEvent(serviceTypeIndex: 1));
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.02,
          vertical: size.width * 0.02,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                Icons.search,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: MyText(
                text: AppLocalizations.of(context)!.whereAreYouGoing,
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.7),
                      fontSize: 16,
                    ),
              ),
            ),
            // Skip button for ride without destination
            if (context.read<HomeBloc>().userData != null &&
                (context
                        .read<HomeBloc>()
                        .userData!
                        .showRideWithoutDestination ==
                    "1") &&
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
              InkWell(
                onTap: () {
                  final homeBloc = context.read<HomeBloc>();
                  if (homeBloc.userData != null) {
                    homeBloc.add(RideWithoutDestinationEvent());
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.02),
                  child: MyText(
                    text: AppLocalizations.of(context)!.skip,
                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final size = MediaQuery.sizeOf(context);
    return Padding(
      padding: EdgeInsets.only(left: size.width * 0.02),
      child: MyText(
        text: title,
        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColorDark,
            ),
      ),
    );
  }
}
