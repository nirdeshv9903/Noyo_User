import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../../common/common.dart';
import '../../../../../../../common/pickup_icon.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../application/booking_bloc.dart';

class BiddingOfferingPriceWidget extends StatelessWidget {
  final BuildContext cont;
  final BookingPageArguments arg;
  const BiddingOfferingPriceWidget(
      {super.key, required this.cont, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<BookingBloc>(),
      child: BlocBuilder<BookingBloc, BookingState>(builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.width * 0.01),
                MyText(
                    text: context.read<BookingBloc>().isMultiTypeVechiles
                        ? context
                            .read<BookingBloc>()
                            .sortedEtaDetailsList[context
                                .read<BookingBloc>()
                                .selectedVehicleIndex]
                            .name
                        : context
                            .read<BookingBloc>()
                            .etaDetailsList[context
                                .read<BookingBloc>()
                                .selectedVehicleIndex]
                            .name,
                    textStyle: Theme.of(context).textTheme.bodyLarge),
                SizedBox(height: size.width * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: AppLocalizations.of(context)!.pickupLocation,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Theme.of(context).disabledColor),
                    ),
                    SizedBox(height: size.width * 0.01),
                    ListView.builder(
                        itemCount: context
                            .read<BookingBloc>()
                            .pickUpAddressList
                            .length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final address = context
                              .read<BookingBloc>()
                              .pickUpAddressList
                              .elementAt(index);
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .disabledColor
                                  .withAlpha((0.1 * 255).toInt()),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 5),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.01),
                                    child: const PickupIcon(),
                                  ),
                                  Expanded(
                                    child: MyText(
                                      text: address.address,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    SizedBox(height: size.width * 0.01),
                    MyText(
                      text: AppLocalizations.of(context)!.dropLocation,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Theme.of(context).disabledColor),
                    ),
                    SizedBox(height: size.width * 0.01),
                    ListView.builder(
                        itemCount:
                            context.read<BookingBloc>().dropAddressList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final address = context
                              .read<BookingBloc>()
                              .dropAddressList
                              .elementAt(index);
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .disabledColor
                                  .withAlpha((0.1 * 255).toInt()),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.005),
                                    child: const DropIcon(),
                                  ),
                                  Expanded(
                                    child: MyText(
                                      text: address.address,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ],
                ),
                SizedBox(height: size.width * 0.03),
                Center(
                  child: MyText(
                      text: AppLocalizations.of(context)!.offerYourFare,
                      textStyle: Theme.of(context).textTheme.bodyLarge),
                ),
                SizedBox(height: size.width * 0.005),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText(
                        text: AppLocalizations.of(context)!
                            .minimumRecommendedFare
                            .replaceAll(
                                '***',
                                '${context.read<BookingBloc>().isMultiTypeVechiles ? context.read<BookingBloc>().sortedEtaDetailsList[context.read<BookingBloc>().selectedVehicleIndex].currency : context.read<BookingBloc>().etaDetailsList[context.read<BookingBloc>().selectedVehicleIndex].currency} ${context.read<BookingBloc>().isMultiTypeVechiles ? (arg.isOutstationRide && context.read<BookingBloc>().isRoundTrip) ? (context.read<BookingBloc>().sortedEtaDetailsList[context.read<BookingBloc>().selectedVehicleIndex].minAmount * 2).toStringAsFixed(2) : context.read<BookingBloc>().sortedEtaDetailsList[context.read<BookingBloc>().selectedVehicleIndex].minAmount.toStringAsFixed(2) : (arg.isOutstationRide && context.read<BookingBloc>().isRoundTrip) ? (context.read<BookingBloc>().etaDetailsList[context.read<BookingBloc>().selectedVehicleIndex].minAmount * 2).toStringAsFixed(2) : context.read<BookingBloc>().etaDetailsList[context.read<BookingBloc>().selectedVehicleIndex].minAmount.toStringAsFixed(2)}'),
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).disabledColor)),
                  ],
                ),
                SizedBox(height: size.width * 0.03),
                Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            if (!context
                                .read<BookingBloc>()
                                .isBiddingDecreaseLimitReach) {
                              context.read<BookingBloc>().add(
                                  BiddingIncreaseOrDecreaseEvent(
                                      isIncrease: false,
                                      isOutStation: arg.isOutstationRide));
                            }
                          },
                          child: Container(
                            width: size.width * 0.2,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: context
                                        .read<BookingBloc>()
                                        .isBiddingDecreaseLimitReach
                                    ? Theme.of(context)
                                        .disabledColor
                                        .withAlpha((0.2 * 255).toInt())
                                    : Theme.of(context)
                                        .primaryColor,
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.all(size.width * 0.025),
                            child: MyText(
                              text:
                                  '-${double.parse(context.read<BookingBloc>().userData!.biddingAmountIncreaseOrDecrease.toString())}',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: context
                                              .read<BookingBloc>()
                                              .isBiddingDecreaseLimitReach
                                          ? (Theme.of(context).brightness ==
                                                  Brightness.light)
                                              ? AppColors.black
                                              : AppColors.white
                                          : AppColors.white),
                            ),
                          ),
                        ),
                        Container(
                          width: size.width * 0.3,
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withAlpha((0.5 * 255).toInt()),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            enabled: true,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            controller:
                                context.read<BookingBloc>().farePriceController,
                            decoration:const InputDecoration(
                              border:  UnderlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide()),
                              // prefixIconConstraints:
                              //     BoxConstraints(maxWidth: size.width * 0.2),
                              // prefixIcon: Center(
                              //   child: MyText(
                              //     text: context
                              //             .read<BookingBloc>()
                              //             .isMultiTypeVechiles
                              //         ? context
                              //             .read<BookingBloc>()
                              //             .sortedEtaDetailsList[context
                              //                 .read<BookingBloc>()
                              //                 .selectedVehicleIndex]
                              //             .currency
                              //             .toString()
                              //         : context
                              //             .read<BookingBloc>()
                              //             .etaDetailsList[context
                              //                 .read<BookingBloc>()
                              //                 .selectedVehicleIndex]
                              //             .currency
                              //             .toString(),
                              //     textStyle:
                              //         Theme.of(context).textTheme.displayLarge,
                              //   ),
                              // ),
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (!context
                                .read<BookingBloc>()
                                .isBiddingIncreaseLimitReach) {
                              context.read<BookingBloc>().add(
                                  BiddingIncreaseOrDecreaseEvent(
                                      isIncrease: true,
                                      isOutStation: arg.isOutstationRide));
                            }
                          },
                          child: Container(
                            width: size.width * 0.2,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: context
                                        .read<BookingBloc>()
                                        .isBiddingIncreaseLimitReach
                                    ? Theme.of(context)
                                        .disabledColor
                                        .withAlpha((0.2 * 255).toInt())
                                    : Theme.of(context)
                                        .primaryColor,
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.all(size.width * 0.025),
                            child: MyText(
                              text:
                                  '+${double.parse(context.read<BookingBloc>().userData!.biddingAmountIncreaseOrDecrease.toString())}',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: context
                                              .read<BookingBloc>()
                                              .isBiddingIncreaseLimitReach
                                          ? (Theme.of(context).brightness ==
                                                  Brightness.light)
                                              ? AppColors.black
                                              : AppColors.white
                                          : AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.width * 0.05),
                Center(
                  child: CustomButton(
                    width: size.width,
                    buttonColor: Theme.of(context).primaryColor,
                    buttonName: AppLocalizations.of(context)!.createRequest,
                    isLoader: context.read<BookingBloc>().isLoading,
                    onTap: () {
                      final currencySymbol =
                          context.read<BookingBloc>().isMultiTypeVechiles
                              ? context
                                  .read<BookingBloc>()
                                  .sortedEtaDetailsList[context
                                      .read<BookingBloc>()
                                      .selectedVehicleIndex]
                                  .currency
                              : context
                                  .read<BookingBloc>()
                                  .etaDetailsList[context
                                      .read<BookingBloc>()
                                      .selectedVehicleIndex]
                                  .currency;

                      final total = double.parse(
                          context.read<BookingBloc>().isMultiTypeVechiles
                              ? context
                                  .read<BookingBloc>()
                                  .sortedEtaDetailsList[context
                                      .read<BookingBloc>()
                                      .selectedVehicleIndex]
                                  .total
                                  .toString()
                              : context
                                  .read<BookingBloc>()
                                  .etaDetailsList[context
                                      .read<BookingBloc>()
                                      .selectedVehicleIndex]
                                  .total
                                  .toString());

                      final lowPercentage = double.parse(
                          context.read<BookingBloc>().isMultiTypeVechiles
                              ? context
                                  .read<BookingBloc>()
                                  .sortedEtaDetailsList[context
                                      .read<BookingBloc>()
                                      .selectedVehicleIndex]
                                  .biddingLowPercentage
                              : context
                                  .read<BookingBloc>()
                                  .etaDetailsList[context
                                      .read<BookingBloc>()
                                      .selectedVehicleIndex]
                                  .biddingLowPercentage);

                      final highPercentage = double.parse(
                          context.read<BookingBloc>().isMultiTypeVechiles
                              ? context
                                  .read<BookingBloc>()
                                  .sortedEtaDetailsList[context
                                      .read<BookingBloc>()
                                      .selectedVehicleIndex]
                                  .biddingHighPercentage
                              : context
                                  .read<BookingBloc>()
                                  .etaDetailsList[context
                                      .read<BookingBloc>()
                                      .selectedVehicleIndex]
                                  .biddingHighPercentage);

                      final value = (arg.isOutstationRide &&
                              context.read<BookingBloc>().isRoundTrip)
                          ? ((total * 2) -
                              ((lowPercentage / 100) * (total * 2)))
                          : (total - ((lowPercentage / 100) * total));
                      final highValue = (arg.isOutstationRide &&
                              context.read<BookingBloc>().isRoundTrip)
                          ? ((total * 2) + (highPercentage / 100) * (total * 2))
                          : (total + (highPercentage / 100) * total);

                      if (double.parse(context
                                  .read<BookingBloc>()
                                  .farePriceController
                                  .text) >=
                              value &&
                          double.parse(context
                                  .read<BookingBloc>()
                                  .farePriceController
                                  .text) <=
                              highValue) {
                        Navigator.pop(context);
                        if (arg.transportType == 'taxi' ||
                            (arg.transportType == 'delivery' &&
                                context
                                        .read<BookingBloc>()
                                        .selectedGoodsTypeId !=
                                    0)) {
                          context.read<BookingBloc>().add(BiddingCreateRequestEvent(
                              userData: arg.userData,
                              vehicleData: context.read<BookingBloc>().isMultiTypeVechiles
                                  ? context.read<BookingBloc>().sortedEtaDetailsList[
                                      context
                                          .read<BookingBloc>()
                                          .selectedVehicleIndex]
                                  : context.read<BookingBloc>().etaDetailsList[
                                      context
                                          .read<BookingBloc>()
                                          .selectedVehicleIndex],
                              pickupAddressList: arg.pickupAddressList,
                              dropAddressList: arg.stopAddressList,
                              selectedTransportType: arg.transportType,
                              paidAt: context.read<BookingBloc>().payAtDrop
                                  ? 'Receiver'
                                  : 'Sender',
                              selectedPaymentType: context
                                  .read<BookingBloc>()
                                  .selectedPaymentType,
                              scheduleDateTime:
                                  context.read<BookingBloc>().scheduleDateTime,
                              goodsTypeId: context
                                  .read<BookingBloc>()
                                  .selectedGoodsTypeId
                                  .toString(),
                              goodsQuantity: context
                                  .read<BookingBloc>()
                                  .goodsQtyController
                                  .text,
                              offeredRideFare: context
                                  .read<BookingBloc>()
                                  .farePriceController
                                  .text,
                              polyLine: context.read<BookingBloc>().polyLine,
                              isPetAvailable: context.read<BookingBloc>().petPreference,
                              isLuggageAvailable: context.read<BookingBloc>().luggagePreference,
                              isOutstationRide: arg.isOutstationRide,
                              isRoundTrip: context.read<BookingBloc>().isRoundTrip,
                              scheduleDateTimeForReturn: context.read<BookingBloc>().scheduleDateTimeForReturn,
                              cardToken: context.read<BookingBloc>().selectedCardToken,
                              parcelType: arg.title));
                        } else {
                          showToast(
                              message: AppLocalizations.of(context)!
                                  .pleaseSelectCredentials);
                        }
                      } else {
                        showModalBottomSheet(
                          context: context,
                          isDismissible: true,
                          isScrollControlled: true,
                          enableDrag: false,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.0),
                            ),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          builder: (_) {
                            return BlocProvider.value(
                              value: context.read<BookingBloc>(),
                              child: SafeArea(
                                child: Container(
                                  width: size.width,
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  )),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: size.width * 0.1),
                                        MyText(
                                          text: ((double.parse(context
                                                          .read<BookingBloc>()
                                                          .farePriceController
                                                          .text) >=
                                                      value) ==
                                                  false)
                                              ? '${AppLocalizations.of(context)!.minimumRideFareError} ($currencySymbol ${value.toStringAsFixed(2)})'
                                              : '${AppLocalizations.of(context)!.maximumRideFareError} ($currencySymbol ${highValue.toStringAsFixed(2)})',
                                          maxLines: 3,
                                          textAlign: TextAlign.center,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error),
                                        ),
                                        SizedBox(height: size.width * 0.1),
                                        CustomButton(
                                          width: size.width,
                                          buttonName:
                                              AppLocalizations.of(context)!
                                                  .okText,
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: size.width * 0.2),
              ],
            ),
          ),
        );
      }),
    );
  }
}
