// ignore_for_file: deprecated_member_use

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:restart_tagxi/core/utils/custom_button.dart";
import "package:restart_tagxi/features/account/presentation/pages/history/widget/trip_fare_breakup_widget.dart";
import "package:restart_tagxi/features/account/presentation/pages/support_ticket/widgets/create_ticket_sheet.dart";
import "../../../../../../common/common.dart";
import "../../../../../../core/utils/custom_dialoges.dart";
import "../../../../../../core/utils/custom_loader.dart";
import "../../../../../../core/utils/custom_text.dart";
import "../../../../../../l10n/app_localizations.dart";
import "../../../../application/acc_bloc.dart";

import "../widget/cancel_ride_widget.dart";
import "../widget/delivery_proof_view.dart";
import "../widget/trip_driver_details_widget.dart";
import "../widget/trip_map_widget.dart";
import "../widget/trip_vehicle_info_widget.dart";

class HistoryTripSummaryPage extends StatelessWidget {
  static const String routeName = '/historytripsummary';
  final TripHistoryPageArguments arg;

  const HistoryTripSummaryPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(TripSummaryHistoryDataEvent(tripHistoryData: arg.historyData))
        ..add(GetServiceLocationEvent())
        ..add(AddHistoryMarkerEvent(
            stops: (arg.historyData.requestStops != null)
                ? arg.historyData.requestStops!.data
                : [],
            pickLat: arg.historyData.pickLat,
            pickLng: arg.historyData.pickLng,
            dropLat: arg.historyData.dropLat,
            dropLng: arg.historyData.dropLng,
            polyline: arg.historyData.polyLine))
        ..add(ComplaintEvent(complaintType: 'request')),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AccInitialState) {
            CustomLoader.loader(context);
          } else if (state is RequestCancelState) {
            Navigator.pop(context);
            Navigator.pop(context);
          } else if (state is GetTicketListLoadedState) {
            CustomLoader.dismiss(context);
          } else if (state is CreateSupportTicketState) {
            if (context.read<AccBloc>().isTicketSheetOpened) return;
            context.read<AccBloc>().isTicketSheetOpened = true;
            showModalBottomSheet(
              isScrollControlled: true,
              enableDrag: true,
              isDismissible: true,
              context: context,
              builder: (cont) {
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: CreateTicketSheet(
                    requestId: state.requestId,
                    cont: context,
                    ticketNamesList: state.ticketNamesList,
                    isFromReuest: state.isFromRequest,
                    index: state.historyIndex,
                    historyPagenumber: state.historyPageNumber,
                  ),
                );
              },
            ).whenComplete(() {
              if (context.mounted) {
                context.read<AccBloc>().isTicketSheetOpened = false;
              }
            });
          } else if (state is InvoiceDownloadSuccessState) {
            showDialog(
              context: context,
              builder: (_) {
                return CustomSingleButtonDialoge(
                  title: AppLocalizations.of(context)!.success,
                  content: AppLocalizations.of(context)!.invoiceSendContent,
                  btnName: AppLocalizations.of(context)!.okText,
                  onTap: () {
                    Navigator.pop(context);
                  },
                );
              },
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final tripHistoryData = context.read<AccBloc>().historyData;
          if (Theme.of(context).brightness == Brightness.dark) {
            if (context.read<AccBloc>().googleMapController != null) {
              context
                  .read<AccBloc>()
                  .googleMapController!
                  .setMapStyle(context.read<AccBloc>().darkMapString);
            }
          } else {
            if (context.read<AccBloc>().googleMapController != null) {
              context
                  .read<AccBloc>()
                  .googleMapController!
                  .setMapStyle(context.read<AccBloc>().lightMapString);
            }
          }
          return Directionality(
            textDirection: context.read<AccBloc>().textDirection == 'rtl'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Scaffold(
              backgroundColor: const Color(0xffDEDCDC),
              body: (tripHistoryData != null)
                  ? SafeArea(
                      child: Stack(
                        children: [
                          SizedBox(
                            height: size.height,
                            width: size.width,
                            child: CustomScrollView(
                              slivers: [
                                SliverAppBar(
                                    stretch: false,
                                    expandedHeight: size.width * 0.7,
                                    pinned: true,
                                    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                                    leading: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        margin: const EdgeInsets.all(
                                            8), // optional: spacing around the circle
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).appBarTheme.backgroundColor,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                    flexibleSpace: LayoutBuilder(builder:
                                        (BuildContext context,
                                            BoxConstraints constraints) {
                                      var top = constraints.biggest.height;
                                      return FlexibleSpaceBar(
                                          title: AnimatedOpacity(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              opacity: top > 71 && top < 91
                                                  ? 1.0
                                                  : 0.0,
                                              child: MyText(
                                                text: top > 71 && top < 91
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .rideDetails
                                                    : "",
                                                textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    color: AppColors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          background: TripMapWidget(
                                            cont: context,
                                            arg: arg,
                                          ));
                                    })),
                                SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                        childCount: 1, (context, index) {
                                  final double spacing = size.width * 0.03;

                                  return Container(
                                    padding: EdgeInsets.all(size.width * 0.03),
                                    width: size.width,
                                    color: const Color(0xffDEDCDC),
                                    child: Column(
                                      children: [
                                        TripFarebreakupWidget(
                                            cont: context, arg: arg),
                                        if (tripHistoryData.isBidRide == 1 &&
                                            tripHistoryData.requestBill !=
                                                null &&
                                            tripHistoryData.requestBill.data
                                                    .driverTips !=
                                                "0")
                                          Container(
                                              padding: EdgeInsets.all(
                                                  size.width * 0.05),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: size.width * 0.01,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .tips,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge!
                                                              .copyWith(),
                                                    ),
                                                    MyText(
                                                      text:
                                                          '${tripHistoryData.requestBill.data.requestedCurrencySymbol} ${tripHistoryData.requestBill.data.driverTips}',
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
                                                    )
                                                  ],
                                                ),
                                              )),
                                        SizedBox(height: spacing),
                                        TripDriverDetailsWidget(
                                            cont: context, arg: arg),
                                        SizedBox(height: spacing),

                                        TripVehicleInfoWidget(
                                            cont: context, arg: arg),
                                        // delivery ride proof
                                        Column(
                                          children: [
                                            if (tripHistoryData.transportType ==
                                                    'delivery' &&
                                                tripHistoryData.requestProofs
                                                    .data.isNotEmpty) ...[
                                              SizedBox(
                                                  height: size.width * 0.02),
                                              Container(
                                                  padding: EdgeInsets.all(
                                                      size.width * 0.05),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .scaffoldBackgroundColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          if (arg
                                                              .historyData
                                                              .requestProofs
                                                              .data
                                                              .isNotEmpty) {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => DeliveryProofViewPage(
                                                                    images: arg
                                                                        .historyData
                                                                        .requestProofs
                                                                        .data),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                                Icons.image,
                                                                color: Colors
                                                                    .blue),
                                                            MyText(
                                                              text: AppLocalizations
                                                                      .of(context)!
                                                                  .loadShipmentProof,
                                                              textStyle: const TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  decorationColor:
                                                                      Colors
                                                                          .blue),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              // SizedBox(height: size.width * 0.02),
                                            ],
                                          ],
                                        ),
                                        SizedBox(height: spacing),

                                        Container(
                                            padding: EdgeInsets.all(
                                                size.width * 0.05),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    MyText(
                                                      text: tripHistoryData
                                                          .requestNumber,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )),
                                      SizedBox(height: size.width * 0.02),
                                      Container(
                                          padding:
                                              EdgeInsets.all(size.width * 0.05),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              MyText(
                                                    text: AppLocalizations.of(context)!.ratings,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor,
                                                            fontSize: 14),
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: List.generate(5, (index) {
                                                  return (index < tripHistoryData.rideDriverRating)
                                                  ? const Icon(Icons.star,color:AppColors.goldenColor)
                                                  : const Icon(Icons.star_border_outlined);
                                                },),
                                              ),
                                            ],
                                          )),
                                        SizedBox(height: spacing * 20),
                                      ],
                                    ),
                                  );
                                })),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: (tripHistoryData.isCompleted == 1 &&
                                    tripHistoryData.supportTicketExist ==
                                        true &&
                                    arg.isSupportTicketEnabled == '1')
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10,
                                        top: 10,
                                        right: 10,
                                        bottom: 10),
                                    child: Container(
                                      width: size.width * 0.5,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .disabledColor),
                                        color: Theme.of(context).disabledColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              MyText(
                                                text:
                                                    "${AppLocalizations.of(context)!.ticketCreated} :",
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .scaffoldBackgroundColor),
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.02),
                                              MyText(
                                                text: tripHistoryData
                                                    .supportTicketId,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .scaffoldBackgroundColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          MyText(
                                            text: tripHistoryData
                                                        .supportTicketStatus ==
                                                    1
                                                ? AppLocalizations.of(context)!
                                                    .pending
                                                : tripHistoryData
                                                            .supportTicketStatus ==
                                                        2
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .acknowledged
                                                    : AppLocalizations.of(
                                                            context)!
                                                        .closed,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                    color: tripHistoryData
                                                                .supportTicketStatus ==
                                                            1
                                                        ? AppColors.blue
                                                        : tripHistoryData
                                                                    .supportTicketStatus ==
                                                                2
                                                            ? AppColors.orange
                                                            : AppColors.red,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : (tripHistoryData.isCompleted == 1 &&
                                        arg.isSupportTicketEnabled == '1')
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          top: 10,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                                offset: Offset(0, -2),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 16),
                                            child: InkWell(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .report_gmailerrorred,
                                                        size: 20,
                                                        color: AppColors.red),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.01),
                                                    MyText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .reportIssues,
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                                color: AppColors
                                                                    .red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13)),
                                                  ],
                                                ),
                                                onTap: () {
                                                  context.read<AccBloc>().add(
                                                      CreateSupportTicketEvent(
                                                          requestId:
                                                              tripHistoryData
                                                                  .requestNumber,
                                                          isFromRequest: true,
                                                          index:
                                                              arg.historyIndex,
                                                          pageNumber:
                                                              arg.pageNumber));
                                                }),
                                          ),
                                        ),
                                      )
                                    : (tripHistoryData.isLater &&
                                            tripHistoryData.isCancelled == 0)
                                        ? CustomButton(
                                            buttonName:
                                                AppLocalizations.of(context)!
                                                    .cancel,
                                            buttonColor:
                                                Theme.of(context).primaryColor,
                                            onTap: () {
                                              showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: false,
                                                  enableDrag: false,
                                                  isDismissible: true,
                                                  builder: (_) {
                                                    return CancelRideWidget(
                                                        cont: context,
                                                        requestId:
                                                            tripHistoryData.id);
                                                  });
                                            })
                                        : Container(),
                          )
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),
          );
        }),
      ),
    );
  }
}
