import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_divider.dart';

import '../../../../../../../common/common.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/booking_bloc.dart';

Widget packageList(BuildContext context, BookingPageArguments arg) {
  final size = MediaQuery.sizeOf(context);
  return BlocBuilder<BookingBloc, BookingState>(builder: (context, state) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      height: 4,
                      width: size.width * 0.15,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: size.width * 0.04),

                  // Service Type Selection
                  if (context.read<BookingBloc>().userData != null &&
                      context
                              .read<BookingBloc>()
                              .userData!
                              .enableModulesForApplications ==
                          'both') ...[
                    _buildSectionHeader(
                        context, AppLocalizations.of(context)!.service),
                    SizedBox(height: size.width * 0.03),
                    _buildServiceTypeSelector(context, size, arg),
                    SizedBox(height: size.width * 0.04),
                    _buildDivider(context),
                    SizedBox(height: size.width * 0.04),
                  ],

                  // Package Selection
                  _buildSectionHeader(
                      context, AppLocalizations.of(context)!.selectPackage),
                  SizedBox(height: size.width * 0.03),

                  if (context
                      .read<BookingBloc>()
                      .rentalPackagesList
                      .isNotEmpty) ...[
                    Expanded(
                      child: ListView.separated(
                        itemCount: context
                            .read<BookingBloc>()
                            .rentalPackagesList
                            .length,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final package = context
                              .read<BookingBloc>()
                              .rentalPackagesList
                              .elementAt(index);
                          return _buildPackageCard(
                              context, size, package, index);
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(height: size.width * 0.03);
                        },
                      ),
                    ),
                  ],

                  if (context.read<BookingBloc>().rentalPackagesList.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Theme.of(context)
                                  .primaryColorDark
                                  .withOpacity(0.3),
                            ),
                            SizedBox(height: size.width * 0.03),
                            MyText(
                              text:
                                  AppLocalizations.of(context)!.noDataAvailable,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .primaryColorDark
                                        .withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Button
          Positioned(
            bottom: 0,
            child: Container(
              width: size.width,
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: CustomButton(
                width: size.width * 0.9,
                height: size.width * 0.12,
                buttonName: AppLocalizations.of(context)!.continueN,
                onTap: () {
                  context.read<BookingBloc>().add(RentalPackageConfirmEvent(
                        picklat: context
                            .read<BookingBloc>()
                            .pickUpAddressList
                            .first
                            .lat
                            .toString(),
                        picklng: context
                            .read<BookingBloc>()
                            .pickUpAddressList
                            .first
                            .lng
                            .toString(),
                      ));
                },
              ),
            ),
          )
        ],
      ),
    );
  });
}

Widget _buildSectionHeader(BuildContext context, String title) {
  return MyText(
    text: title,
    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColorDark,
        ),
  );
}

Widget _buildServiceTypeSelector(
    BuildContext context, Size size, BookingPageArguments arg) {
  return Row(
    children: [
      if ((arg.userData.enableModulesForApplications == 'both' ||
              arg.userData.enableModulesForApplications == 'taxi') &&
          arg.userData.showTaxiRentalRide)
        Expanded(
          child: _buildServiceTypeCard(
            context,
            size,
            'taxi',
            AppLocalizations.of(context)!.taxi,
            Icons.local_taxi_outlined,
          ),
        ),
      if ((arg.userData.enableModulesForApplications == 'both' ||
              arg.userData.enableModulesForApplications == 'delivery') &&
          arg.userData.showDeliveryRentalRide) ...[
        SizedBox(width: size.width * 0.03),
        Expanded(
          child: _buildServiceTypeCard(
            context,
            size,
            'delivery',
            AppLocalizations.of(context)!.delivery,
            Icons.delivery_dining_outlined,
          ),
        ),
      ],
    ],
  );
}

Widget _buildServiceTypeCard(
  BuildContext context,
  Size size,
  String value,
  String title,
  IconData icon,
) {
  final isSelected = context.read<BookingBloc>().transportType == value;

  return InkWell(
    onTap: () {
      context.read<BookingBloc>().selectedPackageIndex = 0;
      context.read<BookingBloc>().transportType = value;
      context.read<BookingBloc>().selectedPaymentType = 'cash';
      context.read<BookingBloc>().isSavedCardChoose = false;
      context.read<BookingBloc>().selectedCardToken = '';
      context.read<BookingBloc>().add(BookingRentalEtaRequestEvent(
            picklat: context
                .read<BookingBloc>()
                .pickUpAddressList
                .first
                .lat
                .toString(),
            picklng: context
                .read<BookingBloc>()
                .pickUpAddressList
                .first
                .lng
                .toString(),
            transporttype: value,
          ));
      context.read<BookingBloc>().add(UpdateEvent());
    },
    borderRadius: BorderRadius.circular(16),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.width * 0.035,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.015),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.025),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Theme.of(context).dividerColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColorDark.withOpacity(0.7),
            ),
          ),
          SizedBox(height: size.width * 0.02),
          MyText(
            text: title,
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColorDark,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDivider(BuildContext context) {
  return Container(
    height: 1,
    decoration: BoxDecoration(
      color: Theme.of(context).dividerColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(1),
    ),
  );
}

Widget _buildPackageCard(
    BuildContext context, Size size, dynamic package, int index) {
  final isSelected = index == context.read<BookingBloc>().selectedPackageIndex;

  return InkWell(
    onTap: () {
      context
          .read<BookingBloc>()
          .add(BookingRentalPackageSelectEvent(selectedPackageIndex: index));
    },
    borderRadius: BorderRadius.circular(16),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.015),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: package.packageName,
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColorDark,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: size.width * 0.01),
                MyText(
                  text: package.shortDescription,
                  textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).primaryColorDark.withOpacity(0.6),
                        fontSize: 13,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.03,
              vertical: size.width * 0.02,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: MyText(
              text:
                  '${package.currency.toString()} ${package.minPrice!.toStringAsFixed(1)} - ${package.currency.toString()} ${package.maxPrice!.toStringAsFixed(1)}',
              textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).primaryColorDark,
                  ),
            ),
          ),
        ],
      ),
    ),
  );
}
