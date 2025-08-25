import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:restart_tagxi/features/bookingpage/presentation/page/review/page/review_page.dart";
import "../../../../../../common/common.dart";
import "../../../../../../common/pickup_icon.dart";
import "../../../../../../core/utils/custom_appbar.dart";
import "../../../../../../core/utils/custom_button.dart";
import "../../../../../../core/utils/custom_loader.dart";
import "../../../../../../core/utils/custom_text.dart";
import "../../../../../../l10n/app_localizations.dart";
import "../../../../application/booking_bloc.dart";
import "../widget/add_tip_widget.dart";
import "../widget/fare_breakup.dart";
import "../widget/payment_gateway_list.dart";

class InvoicePage extends StatelessWidget {
  static const String routeName = '/invoicePage';
  final InvoicePageArguments arg;

  const InvoicePage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => BookingBloc()..add(InvoiceInitEvent(arg: arg)),
      child: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          final bookingBloc = context.read<BookingBloc>();
          if (state is ShowAddTipState) {
            WidgetsBinding.instance.addPostFrameCallback(
              (timeStamp) {
                if (bookingBloc.requestData!.paymentOpt != '2') {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) {
                      return AddTipWidget(
                        cont: context,
                        requestId: bookingBloc.requestData!.id,
                        minimumTipAmount: bookingBloc.requestData!.minimumTipAmount,
                        currencySymbol:
                            bookingBloc.requestBillData!.requestedCurrencySymbol,
                        totalAmount: bookingBloc.requestBillData!.totalAmount,
                        rideRepository: arg.rideRepository,
                      );
                    },
                  );
                }
              },
            );
          } else if (state is TipsAddedState) {
            arg.requestBillData = state.requestBillData;
          } else if (state is WalletPageReUpdateStates) {
            bookingBloc.add(OnRidePaymentWebViewUrlEvent(
                currencySymbol: state.currencySymbol.toString(),
                from: '1',
                money: state.money,
                url: state.url,
                userId: state.userId,
                requestId: state.requestId,
              ),
            );
          }
        },
        child: BlocBuilder<BookingBloc, BookingState>(
          builder: (context, state) {
            final bookingBloc = context.read<BookingBloc>();
            final requestBillData = context.read<BookingBloc>().requestBillData;
            return (requestBillData != null && bookingBloc.requestData !=null)
                ? SafeArea(
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      appBar: CustomAppBar(
                          automaticallyImplyLeading: false,
                          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                          centerTitle: true,
                          title: AppLocalizations.of(context)!.tripSummary),
                      body: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              SizedBox(height: size.width * 0.05),
                              Container(
                                // height: size.width * 0.4,
                                width: size.width,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: size.width * 0.2,
                                            width: size.width * 0.2,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                color: Theme.of(context)
                                                    .dividerColor),
                                            child: (arg.driverData
                                                    .profilePicture.isEmpty)
                                                ? const Icon(
                                                    Icons.person,
                                                    size: 50,
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40),
                                                    child: CachedNetworkImage(
                                                      imageUrl: arg.driverData
                                                          .profilePicture,
                                                      fit: BoxFit.fill,
                                                      placeholder:
                                                          (context, url) =>
                                                              const Center(
                                                        child: Loader(),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Center(
                                                        child: Text(""),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          SizedBox(width: size.width * 0.05),
                                          SizedBox(
                                            width: size.width * 0.55,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                MyText(
                                                  text: arg.driverData.name
                                                      .toUpperCase(),
                                                  maxLines: 5,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark),
                                                  textAlign: TextAlign.start,
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .star_border_outlined,
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                    MyText(
                                                      text: arg
                                                          .driverData.rating
                                                          .toUpperCase(),
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: size.width * 0.025),
                                      MyText(
                                        text: bookingBloc.requestData!.requestNumber,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: size.width * 0.04),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.width * 0.05),
                                  ClipPath(
                                    clipper: _SemiCircleClipper(),
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(size.width * 0.05),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .hintColor
                                            .withAlpha((0.5 * 255).toInt()),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.circle,
                                                      size: 6,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.01),
                                                    MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .duration,
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark
                                                                  .withAlpha((0.7 *
                                                                          255)
                                                                      .toInt())),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              MyText(
                                                text:
                                                    '${bookingBloc.requestData!.totalTime} ${AppLocalizations.of(context)!.mins}',
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .primaryColorDark
                                                            .withAlpha(
                                                                (0.7 * 255)
                                                                    .toInt())),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: size.width * 0.025),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.circle,
                                                      size: 6,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.01),
                                                    MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .distance,
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark
                                                                  .withAlpha((0.7 *
                                                                          255)
                                                                      .toInt())),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              MyText(
                                                text:
                                                    '${bookingBloc.requestData!.totalDistance} ${bookingBloc.requestData!.unit}',
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .primaryColorDark
                                                            .withAlpha(
                                                                (0.7 * 255)
                                                                    .toInt())),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: size.width * 0.025),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.circle,
                                                      size: 6,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.01),
                                                    MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .typeofRide,
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark
                                                                  .withAlpha((0.7 *
                                                                          255)
                                                                      .toInt())),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              MyText(
                                                text: (bookingBloc.requestData!
                                                            .isOutStation ==
                                                        '1')
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .outStation
                                                    : (bookingBloc.requestData!.isRental)
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .rental
                                                        : AppLocalizations.of(
                                                                context)!
                                                            .regular,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .primaryColorDark
                                                            .withAlpha(
                                                                (0.7 * 255)
                                                                    .toInt())),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: size.width * 0.05),
                                          Container(
                                            width: double.infinity,
                                            height: 1,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          SizedBox(height: size.width * 0.05),
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const PickupIcon(),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5),
                                                      child: MyText(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        text: bookingBloc.requestData!
                                                            .pickAddress,
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodySmall,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (bookingBloc.requestData!.requestStops
                                                  .data.isNotEmpty)
                                                ListView.separated(
                                                  itemCount: bookingBloc
                                                      .requestData!
                                                      .requestStops!
                                                      .data
                                                      .length,
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  padding: EdgeInsets.zero,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const DropIcon(),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.02),
                                                        Expanded(
                                                          child: MyText(
                                                            text: bookingBloc
                                                                .requestData!
                                                                .requestStops!
                                                                .data[index]
                                                                .address,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                  separatorBuilder:
                                                      (context, index) {
                                                    return SizedBox(
                                                        height: size.width *
                                                            0.0025);
                                                  },
                                                ),
                                              if (bookingBloc.requestData!.requestStops
                                                  .data.isEmpty)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      const DropIcon(),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 5),
                                                          child: MyText(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            text: bookingBloc
                                                                .requestData!
                                                                .dropAddress,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size.width * 0.05),
                                  if (bookingBloc.requestData!.isBidRide == 1) ...[
                                    Center(
                                      child: MyText(
                                        text: (context
                                                    .read<BookingBloc>()
                                                    .selectedPaymentType ==
                                                'cash')
                                            ? AppLocalizations.of(context)!.cash
                                            : (context
                                                        .read<BookingBloc>()
                                                        .selectedPaymentType ==
                                                    'wallet')
                                                ? AppLocalizations.of(context)!
                                                    .wallet
                                                : AppLocalizations.of(context)!
                                                    .card,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(height: size.width * 0.025),
                                    Center(
                                      child: MyText(
                                          text: requestBillData.driverTips !=
                                                  '0'
                                              ? '${requestBillData.requestedCurrencySymbol} ${double.parse(requestBillData.totalAmount) + double.parse(requestBillData.driverTips)}'
                                              : '${requestBillData.requestedCurrencySymbol} ${requestBillData.totalAmount}',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(fontSize: 25)),
                                    )
                                  ],
                                  if (bookingBloc.requestData!.isBidRide == 0) ...[
                                    Center(
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .fareBreakup,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    SizedBox(height: size.width * 0.025),
                                    Column(
                                      children: [
                                        if (requestBillData.basePrice != 0)
                                          FareBreakup(
                                              text:
                                                  '${AppLocalizations.of(context)!.baseDistancePrice} (${requestBillData.baseDistance} ${requestBillData.unit})',
                                              price:
                                                  '${requestBillData.requestedCurrencySymbol} ${requestBillData.basePrice}'),
                                        if (requestBillData.distancePrice != 0)
                                          FareBreakup(
                                              text:
                                                  '${AppLocalizations.of(context)!.distancePrice} (${requestBillData.requestedCurrencySymbol} ${requestBillData.pricePerDistance} x ${requestBillData.calculatedDistance} ${requestBillData.unit})',
                                              price:
                                                  '${requestBillData.requestedCurrencySymbol} ${requestBillData.distancePrice}'),
                                        if (requestBillData.timePrice != 0)
                                          FareBreakup(
                                              text:
                                                  '${AppLocalizations.of(context)!.timePrice} (${requestBillData.requestedCurrencySymbol} ${requestBillData.pricePerTime} x ${requestBillData.totalTime})',
                                              price:
                                                  '${requestBillData.requestedCurrencySymbol} ${requestBillData.timePrice}'),
                                        if (requestBillData.waitingCharge !=
                                                0 ||
                                            requestBillData.waitingCharge !=
                                                0.0)
                                          FareBreakup(
                                              text:
                                                  '${AppLocalizations.of(context)!.waitingPrice} (${requestBillData.requestedCurrencySymbol} ${requestBillData.waitingChargePerMin} x ${requestBillData.calculatedWaitingTime})',
                                              price:
                                                  '${requestBillData.requestedCurrencySymbol} ${requestBillData.waitingCharge}'),
                                        if (requestBillData.adminCommision != 0)
                                          FareBreakup(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .convenienceFee,
                                              price:
                                                  '${requestBillData.requestedCurrencySymbol} ${requestBillData.adminCommision}'),
                                        if (requestBillData.promoDiscount != 0)
                                          FareBreakup(
                                            text: AppLocalizations.of(context)!
                                                .discount,
                                            price:
                                                '${requestBillData.requestedCurrencySymbol} ${requestBillData.promoDiscount}',
                                            textcolor: AppColors.green,
                                            pricecolor: AppColors.green,
                                          ),
                                        if (requestBillData.airportSurgeFee !=
                                                0 &&
                                            bookingBloc.requestData!.transportType ==
                                                'taxi')
                                          FareBreakup(
                                            text: AppLocalizations.of(context)!
                                                .airportSurgefee,
                                            price:
                                                '${requestBillData.requestedCurrencySymbol} ${requestBillData.airportSurgeFee}',
                                          ),
                                        FareBreakup(
                                            text: AppLocalizations.of(context)!
                                                .taxes,
                                            price:
                                                '${requestBillData.requestedCurrencySymbol} ${requestBillData.serviceTax}'),
                                        if (requestBillData.cancellationFee !=
                                                0.0 &&
                                            requestBillData.cancellationFee !=
                                                0)
                                          FareBreakup(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .cancellationFee,
                                              price:
                                                  '${requestBillData.requestedCurrencySymbol} ${requestBillData.cancellationFee}'),
                                        if (requestBillData
                                                    .additionalChargesAmount !=
                                                0 &&
                                            requestBillData
                                                    .additionalChargesReason !=
                                                null)
                                          FareBreakup(
                                              text:
                                                  '${requestBillData.additionalChargesReason}',
                                              price:
                                                  '${requestBillData.requestedCurrencySymbol} ${requestBillData.additionalChargesAmount}'),
                                        if (requestBillData.driverTips != '0')
                                          FareBreakup(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .tips,
                                              price:
                                                  '${requestBillData.requestedCurrencySymbol} ${requestBillData.driverTips}'),
                                      ],
                                    ),
                                  ],
                                  SizedBox(height: size.width * 0.2),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      bottomNavigationBar: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: size.width * 0.4,
                                  child: Row(
                                    children: [
                                      MyText(
                                        text: (context
                                                    .read<BookingBloc>()
                                                    .selectedPaymentType ==
                                                'cash')
                                            ? AppLocalizations.of(context)!.cash
                                            : (context
                                                        .read<BookingBloc>()
                                                        .selectedPaymentType ==
                                                    'wallet')
                                                ? AppLocalizations.of(context)!
                                                    .wallet
                                                : AppLocalizations.of(context)!
                                                    .card,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: size.width * 0.025),
                                      MyText(
                                        text: requestBillData.driverTips != '0'
                                            ? '${requestBillData.requestedCurrencySymbol} ${double.parse(requestBillData.totalAmount) + double.parse(requestBillData.driverTips)}'
                                            : '${requestBillData.requestedCurrencySymbol} ${requestBillData.totalAmount}',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: size.width * 0.045),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02),
                                Expanded(
                                  child: StreamBuilder<bool>(
                                      stream: arg
                                          .rideRepository.paymentReceivedStream,
                                      builder: (context, snapshot) {
                                        bool isPaymentReceived =
                                            snapshot.data ?? false;
                                        return CustomButton(
                                          width: size.width,
                                          buttonColor:
                                              Theme.of(context).primaryColor,
                                          buttonName: ((isPaymentReceived &&
                                                      (context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .selectedPaymentType ==
                                                              'cash' ||
                                                          context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .selectedPaymentType ==
                                                              'wallet')) ||
                                                  bookingBloc.requestData!.isPaid == 1)
                                              ? AppLocalizations.of(context)!
                                                  .confirm
                                              : AppLocalizations.of(context)!
                                                  .choosePayment,
                                          textSize: 16,
                                          onTap: () {
                                            if ((isPaymentReceived &&
                                                    (bookingBloc.selectedPaymentType ==
                                                            'cash' ||
                                                        bookingBloc.selectedPaymentType ==
                                                            'wallet')) ||
                                              bookingBloc.requestData!.isPaid == 1) {
                                              bookingBloc.requestStreamStart?.cancel();
                                              bookingBloc.rideStreamUpdate?.cancel();
                                              bookingBloc.rideStreamStart?.cancel();
                                              bookingBloc.driverDataStream?.cancel();    
                                              Navigator.pushNamedAndRemoveUntil(
                                                  context,
                                                  ReviewPage.routeName,
                                                  arguments:
                                                      ReviewPageArguments(
                                                          requestId: bookingBloc
                                                              .requestData!.id,
                                                          orderNo: bookingBloc
                                                              .requestData!
                                                              .requestNumber,
                                                          driverData:
                                                              arg.driverData),
                                                  (route) => false);
                                            } else {
                                              showModalBottomSheet(
                                                  context: context,
                                                  barrierColor:
                                                      Theme.of(context)
                                                          .shadowColor,
                                                  backgroundColor: Theme.of(
                                                          context)
                                                      .scaffoldBackgroundColor,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                      top:
                                                          Radius.circular(20.0),
                                                    ),
                                                  ),
                                                  builder: (_) {
                                                    List<String>
                                                        paymentOptions = bookingBloc
                                                            .requestData!
                                                            .paymentType
                                                            .split(',')
                                                            .where((element) =>
                                                                element !=
                                                                'wallet')
                                                            .toList();

                                                    return Container(
                                                      width: size.width,
                                                      padding: EdgeInsets.all(
                                                          size.width * 0.05),
                                                      decoration: BoxDecoration(
                                                          color: Theme
                                                                  .of(context)
                                                              .scaffoldBackgroundColor,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          20),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20))),
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                MyText(
                                                                  text: AppLocalizations.of(
                                                                          context)!
                                                                      .choosePayment,
                                                                  textStyle: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyLarge!
                                                                      .copyWith(
                                                                        color: Theme.of(context)
                                                                            .primaryColorDark,
                                                                      ),
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Icon(
                                                                      Icons
                                                                          .cancel_outlined),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: List.generate(
                                                                  paymentOptions
                                                                      .length,
                                                                  (index) {
                                                                return Theme(
                                                                  data:
                                                                      ThemeData(
                                                                    unselectedWidgetColor:
                                                                        Theme.of(context)
                                                                            .primaryColorDark,
                                                                  ),
                                                                  child:
                                                                      RadioListTile(
                                                                    value: paymentOptions[
                                                                        index],
                                                                    groupValue: context
                                                                        .read<
                                                                            BookingBloc>()
                                                                        .selectedPaymentType,
                                                                    onChanged:
                                                                        (value) {
                                                                      context
                                                                          .read<
                                                                              BookingBloc>()
                                                                          .selectedPaymentType = value.toString();
                                                                      context.read<BookingBloc>().add(ChangePaymentMethodEvent(
                                                                          paymentMethod: context
                                                                              .read<
                                                                                  BookingBloc>()
                                                                              .selectedPaymentType,
                                                                          requestData:
                                                                              bookingBloc.requestData!));
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    activeColor:
                                                                        Theme.of(context)
                                                                            .primaryColorDark,
                                                                    controlAffinity:
                                                                        ListTileControlAffinity
                                                                            .trailing,
                                                                    title:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Icon(
                                                                                paymentOptions[index] == 'cash'
                                                                                    ? Icons.payments_outlined
                                                                                    : (paymentOptions[index] == 'card' || paymentOptions[index] == 'online')
                                                                                        ? Icons.credit_card_rounded
                                                                                        : Icons.account_balance_wallet_outlined,
                                                                                color: Theme.of(context).primaryColorDark),
                                                                            SizedBox(width: size.width * 0.05),
                                                                            MyText(
                                                                              text: paymentOptions[index],
                                                                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }),
                                                            ),
                                                            SizedBox(height:size.width * 0.1)
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            }
                                          },
                                        );
                                      }),
                                )
                              ],
                            ),
                            SizedBox(height: size.width * 0.01),
                            if ((context
                                            .read<BookingBloc>()
                                            .selectedPaymentType ==
                                        'card' ||
                                    context
                                            .read<BookingBloc>()
                                            .selectedPaymentType ==
                                        'online') &&
                                bookingBloc.requestData!.isPaid == 0)
                              CustomButton(
                                width: size.width,
                                buttonColor: Theme.of(context).primaryColor,
                                buttonName:
                                    AppLocalizations.of(context)!.payNow,
                                onTap: () {
                                  if (bookingBloc.requestData!.isCompleted == 1 &&
                                      bookingBloc.requestData!.isPaid == 0 &&
                                      (context
                                                  .read<BookingBloc>()
                                                  .selectedPaymentType ==
                                              'card' ||
                                          context
                                                  .read<BookingBloc>()
                                                  .selectedPaymentType ==
                                              'online')) {
                                    if (bookingBloc.requestData!.paymentGateways
                                        .isNotEmpty) {
                                      showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: false,
                                          enableDrag: true,
                                          isDismissible: true,
                                          builder: (_) {
                                            return BlocProvider.value(
                                              value:
                                                  context.read<BookingBloc>(),
                                              child: PaymentGatewayListWidget(
                                                  cont: context,
                                                  arg: arg,
                                                  walletPaymentGatways: bookingBloc
                                                      .requestData!
                                                      .paymentGateways),
                                            );
                                          });
                                    }
                                  }
                                },
                              )
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox();
          },
        ),
      ),
    );
  }
}

class _SemiCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    final radius = size.height * 0.05;
    final centerY = size.height * 0.6;

    path.moveTo(0, 0);

    path.lineTo(size.width, 0);

    path.lineTo(size.width, centerY - radius);

    path.arcToPoint(
      Offset(size.width, centerY + radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height);

    path.lineTo(0, size.height);

    path.lineTo(0, centerY + radius);

    path.arcToPoint(
      Offset(0, centerY - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    path.lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
