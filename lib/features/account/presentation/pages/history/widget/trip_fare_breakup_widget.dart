import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../bookingpage/presentation/page/invoice/widget/fare_breakup.dart';
import '../../../../application/acc_bloc.dart';

class TripFarebreakupWidget extends StatelessWidget {
  final BuildContext cont;
  final TripHistoryPageArguments arg;
  const TripFarebreakupWidget(
      {super.key, required this.cont, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.all(size.width * 0.02),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (arg.historyData.isCancelled == 1)
                      MyText(
                        text: AppLocalizations.of(context)!.cancelled,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(
                                color: AppColors.red,
                                fontWeight: FontWeight.w600),
                      ),
                    if (arg.historyData.isCompleted == 1)
                      MyText(
                        text: AppLocalizations.of(context)!.fareBreakup,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontWeight: FontWeight.w600),
                      )
                  ],
                ),
                SizedBox(height: size.width * 0.025),
                (arg.historyData.isBidRide == 1 &&
                        arg.historyData.isCancelled == 0)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              SizedBox(height: size.width * 0.025),
                              MyText(
                                  text: (arg.historyData.paymentOpt == '1')
                                      ? AppLocalizations.of(context)!.cash
                                      : (arg.historyData.paymentOpt == '2')
                                          ? AppLocalizations.of(context)!.wallet
                                          : (arg.historyData.paymentOpt == '0')
                                              ? AppLocalizations.of(context)!
                                                  .card
                                              : '',
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge),
                              (arg.historyData.requestBill == null)
                                  ? MyText(
                                      text: (arg.historyData.isBidRide == 1)
                                          ? '${arg.historyData.requestedCurrencySymbol} ${arg.historyData.acceptedRideFare}'
                                          : (arg.historyData.isCompleted == 1)
                                              ? '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}'
                                              : '${arg.historyData.requestedCurrencySymbol} ${arg.historyData.requestEtaAmount}')
                                  : MyText(
                                      text:
                                          '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge)
                            ],
                          ),
                        ],
                      )
                    : (arg.historyData.isCancelled == 1)
                        ? const SizedBox()
                        : (arg.historyData.requestBill != null)
                            ? Column(
                                children: [
                                  if (arg.historyData.requestBill.data.basePrice !=
                                      0)
                                    FareBreakup(
                                        showBorder: false,
                                        text: AppLocalizations.of(context)!
                                            .basePrice,
                                        price:
                                            '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.basePrice}'),
                                  if (arg.historyData.requestBill.data
                                          .distancePrice !=
                                      0)
                                    FareBreakup(
                                        showBorder: false,
                                        text:
                                            '${AppLocalizations.of(context)!.distancePrice}(${arg.historyData.totalDistance}${arg.historyData.unit})',
                                        price:
                                            '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.distancePrice}'),
                                  if (arg.historyData.requestBill.data
                                          .timePrice !=
                                      0)
                                    FareBreakup(
                                        showBorder: false,
                                        text:
                                            '${AppLocalizations.of(context)!.timePrice}(${arg.historyData.totalTime} mins x ${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.pricePerTime})',
                                        price:
                                            '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.timePrice}'),
                                  if (arg.historyData.requestBill.data
                                              .waitingCharge !=
                                          0 ||
                                      arg.historyData.requestBill.data
                                              .waitingCharge !=
                                          0.0)
                                    FareBreakup(
                                        showBorder: false,
                                        text:
                                            "${AppLocalizations.of(context)!.waitingPrice} (${arg.historyData.requestBill!.data.requestedCurrencySymbol} ${arg.historyData.requestBill!.data.waitingChargePerMin} x ${arg.historyData.requestBill!.data.calculatedWaitingTime} mins)",
                                        price:
                                            '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.waitingCharge}'),
                                  if (arg.historyData.requestBill.data.adminCommision !=
                                      0)
                                    FareBreakup(
                                        showBorder: false,
                                        text: AppLocalizations.of(context)!
                                            .convenienceFee,
                                        price:
                                            '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.adminCommision}'),
                                  if (arg.historyData.requestBill.data
                                          .promoDiscount !=
                                      0)
                                    FareBreakup(
                                      showBorder: false,
                                      text: AppLocalizations.of(context)!
                                          .discount,
                                      price:
                                          '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.promoDiscount}',
                                      textcolor: AppColors.green,
                                      pricecolor: AppColors.green,
                                    ),
                                  if (arg.historyData.requestBill.data
                                              .additionalChargesAmount !=
                                          0 &&
                                      arg.historyData.requestBill.data
                                              .additionalChargesReason !=
                                          '')
                                    FareBreakup(
                                        showBorder: false,
                                        text: AppLocalizations.of(context)!
                                            .additionalCharges,
                                        price:
                                            '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.additionalChargesAmount}'),
                                  FareBreakup(
                                      showBorder: false,
                                      text: AppLocalizations.of(context)!.taxes,
                                      price:
                                          '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.serviceTax}'),
                                  if (arg.historyData.requestBill.data
                                              .airportSurgeFee !=
                                          0 &&
                                      arg.historyData.requestBill.data
                                              .airportSurgeFee !=
                                          '' &&
                                      arg.historyData.transportType == 'taxi')
                                    FareBreakup(
                                        showBorder: false,
                                        text: AppLocalizations.of(context)!
                                            .airportSurgefee,
                                        price:
                                            '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.airportSurgeFee}'),
                                  if (arg.historyData.requestBill.data
                                              .cancellationFee !=
                                          0.0 &&
                                      arg.historyData.requestBill.data
                                              .cancellationFee !=
                                          0)
                                    FareBreakup(
                                        showBorder: false,
                                        text: AppLocalizations.of(context)!
                                            .cancellationFee,
                                        price:
                                            '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.cancellationFee}'),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      150 ~/ 2,
                                      (index) => Expanded(
                                        child: Container(
                                          height: 2,
                                          color: index.isEven
                                              ? AppColors.textSelectionColor
                                                  .withAlpha(
                                                      (0.5 * 255).toInt())
                                              : Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  (arg.historyData.requestBill != null &&
                                          arg.historyData.isBidRide != 1)
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            bottom: size.width * 0.025,
                                            top: size.width * 0.025,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Row(
                                                children: [
                                                  MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .payment,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(),
                                                  )
                                                ],
                                              )),
                                              Row(
                                                children: [
                                                  MyText(
                                                    text: (arg.historyData
                                                                .paymentOpt ==
                                                            '1')
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .cash
                                                        : (arg.historyData
                                                                    .paymentOpt ==
                                                                '2')
                                                            ? AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .wallet
                                                            : (arg.historyData
                                                                        .paymentOpt ==
                                                                    '0')
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .card
                                                                : '',
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                  SizedBox(
                                                    width: size.width * 0.025,
                                                  ),
                                                  (arg.historyData
                                                              .requestBill ==
                                                          null)
                                                      ? Row(
                                                          children: [
                                                            MyText(
                                                              text: (arg.historyData
                                                                          .isBidRide ==
                                                                      1)
                                                                  ? '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.acceptedRideFare}'
                                                                  : (arg.historyData
                                                                              .isCompleted ==
                                                                          1)
                                                                      ? '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}'
                                                                      : '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.requestEtaAmount}',
                                                              textStyle: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          size.width *
                                                                              0.045),
                                                            ),
                                                          ],
                                                        )
                                                      : MyText(
                                                          text:
                                                              '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}',
                                                          textStyle: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: size
                                                                          .width *
                                                                      0.045))
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox(),
                                  if (arg.historyData.requestBill.data
                                          .driverTips !=
                                      "0")
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: size.width * 0.025,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .tips,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(),
                                          ),
                                          MyText(
                                            text:
                                                '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.driverTips}',
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        size.width * 0.045),
                                          )
                                        ],
                                      ),
                                    )
                                ],
                              )
                            : Container(),
              ],
            ),
          );
        },
      ),
    );
  }
}
