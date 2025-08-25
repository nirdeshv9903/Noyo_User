import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/booking_bloc.dart';
import 'schedule_ride.dart';

class EtaListViewWidget extends StatelessWidget {
  final BuildContext cont;
  final BookingPageArguments arg;
  final dynamic thisValue;

  const EtaListViewWidget(
      {super.key, required this.cont, required this.arg, this.thisValue});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<BookingBloc>(),
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          final bookingBloc =context.read<BookingBloc>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bookingBloc.isMultiTypeVechiles &&
                  !arg.isOutstationRide &&
                  (arg.isWithoutDestinationRide == null ||
                      (arg.isWithoutDestinationRide != null &&
                          !arg.isWithoutDestinationRide!))) ...[
                SizedBox(height: size.width * 0.04),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              if (bookingBloc.showBiddingVehicles) {
                                bookingBloc.add(
                                    SelectBiddingOrDemandEvent(
                                        selectedTypeEta: 'On Demand',
                                        isBidding: false));
                                // For Check near ETA
                                bookingBloc.checkNearByEta(
                                    bookingBloc.nearByDriversData,
                                    thisValue);
                              }
                            },
                            child: Container(
                              height: size.width * 0.08,
                              width: size.width * 0.44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: !bookingBloc.showBiddingVehicles
                                    ? AppColors.secondary
                                    : Theme.of(context)
                                        .dividerColor
                                        .withAlpha((0.4 * 255).toInt()),
                              ),
                              child: Center(
                                child: MyText(
                                  text: AppLocalizations.of(context)!.onDemand,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: !bookingBloc.showBiddingVehicles
                                    ? AppColors.white
                                    :AppColors.black),
                                ),
                              ),
                            ),
                          ),
                          if (arg.isWithoutDestinationRide == null ||
                              !arg.isWithoutDestinationRide!)...[
                            SizedBox(width: size.width * 0.03),
                            InkWell(
                              onTap: () {
                                if (!bookingBloc.showBiddingVehicles) {
                                  bookingBloc.add(
                                      SelectBiddingOrDemandEvent(
                                          selectedTypeEta: 'Bidding',
                                          isBidding: true));
                                  // For Check near ETA
                                  bookingBloc.checkNearByEta(
                                      bookingBloc.nearByDriversData,
                                      thisValue);
                                }
                              },
                              child: Container(
                                height: size.width * 0.08,
                                width: size.width * 0.44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: bookingBloc.showBiddingVehicles
                                    ? AppColors.secondary
                                    : Theme.of(context)
                                        .dividerColor
                                        .withAlpha((0.4 * 255).toInt()),
                                ),
                                child: Center(
                                  child: MyText(
                                    text: AppLocalizations.of(context)!.bidding,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: bookingBloc.showBiddingVehicles
                                    ? AppColors.white
                                    :AppColors.black),
                                  ),
                                ),
                              ),
                            ),
                        ]],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.width * 0.05),
              ],
              if (arg.isWithoutDestinationRide != null &&
                  arg.isWithoutDestinationRide!)
                SizedBox(height: size.width * 0.04),
              if (arg.isOutstationRide) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(height: size.width * 0.02),
                      Container(
                        width: size.width,
                        height: size.width * 0.15,
                        decoration: BoxDecoration(
                          color: (arg.userData.enableOutstationRoundTripFeature == '1')
                             ? Theme.of(context).disabledColor.withAlpha((0.1 * 255).toInt()) : null,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                bookingBloc.isRoundTrip = false;
                                bookingBloc.showReturnDateTime = '';
                                bookingBloc.scheduleDateTimeForReturn = '';
                                bookingBloc.add(UpdateEvent());
                              },
                              child: Container(
                                width: size.width * 0.45,
                                decoration: BoxDecoration(
                                    border:
                                        !bookingBloc.isRoundTrip
                                            ? Border.all(
                                                color: Theme.of(context)
                                                    .primaryColorDark
                                                    .withAlpha((0.5 * 255).toInt()))
                                            : null,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .oneWayTrip,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          if (!bookingBloc.isRoundTrip && arg.userData.enableOutstationRoundTripFeature == '1')
                                            Icon(Icons.check_circle,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .primaryColorDark)
                                        ],
                                      ),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .getDropOff,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if(arg.userData.enableOutstationRoundTripFeature == '1')
                            InkWell(
                              onTap: () {
                                bookingBloc.isRoundTrip = true;
                                bookingBloc.add(UpdateEvent());
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: false,
                                    enableDrag: false,
                                    isDismissible: true,
                                    barrierColor: Theme.of(context).shadowColor,
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    builder: (_) {
                                      return scheduleRide(
                                          context, size, arg, true);
                                    });
                              },
                              child: Container(
                                width: size.width * 0.45,
                                decoration: BoxDecoration(
                                    border:
                                        bookingBloc.isRoundTrip
                                            ? Border.all(
                                                color: Theme.of(context)
                                                    .primaryColorDark
                                                    .withAlpha((0.5 * 255).toInt()))
                                            : null,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .roundTrip,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          if (bookingBloc.isRoundTrip)
                                            Icon(Icons.check_circle,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .primaryColorDark)
                                        ],
                                      ),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .keepTheCarTillReturn,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.width * 0.02),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: false,
                              enableDrag: false,
                              isDismissible: true,
                              barrierColor: Theme.of(context).shadowColor,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              builder: (_) {
                                return scheduleRide(context, size, arg, false);
                              });
                        },
                        child: Row(
                          children: [
                            MyText(
                                text:
                                    '${AppLocalizations.of(context)!.leaveOn} : ',
                                textStyle:
                                    Theme.of(context).textTheme.bodySmall),
                            if (bookingBloc.showDateTime
                                .isNotEmpty) ...[
                              MyText(
                                text: bookingBloc.showDateTime,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontWeight: FontWeight.w600),
                              ),
                            ]
                          ],
                        ),
                      ),
                      SizedBox(height: size.width * 0.01),
                      if (bookingBloc.isRoundTrip)
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: false,
                                enableDrag: false,
                                isDismissible: true,
                                barrierColor: Theme.of(context).shadowColor,
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                builder: (_) {
                                  return scheduleRide(context, size, arg, true);
                                });
                          },
                          child: Row(
                            children: [
                              MyText(
                                text:
                                    '${AppLocalizations.of(context)!.returnBy} : ',
                                textStyle:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                              if (bookingBloc.showReturnDateTime
                                  .isNotEmpty) ...[
                                MyText(
                                  text: bookingBloc.showReturnDateTime,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontWeight: FontWeight.w600),
                                ),
                              ],
                              if (bookingBloc.showReturnDateTime
                                  .isEmpty) ...[
                                MyText(
                                  text:
                                      AppLocalizations.of(context)!.selectDate,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontWeight: FontWeight.w600),
                                ),
                              ]
                            ],
                          ),
                        ),
                      SizedBox(height: size.width * 0.03),
                    ],
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      text: AppLocalizations.of(context)!.rideDetails,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    if ((!bookingBloc.showBiddingVehicles ||
                            !bookingBloc.isMultiTypeVechiles) &&
                        arg.userData.showRideLaterFeature)
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: false,
                              enableDrag: false,
                              isDismissible: true,
                              barrierColor: Theme.of(context).shadowColor,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              builder: (_) {
                                return scheduleRide(context, size, arg, false);
                              });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (bookingBloc.showDateTime
                                  .isEmpty) ...[
                                MyText(
                                  text: AppLocalizations.of(context)!.now,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: size.width * 0.02),
                                Icon(Icons.calendar_month,
                                    size: 20,
                                    color: Theme.of(context).primaryColorDark),
                              ],
                              if (bookingBloc.showDateTime
                                  .isNotEmpty) ...[
                                MyText(
                                  text:
                                      bookingBloc.showDateTime,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                ),
                                Icon(Icons.cancel_outlined,
                                    size: 18,
                                    color: Theme.of(context).primaryColorDark)
                              ]
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: size.width * 0.02),
              ((bookingBloc.isEtaFilter &&
                          !bookingBloc.filterSuccess) ||
                      ((bookingBloc.isMultiTypeVechiles &&
                              bookingBloc.sortedEtaDetailsList
                                  .isEmpty) ||
                          bookingBloc.etaDetailsList.isEmpty))
                  ? SizedBox(
                      height: size.height * 0.49,
                      child: Center(child: Image.asset(AppImages.noDataFound)))
                  : RawScrollbar(
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: bookingBloc.etaScrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        // physics: bookingBloc.enableEtaScrolling
                        //     ? const BouncingScrollPhysics()
                        //     : const NeverScrollableScrollPhysics(),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bookingBloc.isMultiTypeVechiles
                            ? bookingBloc.sortedEtaDetailsList
                                .length
                            : bookingBloc.etaDetailsList.length,
                        itemBuilder: (context, index) {
                          final eta =
                              bookingBloc.isMultiTypeVechiles
                                  ? bookingBloc.sortedEtaDetailsList
                                      .elementAt(index)
                                  : bookingBloc.etaDetailsList
                                      .elementAt(index);
                          return InkWell(
                            onTap: () {
                              bookingBloc.add(
                                  BookingEtaSelectEvent(
                                      selectedVehicleIndex: index,
                                      isOutstationRide: arg.isOutstationRide));
                              final selectedSize = bookingBloc.dropAddressList
                                          .length ==
                                      1
                                  ? bookingBloc.currentSize
                                  : bookingBloc.dropAddressList
                                              .length ==
                                          2
                                      ? bookingBloc.currentSizeTwo
                                      : bookingBloc.currentSizeThree;
                              bookingBloc.updateScrollHeight(selectedSize);
                              bookingBloc.scrollToBottomFunction(context
                                      .read<BookingBloc>()
                                      .dropAddressList
                                      .length);

                              // Jump to the selected size position in the scroll controller
                              bookingBloc.etaScrollController
                                  .jumpTo(selectedSize);

                              // For Check near ETA
                              bookingBloc.checkNearByEta(
                                  bookingBloc.nearByDriversData,
                                  thisValue);
                            },
                            child: Container(
                              width: size.width * 0.99,
                              height: size.width * 0.17,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1.5,
                                    color: (index == 0) 
                                              ? Theme.of(context)
                                                  .primaryColor
                                              : Theme.of(context).cardColor),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(size.width * 0.01),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: eta.vehicleIcon,
                                          height: 45,
                                          width: 45,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                            child: Loader(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Center(
                                            child: Text(""),
                                          ),
                                        ),
                                        SizedBox(width: size.width * 0.03),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              spacing: size.width * 0.02,
                                              children: [
                                                MyText(
                                                  text: eta.name,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                  overflow: TextOverflow.clip,
                                                  maxLines: 1,
                                                ),
                                                eta.hasDiscount &&
                                                        !bookingBloc.showBiddingVehicles
                                                    ? Image(
                                                        image: const AssetImage(
                                                            AppImages.discount),
                                                        height:
                                                            size.width * 0.04,
                                                        width:
                                                            size.width * 0.04)
                                                    : const SizedBox()
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.timer,
                                                  color: Theme.of(context)
                                                      .hintColor,
                                                  size: 14,
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.005),
                                                MyText(
                                                  text: (bookingBloc.nearByEtaVechileList
                                                              .isNotEmpty &&
                                                          bookingBloc.nearByEtaVechileList
                                                              .elementAt(bookingBloc.nearByEtaVechileList
                                                                  .indexWhere((element) =>
                                                                      element.typeId ==
                                                                      eta.typeId))
                                                              .duration
                                                              .isNotEmpty)
                                                      ? bookingBloc.nearByEtaVechileList
                                                          .elementAt(bookingBloc.nearByEtaVechileList
                                                              .indexWhere((element) =>
                                                                  element
                                                                      .typeId ==
                                                                  eta.typeId))
                                                          .duration
                                                      : '--',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        fontSize: 14,
                                                        color: Theme.of(context)
                                                            .hintColor,
                                                      ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.005),
                                                InkWell(
                                                  onTap: () {
                                                    bookingBloc.add(ShowEtaInfoEvent(
                                                            infoIndex: index));
                                                  },
                                                  child: Icon(
                                                    Icons.info,
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                    size: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              MyText(
                                                text:
                                                   (bookingBloc.isRoundTrip) 
                                                   ?  '${eta.currency.toString()} ${eta.pricePerDistance.toStringAsFixed(1)}/${eta.unitInWords}' 
                                                   : '${eta.currency.toString()} ${eta.total.toStringAsFixed(1)}',
                                                textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                    fontSize:
                                                        (eta.hasDiscount && !bookingBloc.showBiddingVehicles)
                                                            ? 14
                                                            : 16,
                                                    fontWeight:
                                                        (eta.hasDiscount && !bookingBloc.showBiddingVehicles)
                                                            ? FontWeight.normal
                                                            : FontWeight.bold,
                                                    color: (eta.hasDiscount &&
                                                            !bookingBloc.showBiddingVehicles)
                                                        ? Theme.of(context)
                                                            .hintColor
                                                        : Theme.of(context)
                                                            .primaryColorDark,
                                                    decoration: (eta
                                                                .hasDiscount &&
                                                            !bookingBloc.showBiddingVehicles)
                                                        ? TextDecoration.lineThrough
                                                        : null,
                                                    decorationColor: Theme.of(context).primaryColorDark,
                                                    decorationThickness: 2),
                                              ),
                                              if (eta.hasDiscount &&
                                                  !bookingBloc.showBiddingVehicles)
                                                MyText(
                                                  text:
                                                      '${eta.currency.toString()} ${eta.discountTotal.toStringAsFixed(1)}',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
