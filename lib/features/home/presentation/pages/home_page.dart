// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../auth/presentation/pages/auth_page.dart';
import '../../../bookingpage/presentation/page/booking/page/booking_page.dart';
import '../../../bookingpage/presentation/page/invoice/page/invoice_page.dart';
import '../../../loading/application/loader_bloc.dart';
import '../../application/home_bloc.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_text.dart';
import '../../domain/models/stop_address_model.dart';
import '../widgets/get_location_permission.dart';
import '../widgets/home_body_widget.dart';
import '../widgets/home_page_shimmer.dart';
import '../widgets/send_receive_delivery.dart';
import 'confirm_location_page.dart';
import 'destination_page.dart';
import 'on_going_rides.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/homePage';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // && Platform.isAndroid
    if (state == AppLifecycleState.paused) {
      if (HomeBloc().nearByVechileSubscription != null) {
        HomeBloc().nearByVechileSubscription?.pause();
      }
    }
    if (state == AppLifecycleState.resumed) {
      if (HomeBloc().nearByVechileSubscription != null) {
        HomeBloc().nearByVechileSubscription?.resume();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addObserver(this);
    HomeBloc().nearByVechileCheckStream(context, this);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return builderWidget(size);
  }

  Widget builderWidget(Size size) {
    return BlocProvider(
      create: (context) => HomeBloc()
        ..add(GetDirectionEvent())
        ..add(GetUserDetailsEvent()),
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) async {
          if (state is VechileStreamMarkerState) {
            context.read<HomeBloc>().nearByVechileCheckStream(context, this);
          } else if(state is UpdateZoneLocationState){
            context.read<LoaderBloc>().add(UpdateUserLocationEvent());
          } else if (state is LogoutState) {
            if (context.read<HomeBloc>().nearByVechileSubscription != null) {
              context.read<HomeBloc>().nearByVechileSubscription?.cancel();
              context.read<HomeBloc>().nearByVechileSubscription = null;
            }
            Navigator.pushNamedAndRemoveUntil(
                context, AuthPage.routeName, (route) => false);
            await AppSharedPreference.setLoginStatus(false);
          } else if (state is GetLocationPermissionState) {
            showDialog(
              context: context,
              builder: (_) {
                return GetLocationPermissionWidget(cont: context);
              },
            );
          } else if (state is NavigateToOnGoingRidesPageState) {
            Navigator.pushNamed(context, OnGoingRidesPage.routeName,
                    arguments: OnGoingRidesPageArguments(
                        userData: context.read<HomeBloc>().userData!,
                        mapType: context.read<HomeBloc>().mapType))
                .then(
              (value) {
                if (!context.mounted) return;
                context.read<HomeBloc>().add(GetUserDetailsEvent());
              },
            );
          } else if (state is UserOnTripState &&
              state.tripData.acceptedAt == '') {
            if (context.read<HomeBloc>().nearByVechileSubscription != null) {
              context.read<HomeBloc>().nearByVechileSubscription?.cancel();
              context.read<HomeBloc>().nearByVechileSubscription = null;
            }
            Navigator.pushNamedAndRemoveUntil(
              context,
              BookingPage.routeName,
              (route) => false,
              arguments: BookingPageArguments(
                  picklat: state.tripData.pickLat,
                  picklng: state.tripData.pickLng,
                  droplat: state.tripData.dropLat,
                  droplng: state.tripData.dropLng,
                  pickupAddressList: context.read<HomeBloc>().pickupAddressList,
                  stopAddressList: context.read<HomeBloc>().stopAddressList,
                  userData: context.read<HomeBloc>().userData!,
                  transportType: state.tripData.transportType,
                  polyString: state.tripData.polyLine,
                  distance: (double.parse(state.tripData.totalDistance) * 1000)
                      .toString(),
                  duration: state.tripData.totalTime.toString(),
                  isRentalRide: state.tripData.isRental,
                  isWithoutDestinationRide: ((state.tripData.dropLat.isEmpty &&
                              state.tripData.dropLng.isEmpty) &&
                          !state.tripData.isRental)
                      ? true
                      : false,
                  isOutstationRide: state.tripData.isOutStation == "1",
                  mapType: context.read<HomeBloc>().mapType),
            );
          } else if (state is DeliverySelectState) {
            showModalBottomSheet(
              context: context,
              isDismissible: true,
              enableDrag: false,
              isScrollControlled: true,
              builder: (_) {
                return SendOrReceiveDelivery(cont: context);
              },
            );
          } else if (state is DestinationSelectState) {
            Navigator.pushNamed(
              context,
              DestinationPage.routeName,
              arguments: DestinationPageArguments(
                  title: context.read<HomeBloc>().selectedServiceType == 0
                      ? 'Taxi'
                      : 'Delivery',
                  pickupAddress: context.read<HomeBloc>().currentLocation,
                  pickupLatLng: context.read<HomeBloc>().currentLatLng,
                  dropAddress: state.dropAddress,
                  dropLatLng: state.dropLatLng,
                  userData: context.read<HomeBloc>().userData!,
                  pickUpChange: state.isPickupChange,
                  transportType:
                      context.read<HomeBloc>().selectedServiceType == 0
                          ? 'taxi'
                          : 'delivery',
                  isOutstationRide: false,
                  mapType: context.read<HomeBloc>().mapType),
            );
          } else if (state is OutStationSelectState) {
            Navigator.pushNamed(
              context,
              DestinationPage.routeName,
              arguments: DestinationPageArguments(
                  title: context.read<HomeBloc>().selectedServiceType == 0
                      ? 'Taxi'
                      : 'Delivery',
                  pickupAddress: context.read<HomeBloc>().currentLocation,
                  pickupLatLng: context.read<HomeBloc>().currentLatLng,
                  userData: context.read<HomeBloc>().userData!,
                  pickUpChange: false,
                  transportType:
                      context.read<HomeBloc>().selectedServiceType == 0
                          ? 'taxi'
                          : 'delivery',
                  isOutstationRide: true,
                  mapType: context.read<HomeBloc>().mapType),
            );
          } else if (state is ConfirmRideAddressState ||
               state is RecentSearchPlaceSelectState) {
            if (context.read<HomeBloc>().nearByVechileSubscription != null) {
              context.read<HomeBloc>().nearByVechileSubscription?.cancel();
              context.read<HomeBloc>().nearByVechileSubscription = null;
            }
            if (context.read<HomeBloc>().pickupAddressList.isNotEmpty &&
                context.read<HomeBloc>().stopAddressList.length == 1) {
              Navigator.pushNamed(
                context,
                BookingPage.routeName,
                arguments: BookingPageArguments(
                    picklat: context
                        .read<HomeBloc>()
                        .pickupAddressList
                        .first
                        .lat
                        .toString(),
                    picklng: context
                        .read<HomeBloc>()
                        .pickupAddressList
                        .first
                        .lng
                        .toString(),
                    droplat: context
                        .read<HomeBloc>()
                        .stopAddressList
                        .last
                        .lat
                        .toString(),
                    droplng: context
                        .read<HomeBloc>()
                        .stopAddressList
                        .last
                        .lng
                        .toString(),
                    userData: context.read<HomeBloc>().userData!,
                    transportType:
                        context.read<HomeBloc>().selectedServiceType == 0
                            ? 'taxi'
                            : 'delivery',
                    pickupAddressList:
                        context.read<HomeBloc>().pickupAddressList,
                    stopAddressList: context.read<HomeBloc>().stopAddressList,
                    polyString: '',
                    distance: '',
                    duration: '',
                    isOutstationRide: false,
                    mapType: context.read<HomeBloc>().mapType),
              ).then((value) {
                if(!context.mounted) return;
                context.read<HomeBloc>().stopAddressList.clear();
              },);
            } else {
              context.read<HomeBloc>().stopAddressList.clear();
            }
          } else if (state is RentalSelectState) {
            Navigator.pushNamed(context, ConfirmLocationPage.routeName,
                    arguments: ConfirmLocationPageArguments(
                        userData: context.read<HomeBloc>().userData!,
                        isPickupEdit: true,
                        isOutstationRide: false,
                        isEditAddress: false,
                        mapType: context.read<HomeBloc>().mapType,
                        transportType: ''))
                .then(
              (value) {
                if (!context.mounted) return;
                if (value != null) {
                  if (context.read<HomeBloc>().nearByVechileSubscription !=
                      null) {
                    context
                        .read<HomeBloc>()
                        .nearByVechileSubscription
                        ?.cancel();
                    context.read<HomeBloc>().nearByVechileSubscription = null;
                  }
                  context.read<HomeBloc>().pickupAddressList.clear();
                  final add = value as AddressModel;
                  context.read<HomeBloc>().pickupAddressList.add(add);
                  Navigator.pushNamed(
                    context,
                    BookingPage.routeName,
                    arguments: BookingPageArguments(
                        picklat: context
                            .read<HomeBloc>()
                            .pickupAddressList[0]
                            .lat
                            .toString(),
                        picklng: context
                            .read<HomeBloc>()
                            .pickupAddressList[0]
                            .lng
                            .toString(),
                        droplat: '',
                        droplng: '',
                        userData: context.read<HomeBloc>().userData!,
                        transportType:context.read<HomeBloc>().userData!.showTaxiRentalRide ? 'taxi' :context.read<HomeBloc>().userData!.showDeliveryRentalRide ? 'delivery' : '' ,
                        pickupAddressList:
                            context.read<HomeBloc>().pickupAddressList,
                        stopAddressList: [],
                        polyString: '',
                        distance: '',
                        duration: '',
                        mapType: context.read<HomeBloc>().mapType,
                        isOutstationRide: false,
                        isRentalRide: true),
                  );
                }
              },
            );
          } else if (state is RideWithoutDestinationState) {
            Navigator.pushNamed(context, ConfirmLocationPage.routeName,
                    arguments: ConfirmLocationPageArguments(
                        userData: context.read<HomeBloc>().userData!,
                        isPickupEdit: true,
                        isEditAddress: false,
                        isOutstationRide: false,
                        mapType: context.read<HomeBloc>().mapType,
                        transportType: ''))
                .then(
              (value) {
                if (!context.mounted) return;
                if (value != null) {
                  if (context.read<HomeBloc>().nearByVechileSubscription !=
                      null) {
                    context
                        .read<HomeBloc>()
                        .nearByVechileSubscription
                        ?.cancel();
                    context.read<HomeBloc>().nearByVechileSubscription = null;
                  }
                  context.read<HomeBloc>().pickupAddressList.clear();
                  final add = value as AddressModel;
                  context.read<HomeBloc>().pickupAddressList.add(add);
                  Navigator.pushNamed(
                    context,
                    BookingPage.routeName,
                    arguments: BookingPageArguments(
                        picklat: context
                            .read<HomeBloc>()
                            .pickupAddressList[0]
                            .lat
                            .toString(),
                        picklng: context
                            .read<HomeBloc>()
                            .pickupAddressList[0]
                            .lng
                            .toString(),
                        droplat: '',
                        droplng: '',
                        userData: context.read<HomeBloc>().userData!,
                        transportType: 'taxi',
                        pickupAddressList:
                            context.read<HomeBloc>().pickupAddressList,
                        stopAddressList: [],
                        polyString: '',
                        distance: '',
                        duration: '',
                        mapType: context.read<HomeBloc>().mapType,
                        isRentalRide: false,
                        isOutstationRide: false,
                        isWithoutDestinationRide: true),
                  );
                }
              },
            );
          } else if (state is UserOnTripState) {
            if (context.read<HomeBloc>().nearByVechileSubscription != null) {
              context.read<HomeBloc>().nearByVechileSubscription?.cancel();
              context.read<HomeBloc>().nearByVechileSubscription = null;
            }
            Navigator.pushNamedAndRemoveUntil(
                context, BookingPage.routeName, (route) => false,
                arguments: BookingPageArguments(
                    picklat: state.tripData.pickLat,
                    picklng: state.tripData.pickLng,
                    droplat: state.tripData.dropLat,
                    droplng: state.tripData.dropLng,
                    pickupAddressList:
                        context.read<HomeBloc>().pickupAddressList,
                    stopAddressList: context.read<HomeBloc>().stopAddressList,
                    userData: context.read<HomeBloc>().userData!,
                    transportType: state.tripData.transportType,
                    polyString: state.tripData.polyLine,
                    distance: (double.parse(state.tripData.totalDistance) * 1000)
                      .toString(),
                    duration: state.tripData.totalTime.toString(),
                    requestId: state.tripData.id,
                    mapType: context.read<HomeBloc>().mapType,
                    isOutstationRide: state.tripData.isOutStation == "1"));
          } else if (state is UserTripSummaryState) {
            if (context.read<HomeBloc>().nearByVechileSubscription != null) {
              context.read<HomeBloc>().nearByVechileSubscription?.cancel();
              context.read<HomeBloc>().nearByVechileSubscription = null;
            }
            Navigator.pushNamedAndRemoveUntil(
              context,
              InvoicePage.routeName,
              (route) => false,
              arguments: InvoicePageArguments(
                  requestData: state.requestData,
                  requestBillData: state.requestBillData,
                  driverData: state.driverData,
                  rideRepository: state.rideRepository),
            );
          } else if (state is ServiceNotAvailableState) {
            context.read<HomeBloc>().stopAddressList.clear();
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                          alignment:
                              context.read<HomeBloc>().textDirection == 'rtl'
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                          child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.cancel_outlined,
                                  color: Theme.of(context).primaryColor))),
                      Center(
                        child: MyText(
                            text: state.message,
                            maxLines: 4),
                      ),
                    ],
                  ),
                  actions: [
                    Center(
                      child: CustomButton(
                        buttonName: AppLocalizations.of(context)!.okText,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                );
              },
            );
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (context.read<HomeBloc>().mapType == 'google_map') {
              if (Theme.of(context).brightness == Brightness.dark) {
                if (context.read<HomeBloc>().googleMapController != null) {
                  if (context.mounted) {
                    context
                        .read<HomeBloc>()
                        .googleMapController!
                        .setMapStyle(context.read<HomeBloc>().darkMapString);
                  }
                }
              } else {
                if (context.read<HomeBloc>().googleMapController != null) {
                  if (context.mounted) {
                    context
                        .read<HomeBloc>()
                        .googleMapController!
                        .setMapStyle(context.read<HomeBloc>().lightMapString);
                  }
                }
              }
            }

            return PopScope(
              canPop: true,
              child: Directionality(
                textDirection: context.read<HomeBloc>().textDirection == 'rtl'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Scaffold(
                  body: (context.read<HomeBloc>().userData != null &&
                          ((context.read<HomeBloc>().userData!.onTripRequest ==
                                      null ||
                                  context
                                          .read<HomeBloc>()
                                          .userData!
                                          .onTripRequest ==
                                      "") ||
                              (context.read<HomeBloc>().userData!.metaRequest ==
                                      null ||
                                  context
                                          .read<HomeBloc>()
                                          .userData!
                                          .metaRequest ==
                                      "")))
                      ? HomeBodyWidget(cont: context)
                      : HomePageShimmer(size: size),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
