import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart' as intel;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_tagxi/common/tobitmap.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/payment_received_stream.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;
import '../../../common/app_audio.dart';
import '../../../common/common.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snack_bar.dart';
import '../../../core/utils/functions.dart';
import '../../../core/utils/geohash.dart';
import '../../../di/locator.dart';
import '../../home/application/usecase/home_usecases.dart';
import '../../home/domain/models/contact_model.dart';
import '../../home/domain/models/user_details_model.dart';
import '../../home/domain/models/stop_address_model.dart';
import '../domain/models/cancel_reason_model.dart';
import '../domain/models/chat_history_model.dart';
import '../domain/models/eta_details_model.dart';
import '../domain/models/goods_type_model.dart';
import '../domain/models/nearby_eta_model.dart';
import '../domain/models/point_latlng.dart';
import '../domain/models/rental_packages_model.dart';
import '../presentation/page/booking/widget/marker_widget.dart';
import 'usecases/booking_usecase.dart';
part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  TextEditingController applyCouponController = TextEditingController();
  TextEditingController feedBackController = TextEditingController();
  TextEditingController goodsQtyController = TextEditingController();
  TextEditingController receiverNameController = TextEditingController();
  TextEditingController receiverMobileController = TextEditingController();
  TextEditingController farePriceController = TextEditingController();
  TextEditingController chatController = TextEditingController();
  TextEditingController otherReasonController = TextEditingController();
  TextEditingController addTIPController = TextEditingController();
  TextEditingController instructionsController = TextEditingController();
  ScrollController chatScrollController = ScrollController();
  ScrollController etaScrollController = ScrollController();
  GoogleMapController? googleMapController;
  fm.MapController? fmController = fm.MapController();
  List<fmlt.LatLng> fmpoly = [];
  late DraggableScrollableController _draggableScrollableController;

  dynamic vsync;
  DraggableScrollableController get draggableScrollableController =>
      _draggableScrollableController;
  bool isLoading = false;
  bool detailView = false;
  bool isMyself = false;
  bool isOthers = false;
  bool isTripStart = false;
  bool isNormalRideSearching = false;
  bool isBiddingRideSearching = false;
  bool isDriverReceivedPayment = false;
  bool isBiddingIncreaseLimitReach = false;
  bool isBiddingDecreaseLimitReach = false;
  bool luggagePreference = false;
  bool petPreference = false;
  bool isMultiTypeVechiles = false;
  bool isBottomNavVisible = true;
  bool enableEtaScrolling = false;
  bool showPaymentChange = false;
  bool payAtDrop = false;
  bool isBottomDisabled = false;
  bool showBiddingVehicles = false;
  bool isEtaFilter = false;
  bool filterSuccess = false;
  bool isPop = false;
  bool cancelReasonClicked = false;
  bool isRentalRide = false;
  bool isRoundTrip = false;
  bool isSavedCardChoose = false;
  int timerDuration = 0;
  int waitingTime = 0;
  int selectedRatingsIndex = 0;
  int selectedVehicleIndex = 0;
  int selectedPackageIndex = 0;
  int selectedRideTypeIndex = 0;
  int selectedGoodsTypeId = 0;
  int choosenVehiclePackageIndex = 0;
  int choosenAddressIndex = 0;
  double minChildSize = 0.37;
  double initChildSize = 0.40;
  double currentSize = 0.37;
  double currentSizeTwo = 0.41;
  double currentSizeThree = 0.45;
  double minChildSizeTwo = 0.41;
  double minChildSizeThree = 0.45;
  double maxChildSize = 0.9;
  double maxChildHeight = 0.65;
  double scrollHeight = 0.0;
  double onRideBottomPosition = -250;
  double onRideBottomCurrentHeight = 0;
  double addTip = 0;
  String? selectedPackageId;
  String showDateTime = '';
  String showReturnDateTime = '';
  String textDirection = 'ltr';
  String languageCode = '';
  String scheduleDateTime = '';
  String scheduleDateTimeForReturn = '';
  String selectedPaymentType = 'cash';
  String selectedCardToken = '';
  String goodsTypeQtyOrLoose = 'Loose';
  String selectedCancelReason = '';
  String selectedCancelReasonId = '';
  String transportType = '';
  String distance = '';
  String polyLine = '';
  String duration = '';
  String notifyText = '';
  String promoErrorText = '';
  String dropdownValue = '';
  String lightMapString = '';
  String darkMapString = '';
  String fmDistance = '';
  String additionalChargesReason = '';
  String additionalChargesAmount = '';
  double fmDuration = 0;
  List<EtaDetails> etaDetailsList = [];
  List<RentalEtaDetails> rentalEtaDetailsList = [];
  List<RentalPackagesData> rentalPackagesList = [];
  List<CategoryData> categoryList = [];
  List<EtaDetails> sortedEtaDetailsList = [];
  List<String> paymentList = [];
  List<dynamic> savedCardList = [];
  List<GoodsTypeData> goodsTypeList = [];
  List biddingDriverList = [];
  List<CancelReasonsData> cancelReasonsList = [];
  List<AddressModel> pickUpAddressList = [];
  List<AddressModel> dropAddressList = [];
  List<ChatHistoryData> chatHistoryList = [];
  List<NearbyEtaModel> nearByEtaVechileList = [];
  List<dynamic> nearByDriversData = [];
  List<TextEditingController> addressTextControllerList = [];
  List<ContactsModel> contactsList = [];
  ContactsModel selectedContact = ContactsModel(name: '', number: '');

  Timer? normalRideTimer;
  Timer? biddingRideSearchTimer;
  Timer? biddingRideTimer;
  ScrollController scrollController = ScrollController();

  StreamSubscription<DatabaseEvent>? requestStreamStart;
  StreamSubscription<DatabaseEvent>? rideStreamStart;
  StreamSubscription<DatabaseEvent>? rideStreamUpdate;
  StreamSubscription<DatabaseEvent>? biddingRequestStream;
  StreamSubscription<DatabaseEvent>? driverDataStream;
  StreamSubscription<DatabaseEvent>? etaDurationStream;
  late RideRepository rideRepository;

  UserDetail? userData;
  OnTripRequestData? requestData;
  DriverDetailData? driverData;
  RequestBillData? requestBillData;
  AudioPlayer audioPlayers = AudioPlayer();

  BitmapDescriptor? pickupMarker;
  List markerList = [];
  LatLng? driverPosition;
  Set<Polyline> polylines = {};
  List<LatLng> polylineLatLng = [];
  LatLngBounds? bound;
//Animate
  AnimationController? animationController;
  Animation<double>? animation;
  Animation<double>? _animation1;
  AnimationController? animationController1;

  StreamSubscription<DatabaseEvent>? nearByVechileSubscription;
  Map myBearings = {};
  String mapType = 'google_map';

  double selectedEtaAmount = 0.0;
  TextEditingController filterCapacityController =
      TextEditingController(text: '1');
  int filterCapasity = 1;
  List filterCategory = [];
  List filterPermit = [];
  List filterBodyType = [];
  int applyFilterCapasity = 1;
  List applyFilterCategory = [];
  List applyFilterPermit = [];
  List applyFilterBodyType = [];
  String changedPaymentValue = '';

  MapType _selectedMapType = MapType.normal;
  MapType get selectedMapType => _selectedMapType;

  BookingBloc() : super(BookingInitialState()) {
    _draggableScrollableController = DraggableScrollableController();
    on<UpdateEvent>((event, emit) => emit(BookingUpdateState()));
    on<GetDirectionEvent>(getDirection);
    on<BookingInitEvent>(bookingInitEvent);
    on<BookingNavigatorPopEvent>(navigatorPop);
    on<ShowEtaInfoEvent>(showEtaDetails);
    on<BookingEtaRequestEvent>(bookingEtaRequest);
    on<BookingRentalEtaRequestEvent>(bookingRentalEtaRequest);
    on<ShowRentalPackageListEvent>(rentalPackageSelect);
    on<RentalPackageConfirmEvent>(rentalPackageConfirm);
    on<BookingEtaSelectEvent>(selectedEtaVehicleIndex);
    on<BookingRentalPackageSelectEvent>(selectedRentalPackageIndex);
    on<BookingGetUserDetailsEvent>(getUserDetails);
    on<TimerEvent>(timerEvent);
    on<NoDriversEvent>(noDriverEvent);
    on<BookingCreateRequestEvent>(createRequestEvent);
    on<BookingCancelRequestEvent>(cancelRequest);
    on<BookingStreamRequestEvent>(bookingStreamRequest);
    on<TripRideCancelEvent>(onTripRideCancel);
    on<BookingRatingsSelectEvent>(ratingsSelectEvent);
    on<BookingUserRatingsEvent>(userRatings);
    on<GetGoodsTypeEvent>(getGoodsType);
    on<EnableBiddingEvent>(enableBiddingEvent);
    on<BiddingIncreaseOrDecreaseEvent>(biddingFareIncreaseDecrease);
    on<BiddingCreateRequestEvent>(biddingCreateRequest);
    on<BiddingFareUpdateEvent>(biddingFareUpdate);
    on<BiddingAcceptOrDeclineEvent>(biddingAcceptOrDecline);
    on<CancelReasonsEvent>(getCancelReasons);
    on<PolylineEvent>(getPolyline);
    on<GetChatHistoryEvent>(getChatHistory);
    on<ChatWithDriverEvent>(chatWithDriver);
    on<SendChatMessageEvent>(sendChatMessage);
    on<SeenChatMessageEvent>(seenChatMessage);
    on<SOSEvent>(sosEvent);
    on<NotifyAdminEvent>(notifyAdmin);
    on<SelectBiddingOrDemandEvent>(typeEtaChange);
    on<UpdateScrollPhysicsEvent>(enableEtaScrollingList);
    on<UpdateMinChildSizeEvent>((event, emit) {
      scrollToMinChildSize(event.minChildSize);
    });
    on<UpdateScrollSizeEvent>((event, emit) {
      scrollToBottomFunction(event.minChildSize);
    });
    on<DetailViewUpdateEvent>(enableDetailsViewFunction);
    on<WalletPageReUpdateEvents>(walletPageReUpdate);
    on<ShowAddTipEvent>(showAddTip);
    on<AddTipsEvent>(addTipEvent);
    on<InvoiceInitEvent>(invoiceInit);
    on<ChangePaymentMethodEvent>(changePaymentMethodListener);
    on<BookingLocateMeEvent>(locateMe);
    on<EditLocationEvent>(editLocation);
    on<EditLocationPageInitEvent>(editLocationInit);
    on<ReorderEvent>(reOrderAddress);
    on<AddStopEvent>(addNewAddressStop);
    on<SelectFromMapEvent>(selectFromMap);
    on<BookingAddOrEditStopAddressEvent>(addOrEditStopAddress);
    on<SelectContactDetailsEvent>(selectContactDetails);
    on<ReceiverContactEvent>(receiverContactDetails);
    on<ChangeDestinationEvent>(changeDestination);
    on<AddMarkersEvent>(addMarkers);
    on<UpdateMarkersEvent>(updateMarkers);
    on<OnRidePaymentWebViewUrlEvent>(onRidePaymentWebViewUrl);
    on<UpdateMapTypeEvent>(updateMapType);
  }

  void etaScrollingToMin(double targetMinChildSize) {
    try {
      etaScrollController.animateTo(
        targetMinChildSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      debugPrint("Error scrolling to minChildSize: $e");
    }
  }

  String formatDuration(int seconds) {
    int minutes = seconds ~/ 60; // Integer division to get minutes
    int remainingSeconds = seconds % 60; // Remainder to get the seconds
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> getDirection(
      GetDirectionEvent event, Emitter<BookingState> emit) async {
    //Animate
    animationController = AnimationController(
      vsync: event.vsync,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: false);

    animation = CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeInOut,
    );
    animationController?.repeat(reverse: false);

    emit(BookingLoadingStartState());
    languageCode = await AppSharedPreference.getSelectedLanguageCode();
    textDirection = await AppSharedPreference.getLanguageDirection();
    lightMapString = await rootBundle.loadString('assets/light-theme.json');
    darkMapString = await rootBundle.loadString('assets/dark-theme.json');
    emit(BookingLoadingStopState());
  }

  //GoogleMap Animation
  List<LatLng> getGoogleMapAnimatedPolyline(
      List<LatLng> points, double animationValue) {
    if (points.isEmpty) return [];

    final int totalPoints = points.length;
    final int animatedPointsCount = (animationValue * totalPoints).toInt();

    // Return a sublist of points that represents the current animation progress
    return points.sublist(0, animatedPointsCount.clamp(0, totalPoints));
  }

  //FlutterMap Animation
  List<fmlt.LatLng> getFlutterMapAnimatedPolyline(
      List<fmlt.LatLng> points, double animationValue) {
    if (points.isEmpty) return [];

    // Calculate how many points to show based on the animation value
    final int totalPoints = points.length;
    final int animatedPointsCount = (animationValue * totalPoints).toInt();

    // Return a subset of the polyline points (from A to B progressively)
    return points.sublist(0, animatedPointsCount.clamp(0, totalPoints));
  }

  Future<void> navigatorPop(
      BookingNavigatorPopEvent event, Emitter<BookingState> emit) async {
    vsync = null;
    animationController?.dispose();
    animationController = null;
    animationController1?.dispose();
    animationController1 = null;
    googleMapController = null;
    requestStreamStart?.cancel();
    rideStreamUpdate?.cancel();
    rideStreamStart?.cancel();
    biddingRequestStream?.cancel();
    driverDataStream?.cancel();
    etaDurationStream?.cancel();
    nearByVechileSubscription?.cancel();
    timerDuration = 0;
    normalRideTimer?.cancel();
    biddingRideSearchTimer?.cancel();
    if (!isPop) {
      isPop = true;
      emit(BookingNavigatorPopState());
    }
  }

  Future<void> bookingInitEvent(
      BookingInitEvent event, Emitter<BookingState> emit) async {
    vsync = event.vsync;
    mapType = event.arg.mapType;
    pickUpAddressList = event.arg.pickupAddressList;
    dropAddressList =
        ((event.arg.isRentalRide != null && event.arg.isRentalRide!) ||
                (event.arg.isWithoutDestinationRide != null &&
                    event.arg.isWithoutDestinationRide!))
            ? []
            : event.arg.stopAddressList;
    userData = event.arg.userData;
    transportType = event.arg.transportType;
    polyLine = event.arg.polyString;
    distance = event.arg.distance;
    duration = event.arg.duration;
    requestData = event.arg.userData.onTripRequest != ""
        ? event.arg.userData.onTripRequest.data
        : event.arg.userData.metaRequest != ""
            ? event.arg.userData.metaRequest.data
            : null;

    if (dropAddressList.length >= 2) {
      minChildSize = 0.52;
      initChildSize = 0.55;
      for (var i = 0; i < dropAddressList.length; i++) {
        dropAddressList[i].orderId = (i + 1).toString();
      }
    }
    if (event.arg.transportType == 'delivery' &&
        event.arg.title == 'Send Parcel') {
      showPaymentChange = true;
    }
    if (event.arg.transportType == 'delivery' &&
        event.arg.title == 'Receive Parcel' &&
        event.arg.stopAddressList.length > 1) {
      payAtDrop = true;
      showPaymentChange = true;
    }
    if (event.arg.isWithoutDestinationRide != null &&
        event.arg.isWithoutDestinationRide!) {
      showBiddingVehicles = false;
    }
    if (event.arg.isOutstationRide) {
      showBiddingVehicles = true;
      showDateTime = intel.DateFormat('dd/MM/yyyy (hh:mm a)').format(
          DateTime.now().add(Duration(
              minutes: int.parse(
                  event.arg.userData.userCanMakeARideAfterXMiniutes))));
      scheduleDateTime = DateTime.now()
          .add(Duration(
              minutes:
                  int.parse(event.arg.userData.userCanMakeARideAfterXMiniutes)))
          .toString();
      transportType = (event.arg.userData.showTaxiOutstationRideFeature == '1') 
      ? 'taxi'
      : (event.arg.userData.showDeliveryOutstationRideFeature == '1')
         ? 'delivery'
         : 'taxi';
    }
    if (event.arg.isRentalRide != null &&
        event.arg.isRentalRide! &&
        requestData == null) {
      isRentalRide = true;
      transportType = ((event.arg.userData.enableModulesForApplications ==
                      'both' ||
                  event.arg.userData.enableModulesForApplications == 'taxi') &&
              event.arg.userData.showTaxiRentalRide)
          ? 'taxi'
          : (event.arg.userData.showDeliveryRentalRide)
              ? 'delivery'
              : '';
      if (transportType.isNotEmpty) {
        add(BookingRentalEtaRequestEvent(
          picklat: event.arg.picklat,
          picklng: event.arg.picklng,
          transporttype: transportType,
        ));
      }
      markerList.add(Marker(
        markerId: const MarkerId("pick"),
        position: LatLng(
            double.parse(event.arg.picklat), double.parse(event.arg.picklng)),
        rotation: 0.0,
        icon: await MarkerWidget(
          isPickup: true,
          text: event.arg.pickupAddressList.first.address,
        ).toBitmapDescriptor(
            logicalSize: const Size(30, 30), imageSize: const Size(200, 200)),
      ));
      mapBound(double.parse(event.arg.picklat), double.parse(event.arg.picklng),
          double.parse(event.arg.picklat), double.parse(event.arg.picklng),
          isRentalRide: true);
      if (mapType == 'google_map') {
        googleMapController
            ?.animateCamera(CameraUpdate.newLatLngBounds(bound!, 100));
      } else {
        if (fmController != null) {
          fmController!.move(
              fmlt.LatLng(
                  bound!.northeast.latitude, bound!.northeast.longitude),
              13);
        }
      }
      emit(RentalPackageSelectState());
    } else {
      if (event.arg.requestId != null) {
        add(BookingGetUserDetailsEvent(requestId: event.arg.requestId));
      } else {
        if (event.arg.polyString.isEmpty &&
            (event.arg.isRentalRide == null || !event.arg.isRentalRide!) &&
            (event.arg.isWithoutDestinationRide == null ||
                !event.arg.isWithoutDestinationRide!)) {
          add(PolylineEvent(
            isInitCall: true,
            arg: event.arg,
            pickLat: double.parse(event.arg.picklat),
            pickLng: double.parse(event.arg.picklng),
            dropLat: double.parse(event.arg.droplat),
            dropLng: double.parse(event.arg.droplng),
            stops: (event.arg.stopAddressList.length > 1)
                ? event.arg.stopAddressList
                : [],
            pickAddress: event.arg.pickupAddressList.first.address,
            dropAddress: event.arg.stopAddressList.last.address,
          ));
        } else {
          if ((event.arg.isRentalRide == null || !event.arg.isRentalRide!) &&
              (event.arg.isWithoutDestinationRide == null ||
                  !event.arg.isWithoutDestinationRide!)) {
            add(BookingEtaRequestEvent(
                picklat: event.arg.picklat,
                picklng: event.arg.picklng,
                droplat: event.arg.droplat,
                droplng: event.arg.droplng,
                ridetype: 1,
                transporttype: transportType,
                distance: distance,
                duration: duration,
                polyLine: event.arg.polyString,
                pickupAddressList: pickUpAddressList,
                dropAddressList: dropAddressList,
                isOutstationRide: event.arg.isOutstationRide,
                isWithoutDestinationRide:
                    event.arg.isWithoutDestinationRide ?? false));
          }
          if ((event.arg.isWithoutDestinationRide != null &&
              event.arg.isWithoutDestinationRide!)) {
            add(BookingEtaRequestEvent(
                picklat: event.arg.picklat,
                picklng: event.arg.picklng,
                droplat: '',
                droplng: '',
                ridetype: 1,
                transporttype: transportType,
                distance: '',
                duration: '',
                polyLine: '',
                pickupAddressList: pickUpAddressList,
                dropAddressList: [],
                isOutstationRide: event.arg.isOutstationRide,
                isWithoutDestinationRide:
                    event.arg.isWithoutDestinationRide ?? false));
          }
          markerList.add(Marker(
            markerId: const MarkerId("pick"),
            position: LatLng(double.parse(event.arg.picklat),
                double.parse(event.arg.picklng)),
            rotation: 0.0,
            icon: await MarkerWidget(
              isPickup: true,
              text: event.arg.pickupAddressList.first.address,
            ).toBitmapDescriptor(
                logicalSize: const Size(30, 30),
                imageSize: const Size(200, 200)),
          ));
          if (event.arg.stopAddressList.isEmpty &&
              ((userData!.metaRequest != null && userData!.metaRequest != "") ||
                  (userData!.onTripRequest != null &&
                      userData!.onTripRequest != ""))) {
            if (((event.arg.isWithoutDestinationRide != null &&
                        !event.arg.isWithoutDestinationRide!) ||
                    (event.arg.isWithoutDestinationRide == null)) &&
                ((event.arg.isRentalRide != null && !event.arg.isRentalRide!) ||
                    event.arg.isRentalRide == null)) {
              await addDistanceMarker(
                  LatLng(double.parse(event.arg.droplat),
                      double.parse(event.arg.droplng)),
                  double.tryParse(distance)!,
                  time: double.parse(duration));
            }
            markerList.add(Marker(
              markerId: const MarkerId("drop"),
              position: LatLng(double.parse(event.arg.droplat),
                  double.parse(event.arg.droplng)),
              rotation: 0.0,
              icon: await MarkerWidget(
                isPickup: false,
                text: event.arg.stopAddressList.last.address,
              ).toBitmapDescriptor(
                  logicalSize: const Size(30, 30),
                  imageSize: const Size(200, 200)),
            ));
          } else if (event.arg.stopAddressList.isNotEmpty &&
              event.arg.stopAddressList.length > 1) {
            for (var i = 0; i < event.arg.stopAddressList.length; i++) {
              if (((event.arg.isWithoutDestinationRide != null &&
                          !event.arg.isWithoutDestinationRide!) ||
                      (event.arg.isWithoutDestinationRide == null)) &&
                  ((event.arg.isRentalRide != null &&
                          !event.arg.isRentalRide!) ||
                      event.arg.isRentalRide == null)) {
                await addDistanceMarker(
                    LatLng(double.parse(event.arg.droplat),
                        double.parse(event.arg.droplng)),
                    double.tryParse(distance)!,
                    time: double.parse(duration));
              }
              markerList.add(Marker(
                markerId: MarkerId("drop$i"),
                position: LatLng(event.arg.stopAddressList[i].lat,
                    event.arg.stopAddressList[i].lng),
                rotation: 0.0,
                icon: await MarkerWidget(
                  isPickup: false,
                  count: '${i + 1}',
                  text: event.arg.stopAddressList[i].address,
                ).toBitmapDescriptor(
                    logicalSize: const Size(30, 30),
                    imageSize: const Size(200, 200)),
              ));
            }
          } else {
            if (dropAddressList.isNotEmpty) {
              if (((event.arg.isWithoutDestinationRide != null &&
                          !event.arg.isWithoutDestinationRide!) ||
                      (event.arg.isWithoutDestinationRide == null)) &&
                  ((event.arg.isRentalRide != null &&
                          !event.arg.isRentalRide!) ||
                      event.arg.isRentalRide == null)) {
                await addDistanceMarker(
                    LatLng(double.parse(event.arg.droplat),
                        double.parse(event.arg.droplng)),
                    double.tryParse(distance)!,
                    time: double.parse(duration));
              }
              markerList.add(Marker(
                markerId: const MarkerId("drop"),
                position: LatLng(double.parse(event.arg.droplat),
                    double.parse(event.arg.droplng)),
                rotation: 0.0,
                icon: await MarkerWidget(
                  isPickup: false,
                  text: event.arg.stopAddressList.last.address,
                ).toBitmapDescriptor(
                    logicalSize: const Size(30, 30),
                    imageSize: const Size(200, 200)),
              ));
            }
          }
          if ((event.arg.isRentalRide == null ||
                  (event.arg.isRentalRide != null &&
                      !event.arg.isRentalRide!)) &&
              (event.arg.isWithoutDestinationRide == null ||
                  (event.arg.isWithoutDestinationRide != null &&
                      !event.arg.isWithoutDestinationRide!))) {
            mapBound(
              double.parse(event.arg.picklat),
              double.parse(event.arg.picklng),
              double.parse(event.arg.droplat),
              double.parse(event.arg.droplng),
            );
            decodeEncodedPolyline(event.arg.polyString);
          } else {
            mapBound(
                double.parse(event.arg.picklat),
                double.parse(event.arg.picklng),
                double.parse(event.arg.picklat),
                double.parse(event.arg.picklng),
                isRentalRide: true);
          }
        }

        if (requestData != null) {
          if (event.arg.userData.metaRequest != "") {
            if (requestData!.isBidRide == 1) {
              biddingStreamRequest();
              isBiddingRideSearching = true;
              nearByVechileSubscription?.cancel();
              etaDurationStream?.cancel();
              if (requestData!.offerredRideFare ==
                  requestData!.requestEtaAmount) {
                isBiddingDecreaseLimitReach = true;
              }
              if (event.arg.mapType == 'google_map') {
                if (googleMapController != null) {
                  googleMapController!.animateCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(
                    target: LatLng(double.parse(event.arg.picklat),
                        double.parse(event.arg.picklng)),
                    zoom: 17.0,
                  )));
                }
              } else {
                if (fmController != null) {
                  fmController!.move(
                      fmlt.LatLng(double.parse(event.arg.picklat),
                          double.parse(event.arg.picklng)),
                      13);
                }
              }
              emit(BiddingCreateRequestSuccessState());
            } else {
              streamRequest();
              isNormalRideSearching = true;
              if (event.arg.mapType == 'google_map') {
                if (googleMapController != null) {
                  googleMapController!.animateCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(
                    target: LatLng(double.parse(event.arg.picklat),
                        double.parse(event.arg.picklng)),
                    zoom: 17.0,
                  )));
                }
              } else {
                if (fmController != null) {
                  fmController!.move(
                      fmlt.LatLng(double.parse(event.arg.picklat),
                          double.parse(event.arg.picklng)),
                      13);
                }
              }
              emit(BookingCreateRequestSuccessState());
            }
          } else if (event.arg.userData.onTripRequest != "") {
            driverData = requestData!.driverDetail.data;
            isNormalRideSearching = false;
            isBiddingRideSearching = false;
            if (requestData!.isCompleted == 1) {
              rideRepository = RideRepository();
              requestBillData = requestData!.requestBill.data;
              if (driverDataStream != null) driverDataStream?.cancel();
              if (etaDurationStream != null) etaDurationStream?.cancel();
              var val = await FirebaseDatabase.instance
                  .ref('requests/${requestData!.id}')
                  .get();
              if (val.child('is_payment_received').value != null) {
                isDriverReceivedPayment =
                    (val.child('is_payment_received').value as bool?) ?? false;
                rideRepository.updatePaymentReceived(isDriverReceivedPayment);
              }
              emit(TripCompletedState(rideRepository: rideRepository));
            } else {
              streamRide();
              isTripStart = true;
              nearByVechileSubscription?.cancel();
              etaDurationStream?.cancel();
              emit(BookingUpdateState());
            }
          }
        }
        emit(BookingUpdateState());
      }
    }
  }

  Future<void> showEtaDetails(
      ShowEtaInfoEvent event, Emitter<BookingState> emit) async {
    emit(ShowEtaInfoState(infoIndex: event.infoIndex));
  }

  Future<void> selectedEtaVehicleIndex(
      BookingEtaSelectEvent event, Emitter<BookingState> emit) async {
    selectedVehicleIndex = event.selectedVehicleIndex;

    if (isRentalRide) {
      // Move the selected vehicle to the top of the list
      final selectedVehicle =
          rentalEtaDetailsList.removeAt(selectedVehicleIndex);
      rentalEtaDetailsList.insert(0, selectedVehicle);
      selectedVehicleIndex = 0;
      paymentList = rentalEtaDetailsList[0].paymentType.split(",");
      selectedPaymentType = paymentList.isNotEmpty ? paymentList.first : '';
      selectedEtaAmount = rentalEtaDetailsList[0].hasDiscount
          ? rentalEtaDetailsList[0].discountedTotel
          : rentalEtaDetailsList[0].fareAmount;
    } else {
      // Move the selected vehicle to the top of the list
      if (isMultiTypeVechiles) {
        final selectedVehicle =
            sortedEtaDetailsList.removeAt(selectedVehicleIndex);
        sortedEtaDetailsList.insert(0, selectedVehicle);
        selectedVehicleIndex = 0;
      } else {
        final selectedVehicle = etaDetailsList.removeAt(selectedVehicleIndex);
        etaDetailsList.insert(0, selectedVehicle);
        selectedVehicleIndex = 0;
      }
      paymentList = isMultiTypeVechiles
          ? sortedEtaDetailsList[0].paymentType.split(",")
          : etaDetailsList[0].paymentType.split(",");
      selectedPaymentType = paymentList.isNotEmpty ? paymentList.first : '';    
      selectedEtaAmount = isMultiTypeVechiles
          ? sortedEtaDetailsList[0].hasDiscount
              ? sortedEtaDetailsList[0].discountTotal
              : sortedEtaDetailsList[0].total
          : etaDetailsList[0].hasDiscount
              ? etaDetailsList[0].discountTotal
              : etaDetailsList[0].total;
    }
    if (!event.isOutstationRide) {
      scheduleDateTime = '';
      showDateTime = '';
      showReturnDateTime = '';
      scheduleDateTimeForReturn = '';
    }
    emit(EtaSelectState());
  }

  Future<void> selectedRentalPackageIndex(
      BookingRentalPackageSelectEvent event, Emitter<BookingState> emit) async {
    selectedPackageIndex = event.selectedPackageIndex;
    selectedPackageId = rentalPackagesList[selectedPackageIndex].id.toString();
    emit(EtaSelectState());
  }

  Future<void> timerEvent(TimerEvent event, Emitter<BookingState> emit) async {
    timerDuration = event.duration;
    emit(TimerState());
  }

  Future<void> noDriverEvent(
      NoDriversEvent event, Emitter<BookingState> emit) async {
    emit(BookingNoDriversFoundState());
  }

  timerCount(BuildContext context,
      {required int duration,
      bool? isCloseTimer,
      required bool isNormalRide}) async {
    int count = duration;

    if (isCloseTimer == null && isNormalRide) {
      normalRideTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        count--;
        if (count <= 0) {
          normalRideTimer?.cancel();
          add(NoDriversEvent());
          isNormalRideSearching = false;
          isBiddingRideSearching = false;
          add(BookingCancelRequestEvent(
              requestId: requestData!.id, timerCancel: true));
        }
        add(TimerEvent(duration: count));
      });
    } else if (isCloseTimer == null && !isNormalRide) {
      biddingRideSearchTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        count--;
        if (count <= 0) {
          biddingRideSearchTimer?.cancel();
          add(NoDriversEvent());
          isNormalRideSearching = false;
          isBiddingRideSearching = false;
          add(BookingCancelRequestEvent(
              requestId: requestData!.id, timerCancel: true));
        }
        add(TimerEvent(duration: count));
      });
    }

    if (isCloseTimer != null && isCloseTimer && isNormalRide) {
      normalRideTimer?.cancel();
      Navigator.pop(context);
      isNormalRideSearching = false;
      isBiddingRideSearching = false;
      add(TimerEvent(duration: 0));
    } else if (isCloseTimer != null && isCloseTimer && !isNormalRide) {
      biddingRideSearchTimer?.cancel();
      Navigator.pop(context);
      isNormalRideSearching = false;
      isBiddingRideSearching = false;
      add(TimerEvent(duration: 0));
    }
  }

  Future<void> typeEtaChange(
      SelectBiddingOrDemandEvent event, Emitter<BookingState> emit) async {
    showBiddingVehicles = event.isBidding;
    if (event.isBidding) {
      sortedEtaDetailsList.clear();
      for (var i = 0; i < etaDetailsList.length; i++) {
        if (etaDetailsList[i].dispatchType != 'normal') {
          sortedEtaDetailsList.add(etaDetailsList[i]);
        }
      }
      selectedVehicleIndex = 0;
      scheduleDateTime = '';
      showDateTime = '';
      showReturnDateTime = '';
      scheduleDateTimeForReturn = '';
      if (currentSize == maxChildSize ||
          currentSizeTwo == maxChildSize ||
          currentSizeThree == maxChildSize) {
        enableEtaScrolling = true;
      }
    } else {
      sortedEtaDetailsList.clear();
      for (var i = 0; i < etaDetailsList.length; i++) {
        if (etaDetailsList[i].dispatchType != 'bidding') {
          sortedEtaDetailsList.add(etaDetailsList[i]);
        }
      }

      selectedVehicleIndex = 0;

      if (currentSize == maxChildSize ||
          currentSizeTwo == maxChildSize ||
          currentSizeThree == maxChildSize) {
        enableEtaScrolling = true;
      }
    }
    emit(BookingUpdateState());
  }

  // Eta Request
  FutureOr<void> bookingEtaRequest(
      BookingEtaRequestEvent event, Emitter<BookingState> emit) async {
    final data = await serviceLocator<BookingUsecase>().etaRequest(
        picklat: event.picklat,
        picklng: event.picklng,
        droplat: event.droplat,
        droplng: event.droplng,
        rideType: event.ridetype,
        transportType: event.transporttype,
        promoCode: event.promocode,
        vehicleType: event.vehicleId,
        distance: event.distance,
        duration: event.duration,
        polyLine: event.polyLine,
        pickupAddressList: event.pickupAddressList,
        dropAddressList: event.dropAddressList,
        isOutstationRide: event.isOutstationRide,
        isWithoutDestinationRide: event.isWithoutDestinationRide);
    data.fold(
      (error) {
        if (error.message == 'logout') {
          emit(LogoutState());
        } else if (event.promocode != null) {
          promoErrorText = error.message.toString();
          showToast(message: '${error.message}');
          applyCouponController.clear();
          // promoErrorText = 'Please enter valid coupon code';
          emit(BookingUpdateState());
        } else {
          showToast(message: '${error.message}');
        }
      },
      (success) async {
        etaDetailsList.clear();
        sortedEtaDetailsList.clear();
        nearByEtaVechileList.clear();
        if (nearByVechileSubscription != null) {
          nearByVechileSubscription?.cancel();
        }
        if (etaDurationStream != null) etaDurationStream?.cancel();
        etaDetailsList = success.data;

        if (etaDetailsList.isNotEmpty) {
          if (etaDetailsList.any((element) => element.dispatchType == 'both') ||
              (etaDetailsList
                      .any((element) => element.dispatchType == 'normal') &&
                  etaDetailsList
                      .any((element) => element.dispatchType == 'bidding'))) {
            isMultiTypeVechiles = true;
            if (showBiddingVehicles) {
              for (var i = 0; i < etaDetailsList.length; i++) {
                if (etaDetailsList[i].dispatchType != 'normal') {
                  sortedEtaDetailsList.add(etaDetailsList[i]);
                }
              }
            } else {
              for (var i = 0; i < etaDetailsList.length; i++) {
                if (etaDetailsList[i].dispatchType != 'bidding') {
                  sortedEtaDetailsList.add(etaDetailsList[i]);
                }
              }
            }
          } else {
            isMultiTypeVechiles = false;
            if (etaDetailsList
                .any((element) => element.dispatchType == 'bidding')) {
              showBiddingVehicles = true;
            } else {
              showBiddingVehicles = false;
            }
          }
          savedCardList =
              (success.savedCards != null) ? success.savedCards! : [];
          paymentList = isMultiTypeVechiles
              ? sortedEtaDetailsList[selectedVehicleIndex]
                  .paymentType
                  .split(',')
              : etaDetailsList[selectedVehicleIndex].paymentType.split(',');
          selectedPaymentType = paymentList.isNotEmpty ? paymentList.first : '';    
          selectedEtaAmount = isMultiTypeVechiles
              ? sortedEtaDetailsList[selectedVehicleIndex].hasDiscount
                  ? sortedEtaDetailsList[selectedVehicleIndex].discountTotal
                  : sortedEtaDetailsList[selectedVehicleIndex].total
              : etaDetailsList[selectedVehicleIndex].hasDiscount
                  ? etaDetailsList[selectedVehicleIndex].discountTotal
                  : etaDetailsList[selectedVehicleIndex].total;

          if (event.promocode != null) {
            // applyCoupon = false;
            detailView = false;
            applyCouponController.clear();
          }
          etaDurationGetStream(etaDetailsList, double.parse(event.picklat),
              double.parse(event.picklng));
        } else {
          emit(EtaNotAvailableState());
        }
        emit(BookingSuccessState());
      },
    );
  }

  // Rental Eta Request
  FutureOr<void> rentalPackageSelect(
      ShowRentalPackageListEvent event, Emitter<BookingState> emit) async {
    emit(RentalPackageSelectState());
  }

  // Rental Eta Request
  FutureOr<void> bookingRentalEtaRequest(
      BookingRentalEtaRequestEvent event, Emitter<BookingState> emit) async {
    final data = await serviceLocator<BookingUsecase>().rentalEtaRequest(
        picklat: event.picklat,
        picklng: event.picklng,
        transportType: event.transporttype,
        promoCode: event.promocode);
    data.fold(
      (error) {
        if (error.message == 'logout') {
          emit(LogoutState());
        } else if (event.promocode != null) {
          promoErrorText = error.message.toString();
          emit(BookingUpdateState());
        } else {
          showToast(message: '${error.message}');
        }
      },
      (success) async {
        // rentalPackagesList.clear();
        rentalPackagesList = success.data;
        savedCardList = success.savedCards;
        if (event.promocode != null || event.promocode == '') {
          // applyCoupon = false;
          detailView = false;
          applyCouponController.clear();
          add(RentalPackageConfirmEvent(
              picklat: event.picklat, picklng: event.picklng));
        }
        emit(BookingUpdateState());
      },
    );
  }

  // Rental Package Confirm
  FutureOr<void> rentalPackageConfirm(
      RentalPackageConfirmEvent event, Emitter<BookingState> emit) async {
    rentalEtaDetailsList.clear();
    nearByEtaVechileList.clear();
    if (nearByVechileSubscription != null) {
      nearByVechileSubscription?.cancel();
    }
    if (etaDurationStream != null) etaDurationStream?.cancel();

    selectedPackageId = rentalPackagesList[selectedPackageIndex].id.toString();
    rentalEtaDetailsList = (rentalPackagesList.isNotEmpty &&
            rentalPackagesList[selectedPackageIndex].typesWithPrice != null)
        ? rentalPackagesList[selectedPackageIndex].typesWithPrice!.data
        : [];
    if (rentalEtaDetailsList.isNotEmpty) {
      isMultiTypeVechiles = false;
      paymentList =
          rentalEtaDetailsList[selectedVehicleIndex].paymentType.split(',');
      selectedPaymentType = paymentList.isNotEmpty ? paymentList.first : '';     
      selectedEtaAmount = rentalEtaDetailsList[selectedVehicleIndex].hasDiscount
          ? rentalEtaDetailsList[selectedVehicleIndex].discountedTotel
          : rentalEtaDetailsList[selectedVehicleIndex].fareAmount;

      etaDurationGetStream(rentalEtaDetailsList, double.parse(event.picklat),
          double.parse(event.picklng));
      emit(BookingSuccessState());
    }
    emit(RentalPackageConfirmState());
  }

  //Nearby Vechiles Stream
  etaDurationGetStream(List<dynamic> etaList, double pickLat, double pickLng) {
    if (etaDurationStream != null) etaDurationStream?.cancel();
    GeoHasher geo = GeoHasher();
    double lat = 0.0144927536231884;
    double lon = 0.0181818181818182;
    double lowerLat = 0.0;
    double lowerLon = 0.0;
    double greaterLat = 0.0;
    double greaterLon = 0.0;
    lowerLat = pickLat - (lat * 1.24);
    lowerLon = pickLng - (lon * 1.24);

    greaterLat = pickLat + (lat * 1.24);
    greaterLon = pickLng + (lon * 1.24);

    var lower = geo.encode(lowerLon, lowerLat);
    var higher = geo.encode(greaterLon, greaterLat);

    etaDurationStream = FirebaseDatabase.instance
        .ref('drivers')
        .orderByChild('g')
        .startAt(lower)
        .endAt(higher)
        .onValue
        .handleError((onError) {
      etaDurationStream?.cancel();
    }).listen((event) async {
      debugPrint('nearByStreamStart Listening');
      if (nearByEtaVechileList.isEmpty) {
        for (var i = 0; i < etaList.length; i++) {
          nearByEtaVechileList
              .add(NearbyEtaModel(typeId: etaList[i].typeId, duration: ''));
        }
      }
      List vehicleList = [];
      List vehicles = [];
      List<double> distanceList = [];
      for (var e in event.snapshot.children) {
        vehicleList.add(e.value);
      }

      for (var i = 0; i < nearByEtaVechileList.length; i++) {
        if (vehicleList.isNotEmpty) {
          for (var e in vehicleList) {
            if (e['is_active'] == 1 &&
                e['is_available'] == true &&
                ((e['vehicle_types'] != null &&
                        e['vehicle_types']
                            .contains(nearByEtaVechileList[i].typeId)) ||
                    (e['vehicle_type'] != null &&
                        e['vehicle_type'] == nearByEtaVechileList[i].typeId))) {
              DateTime dt =
                  DateTime.fromMillisecondsSinceEpoch(e['updated_at']);
              if (DateTime.now().difference(dt).inMinutes <= 2) {
                vehicles.add(e);
                if (vehicles.isNotEmpty) {
                  var dist = calculateDistance(
                    lat1: pickLat,
                    lon1: pickLng,
                    lat2: e['l'][0],
                    lon2: e['l'][1],
                    unit: userData?.distanceUnit ?? 'km',
                  );

                  distanceList.add(double.parse(dist.toString()));
                  var minDist = distanceList.reduce(math.min);
                  if (minDist > 0 && minDist <= 1) {
                    nearByEtaVechileList[i].duration = '2 mins';
                  } else if (minDist > 1 && minDist <= 3) {
                    nearByEtaVechileList[i].duration = '5 mins';
                  } else if (minDist > 3 && minDist <= 5) {
                    nearByEtaVechileList[i].duration = '8 mins';
                  } else if (minDist > 5 && minDist <= 7) {
                    nearByEtaVechileList[i].duration = '11 mins';
                  } else if (minDist > 7 && minDist <= 10) {
                    nearByEtaVechileList[i].duration = '14 mins';
                  } else if (minDist > 10) {
                    nearByEtaVechileList[i].duration = '15 mins';
                  }
                } else {
                  nearByEtaVechileList[i].duration = '';
                }
              }
            }
          }
        }
      }
      // add(UpdateEvent());
    });
  }

  Future<void> createRequestEvent(
      BookingCreateRequestEvent event, Emitter<BookingState> emit) async {
    isLoading = true;
    emit(BookingUpdateState());
    final data = await serviceLocator<BookingUsecase>().createRequest(
        userData: event.userData,
        vehicleData: event.vehicleData,
        pickupAddressList: event.pickupAddressList,
        dropAddressList: event.dropAddressList,
        selectedTransportType: event.selectedTransportType,
        paidAt: event.paidAt,
        parcelType: event.parcelType,
        selectedPaymentType:
            event.cardToken.isNotEmpty ? 'card' : event.selectedPaymentType,
        cardToken: event.cardToken,
        scheduleDateTime: event.scheduleDateTime,
        isEtaRental: event.isRentalRide,
        isBidRide: false,
        goodsTypeId: event.goodsTypeId,
        goodsQuantity:
            event.goodsQuantity.isEmpty ? 'Loose' : event.goodsQuantity,
        offeredRideFare: "",
        polyLine: event.polyLine,
        isPetAvailable: event.isPetAvailable,
        isLuggageAvailable: event.isLuggageAvailable,
        isAirport: ((event.pickupAddressList.first.isAirportLocation != null &&
                    event.pickupAddressList.first.isAirportLocation!) ||
                (event.dropAddressList.any((element) =>
                    (element.isAirportLocation != null &&
                        element.isAirportLocation!))))
            ? true
            : false,
        isParcel: (event.selectedTransportType == 'delivery') ? true : false,
        packageId: selectedPackageId,
        isOutstationRide: false,
        isRoundTrip: false,
        scheduleDateTimeForReturn: '',
        taxiInstruction: instructionsController.text);
    data.fold(
      (error) {
        isLoading = false;
        if (error.message == 'logout') {
          emit(LogoutState());
        } else {
          showToast(message: '${error.message}');
          emit(BookingCreateRequestFailureState());
        }
      },
      (success) async {
        isLoading = false;
        isTripStart = true;
        nearByVechileSubscription?.cancel();
        etaDurationStream?.cancel();
        if (success['success']) {
          if (event.scheduleDateTime.isEmpty) {
            requestData = OnTripRequestData.fromJson(success["data"]);
            streamRequest();
            isNormalRideSearching = true;
            isBiddingRideSearching = false;
            if (mapType == 'google_map') {
              if (googleMapController != null) {
                googleMapController!
                    .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                  target: LatLng(event.pickupAddressList.first.lat,
                      event.pickupAddressList.first.lng),
                  zoom: 15.5,
                )));
              }
            } else {
              if (fmController != null) {
                fmController!.move(
                    fmlt.LatLng(event.pickupAddressList.first.lat,
                        event.pickupAddressList.first.lng),
                    13);
              }
            }
            emit(BookingCreateRequestSuccessState());
          } else {
            emit(BookingLaterCreateRequestSuccessState(isOutstation: false));
          }
        }else{
          showToast(message: '${success['message']}');
          emit(BookingCreateRequestFailureState());
        }
      },
    );
  }

  FutureOr cancelRequest(
      BookingCancelRequestEvent event, Emitter<BookingState> emit) async {
    emit(BookingLoadingStartState());
    final data = await serviceLocator<BookingUsecase>().cancelRequest(
        requestId: event.requestId,
        reason: event.reason,
        timerCancel: event.timerCancel,
        customReason: event.customReason);
    data.fold(
      (error) {
        debugPrint(error.toString());
        emit(BookingLoadingStopState());
        if (error.message == 'logout') {
          emit(LogoutState());
        }
      },
      (success) {
        requestData = null;
        isTripStart = false;
        isNormalRideSearching = false;
        isBiddingRideSearching = false;
        isBiddingIncreaseLimitReach = false;
        isBiddingDecreaseLimitReach = false;
        emit(BookingUpdateState());
        if (requestData != null) {
          if (requestData!.isBidRide == 1) {
            FirebaseDatabase.instance
                .ref('bid-meta/${requestData!.id}')
                .remove();
            if (biddingRequestStream?.isPaused == false ||
                biddingRequestStream != null) {
              biddingRequestStream?.cancel();
            }
            emit(BookingRequestCancelState());
          }
          FirebaseDatabase.instance
              .ref('requests')
              .child(requestData!.id)
              .update({'cancelled_by_user': true});
        }
        requestStreamStart?.cancel();
        rideStreamUpdate?.cancel();
        rideStreamStart?.cancel();
        driverDataStream?.cancel();
        requestStreamStart = null;
        rideStreamUpdate = null;
        rideStreamStart = null;
        driverDataStream = null;
        emit(BookingLoadingStopState());
      },
    );
  }

  FutureOr onTripRideCancel(
      TripRideCancelEvent event, Emitter<BookingState> emit) async {
    requestData = null;
    isTripStart = false;
    requestStreamStart?.cancel();
    rideStreamUpdate?.cancel();
    rideStreamStart?.cancel();
    driverDataStream?.cancel();
    requestStreamStart = null;
    rideStreamUpdate = null;
    rideStreamStart = null;
    driverDataStream = null;
    emit(TripRideCancelState(isCancelByDriver: event.isCancelByDriver));
  }

  FutureOr getUserDetails(
      BookingGetUserDetailsEvent event, Emitter<BookingState> emit) async {
    final data = await serviceLocator<HomeUsecase>()
        .userDetails(requestId: event.requestId);
    await data.fold((error) {
      debugPrint(error.toString());
      if (error.message == 'logout') {
        emit(LogoutState());
      }
    }, (success) async {
      userData = success.data;
      if (userData!.onTripRequest != null &&
          userData!.onTripRequest != "" &&
          userData!.onTripRequest.data != null &&
          userData!.onTripRequest.data.driverDetail != null) {
        requestData = userData!.onTripRequest.data;
        driverData = userData!.onTripRequest.data.driverDetail.data;
        // showPolyline = true;
        if (requestData != null) {
          if (rideStreamUpdate == null ||
              rideStreamUpdate?.isPaused == true ||
              rideStreamStart == null ||
              rideStreamStart?.isPaused == true) {
            var val = await FirebaseDatabase.instance
              .ref('requests/${requestData!.id}').get();
            if (val.child('additional_charges_reason').value != null) {
              additionalChargesReason = val.child('additional_charges_reason').value.toString();
            }
            if (val.child('additional_charges_amount').value != null) {
              additionalChargesAmount = val.child('additional_charges_amount').value.toString();
            }    
            streamRide();
            isTripStart = true;
            nearByVechileSubscription?.cancel();
            etaDurationStream?.cancel();
            if (isNormalRideSearching) {
              isNormalRideSearching = false;
            }
            if (isBiddingRideSearching) {
              isBiddingRideSearching = false;
            }
            emit(BookingUpdateState());
          }
        } else {
          if (rideStreamUpdate != null ||
              rideStreamUpdate?.isPaused == false ||
              rideStreamStart != null ||
              rideStreamStart?.isPaused == false) {
            rideStreamUpdate?.cancel();
            rideStreamUpdate = null;
            rideStreamStart?.cancel();
            rideStreamStart = null;
          }
        }
        if (requestData!.isTripStart != 1 && requestData!.acceptedAt != '') {
          nearByVechileSubscription?.cancel();
          etaDurationStream?.cancel();
        }
        if ((requestData!.isTripStart != 1 ||
                requestData!.isOutStation == '1') &&
            (requestData!.arrivedAt != '') &&
            // (requestData!.arrivedAt != '' ||
            // requestData!.isOutStation == '1') &&
            (requestData!.dropLat != '0' &&
                requestData!.dropLng != '0' &&
                !requestData!.isRental)) {
          // markerList.removeWhere((element) =>
          //     element.markerId.value.contains('${driverData!.id}'));
          final BitmapDescriptor bikeMarker = await BitmapDescriptor.asset(
              const ImageConfiguration(size: Size(20, 34)), AppImages.bike);

          final BitmapDescriptor carMarker = await BitmapDescriptor.asset(
              const ImageConfiguration(size: Size(20, 34)), AppImages.car);

          final BitmapDescriptor autoMarker = await BitmapDescriptor.asset(
              const ImageConfiguration(size: Size(20, 34)), AppImages.auto);

          final BitmapDescriptor truckMarker = await BitmapDescriptor.asset(
              const ImageConfiguration(size: Size(20, 34)), AppImages.truck);

          final BitmapDescriptor ehcv = await BitmapDescriptor.asset(
              const ImageConfiguration(size: Size(20, 34)), AppImages.ehcv);

          final BitmapDescriptor hatchBack = await BitmapDescriptor.asset(
              const ImageConfiguration(size: Size(20, 34)),
              AppImages.hatchBack);

          final BitmapDescriptor hcv = await BitmapDescriptor.asset(
              const ImageConfiguration(size: Size(20, 34)), AppImages.hcv);

          final BitmapDescriptor lcv = await BitmapDescriptor.asset(
              const ImageConfiguration(size: Size(20, 34)), AppImages.lcv);

          final BitmapDescriptor mcv = await BitmapDescriptor.asset(
              const ImageConfiguration(size: Size(20, 34)), AppImages.mcv);

          final BitmapDescriptor luxury = await BitmapDescriptor.asset(
              const ImageConfiguration(size: Size(20, 34)), AppImages.luxury);

          final BitmapDescriptor premium = await BitmapDescriptor.asset(
              const ImageConfiguration(size: Size(20, 34)), AppImages.premium);

          final BitmapDescriptor suv = await BitmapDescriptor.asset(
              const ImageConfiguration(size: Size(20, 34)), AppImages.suv);
          final marker = (driverData!.vehicleTypeIcon == 'truck')
              ? truckMarker
              : (driverData!.vehicleTypeIcon == 'motor_bike')
                  ? bikeMarker
                  : (driverData!.vehicleTypeIcon == 'auto')
                      ? autoMarker
                      : (driverData!.vehicleTypeIcon == 'lcv')
                          ? lcv
                          : (driverData!.vehicleTypeIcon == 'ehcv')
                              ? ehcv
                              : (driverData!.vehicleTypeIcon == 'hatchback')
                                  ? hatchBack
                                  : (driverData!.vehicleTypeIcon == 'hcv')
                                      ? hcv
                                      : (driverData!.vehicleTypeIcon == 'mcv')
                                          ? mcv
                                          : (driverData!.vehicleTypeIcon ==
                                                  'luxury')
                                              ? luxury
                                              : (driverData!.vehicleTypeIcon ==
                                                      'premium')
                                                  ? premium
                                                  : (driverData!
                                                              .vehicleTypeIcon ==
                                                          'suv')
                                                      ? suv
                                                      : carMarker;
          if (requestData!.polyLine.isNotEmpty) {
            markerList.clear();
            markerList.add(Marker(
              markerId: const MarkerId("pick"),
              position: LatLng(double.parse(requestData!.pickLat),
                  double.parse(requestData!.pickLng)),
              rotation: 0.0,
              icon: await MarkerWidget(
                isPickup: true,
                text: requestData!.pickAddress,
              ).toBitmapDescriptor(
                  logicalSize: const Size(30, 30),
                  imageSize: const Size(200, 200)),
            ));
            if (userData != null &&
                requestData!.requestStops.data.isEmpty &&
                ((userData!.metaRequest != null &&
                        userData!.metaRequest != "") ||
                    (userData!.onTripRequest != null &&
                        userData!.onTripRequest != ""))) {
              markerList.add(Marker(
                markerId: const MarkerId("drop"),
                position: LatLng(double.parse(requestData!.dropLat),
                    double.parse(requestData!.dropLng)),
                rotation: 0.0,
                icon: await MarkerWidget(
                  isPickup: false,
                  text: requestData!.dropAddress,
                ).toBitmapDescriptor(
                    logicalSize: const Size(30, 30),
                    imageSize: const Size(200, 200)),
              ));
            } else if (requestData!.requestStops.data.isNotEmpty) {
              for (var i = 0; i < requestData!.requestStops.data.length; i++) {
                markerList.add(Marker(
                  markerId: MarkerId("drop$i"),
                  position: LatLng(requestData!.requestStops.data[i].lat,
                      requestData!.requestStops.data[i].lng),
                  rotation: 0.0,
                  icon: await MarkerWidget(
                    isPickup: false,
                    count: '${i + 1}',
                    text: requestData!.requestStops.data[i].address,
                  ).toBitmapDescriptor(
                      logicalSize: const Size(30, 30),
                      imageSize: const Size(200, 200)),
                ));
              }
            } else {
              markerList.add(Marker(
                markerId: const MarkerId("drop"),
                position: LatLng(double.parse(requestData!.dropLat),
                    double.parse(requestData!.dropLng)),
                rotation: 0.0,
                icon: await MarkerWidget(
                  isPickup: true,
                  text: requestData!.dropAddress,
                ).toBitmapDescriptor(
                    logicalSize: const Size(30, 30),
                    imageSize: const Size(200, 200)),
              ));
            }
            mapBound(
              double.parse(requestData!.pickLat),
              double.parse(requestData!.pickLng),
              double.parse(requestData!.dropLat),
              double.parse(requestData!.dropLng),
            );
            decodeEncodedPolyline(requestData!.polyLine);
          } else {
            markerList.clear();
            add(PolylineEvent(
              pickLat: double.parse(requestData!.pickLat),
              pickLng: double.parse(requestData!.pickLng),
              dropLat: double.parse(requestData!.dropLat),
              dropLng: double.parse(requestData!.dropLng),
              stops: (requestData != null &&
                      requestData!.arrivedAt != "" &&
                      dropAddressList.length > 1)
                  ? dropAddressList
                  : [],
              pickAddress: '',
              dropAddress: '',
              icon: marker,
            ));
          }
        } else {
          if (mapType == 'google_map') {
            if (googleMapController != null) {
              googleMapController!
                  .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                target: LatLng(double.parse(requestData!.pickLat),
                    double.parse(requestData!.pickLng)),
                zoom: 17.0,
              )));
            }
          } else {
            if (fmController != null) {
              fmController!.move(
                  fmlt.LatLng(double.parse(requestData!.pickLat),
                      double.parse(requestData!.pickLng)),
                  13);
            }
          }
        }
        if (requestData!.isCompleted == 1) {
          rideRepository = RideRepository();
          if (requestData!.requestBill != null) {
            requestBillData = requestData!.requestBill.data;
          }

          var val = await FirebaseDatabase.instance
              .ref('requests/${requestData!.id}')
              .get();
          if (val.child('is_payment_received').value != null) {
            isDriverReceivedPayment =
                (val.child('is_payment_received').value as bool?) ?? false;
            rideRepository.updatePaymentReceived(isDriverReceivedPayment);
          } else {
            isDriverReceivedPayment = requestData!.isPaid == 1 ? true : false;
            rideRepository.updatePaymentReceived(isDriverReceivedPayment);
          }
          if (driverDataStream != null) driverDataStream?.cancel();
          if (etaDurationStream != null) etaDurationStream?.cancel();
          emit(TripCompletedState(rideRepository: rideRepository));
        } else {
          if (normalRideTimer != null) {
            normalRideTimer?.cancel();
          }
          if (biddingRideSearchTimer != null) {
            biddingRideSearchTimer?.cancel();
          }
          if (biddingRideTimer != null) {
            biddingRideTimer?.cancel();
          }
          requestStreamStart?.cancel();
          biddingRequestStream?.cancel();
        }
        emit(BookingUpdateState());
      } else if (userData!.metaRequest != null && userData!.metaRequest != "") {
        requestData = userData!.metaRequest.data;
        if (requestStreamStart == null ||
            requestStreamStart?.isPaused == true) {
          streamRequest();
        }
      } else {
        requestData = null;
        isTripStart = false;
        isNormalRideSearching = false;
        isBiddingRideSearching = false;
        normalRideTimer?.cancel();
        biddingRideSearchTimer?.cancel();
        requestStreamStart?.cancel();
        rideStreamUpdate?.cancel();
        rideStreamStart?.cancel();
        biddingRequestStream?.cancel();
        driverDataStream?.cancel();
        etaDurationStream?.cancel();
        normalRideTimer = null;
        biddingRideSearchTimer = null;
        requestStreamStart = null;
        rideStreamUpdate = null;
        rideStreamStart = null;
        biddingRequestStream = null;
        driverDataStream = null;
        etaDurationStream = null;
        emit(BookingUpdateState());
      }
    });
  }

  FutureOr bookingStreamRequest(
      BookingStreamRequestEvent event, Emitter<BookingState> emit) async {
    emit(BookingStreamRequestState());
  }

  //requestStream
  streamRequest() {
    if (requestStreamStart != null) {
      requestStreamStart?.cancel();
    }
    if (rideStreamUpdate != null) {
      rideStreamUpdate?.cancel();
    }
    if (rideStreamStart != null) {
      rideStreamStart?.cancel();
    }

    requestStreamStart = FirebaseDatabase.instance
        .ref('request-meta')
        .child(requestData!.id)
        .onChildRemoved
        .handleError((onError) {
      requestStreamStart?.cancel();
    }).listen((event) async {
      debugPrint('requestStreamStart Listening');
      add(BookingGetUserDetailsEvent(requestId: requestData!.id));
      // requestStreamStart?.cancel();
      add(BookingStreamRequestEvent());
    });
  }

  //rideStream
  streamRide() {
    rideRepository = RideRepository();
    waitingTime = 0;
    if (requestStreamStart != null) requestStreamStart?.cancel();
    if (rideStreamUpdate != null) rideStreamUpdate?.cancel();
    if (rideStreamStart != null) rideStreamStart?.cancel();
    if (driverDataStream != null) driverDataStream?.cancel();
    rideStreamUpdate = FirebaseDatabase.instance
        .ref('requests/${requestData!.id}')
        .onChildChanged
        .handleError((onError) {
      rideStreamUpdate?.cancel();
    }).listen((DatabaseEvent event) async {
      debugPrint('rideStreamUpdate Listening');
      if (event.snapshot.key.toString() == 'modified_by_driver') {
        if (!isClosed) {
          add(BookingGetUserDetailsEvent(requestId: requestData!.id));
        }
      } else if (event.snapshot.key.toString() == 'message_by_driver') {
        add(GetChatHistoryEvent(requestId: requestData!.id));
      } else if (event.snapshot.key.toString() == 'cancelled_by_driver') {
        add(TripRideCancelEvent(isCancelByDriver: true));
        add(BookingGetUserDetailsEvent());
      } else if (event.snapshot.key.toString() == 'waiting_time_before_start') {
        var val = event.snapshot.value.toString();
        debugPrint('waiting Time : $val');
        waitingTime = int.parse(val);
      } else if (event.snapshot.key.toString() == 'is_accept') {
        markerList.removeWhere((element) => element.markerId.value.contains('#'));
        add(BookingGetUserDetailsEvent(requestId: requestData!.id));
      } else if (event.snapshot.value != null &&
          event.snapshot.key == 'is_user_paid') {
        add(BookingGetUserDetailsEvent(requestId: requestData!.id));
      } else if (event.snapshot.value != null &&
          event.snapshot.key == 'additional_charges_reason') {
        additionalChargesReason = event.snapshot.value.toString();
        add(UpdateEvent());
      } else if (event.snapshot.value != null &&
          event.snapshot.key == 'additional_charges_amount') {
        additionalChargesAmount = event.snapshot.value.toString();
        add(UpdateEvent());
      }

      if (event.snapshot.key.toString() == 'polyline') {
        polyLine = event.snapshot.child('polyline').value.toString();
        driverStreamRide(isFromRequstStream: true);
      }
      if (event.snapshot.key.toString() == 'distance') {
        distance = event.snapshot.child('distance').value.toString();
        add(UpdateEvent());
      }
      if (event.snapshot.key.toString() == 'duration') {
        duration = event.snapshot.child('duration').value.toString();
        if (!isClosed) {
          add(UpdateEvent());
        }
      }
      if (event.snapshot.key.toString() == 'is_payment_received') {
        isDriverReceivedPayment =
            (event.snapshot.child('is_payment_received').value as bool?) ??
                false;

        rideRepository.updatePaymentReceived(isDriverReceivedPayment);
        add(UpdateEvent());
      }
    });

    rideStreamStart = FirebaseDatabase.instance
        .ref('requests/${requestData!.id}')
        .onChildAdded
        .handleError((onError) {
      rideStreamStart?.cancel();
    }).listen((DatabaseEvent event) async {
      if (event.snapshot.key.toString() == 'cancelled_by_driver') {
        add(TripRideCancelEvent(isCancelByDriver: true));
        add(BookingGetUserDetailsEvent());
      } else if (event.snapshot.key.toString() == 'modified_by_driver') {
        add(BookingGetUserDetailsEvent(requestId: requestData!.id));
      } else if (event.snapshot.key.toString() == 'message_by_driver') {
        add(GetChatHistoryEvent(requestId: requestData!.id));
      } else if (event.snapshot.key.toString() == 'waiting_time_after_start') {
        var val = event.snapshot.value.toString();
        debugPrint('waiting Time : $val');
        waitingTime = int.parse(val);
      } else if (event.snapshot.key.toString() == 'is_accept') {
        driverStreamRide();
        markerList.removeWhere((element) => element.markerId.value.contains('#'));
        add(BookingGetUserDetailsEvent(requestId: requestData!.id));
      } else if (event.snapshot.value != null &&
          event.snapshot.key == 'is_user_paid') {
        add(BookingGetUserDetailsEvent(requestId: requestData!.id));
      } else if (event.snapshot.value != null &&
          event.snapshot.key == 'additional_charges_reason') {
        additionalChargesReason = event.snapshot.value.toString();
        add(UpdateEvent());
      } else if (event.snapshot.value != null &&
          event.snapshot.key == 'additional_charges_amount') {
        additionalChargesAmount = event.snapshot.value.toString();
        add(UpdateEvent());
      }

      if (event.snapshot.key.toString() == 'polyline') {
        polyLine = event.snapshot.child('polyline').value.toString();
        driverStreamRide(isFromRequstStream: true);
      }
      if (event.snapshot.key.toString() == 'distance') {
        distance = event.snapshot.child('distance').value.toString();
        add(UpdateEvent());
      }
      if (event.snapshot.key.toString() == 'duration') {
        duration = event.snapshot.child('duration').value.toString();
        add(UpdateEvent());
      }
      if (event.snapshot.key.toString() == 'is_payment_received') {
        isDriverReceivedPayment =
            (event.snapshot.child('is_payment_received').value as bool?) ??
                false;
        rideRepository.updatePaymentReceived(isDriverReceivedPayment);
        if (!isClosed) {
          add(UpdateEvent());
        }
      }
    });
  }

  driverStreamRide({int? driverId, bool? isFromRequstStream}) {
    if (driverDataStream != null) driverDataStream?.cancel();
    driverDataStream = FirebaseDatabase.instance
        .ref('drivers/driver_${(driverId != null) ? driverId : driverData!.id}')
        .onValue
        .handleError((onError) {
      driverDataStream?.cancel();
    }).listen((DatabaseEvent event) async {
      debugPrint('Driver Stream');
      dynamic driver = jsonDecode(jsonEncode(event.snapshot.value));
      final BitmapDescriptor bikeMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(20, 34)), AppImages.bike);

      final BitmapDescriptor carMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(20, 34)), AppImages.car);

      final BitmapDescriptor autoMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(20, 34)), AppImages.auto);

      final BitmapDescriptor truckMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(20, 34)), AppImages.truck);

      final BitmapDescriptor ehcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(20, 34)), AppImages.ehcv);

      final BitmapDescriptor hatchBack = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(20, 34)), AppImages.hatchBack);

      final BitmapDescriptor hcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(20, 34)), AppImages.hcv);

      final BitmapDescriptor lcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(20, 34)), AppImages.lcv);

      final BitmapDescriptor mcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(20, 34)), AppImages.mcv);

      final BitmapDescriptor luxury = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(20, 34)), AppImages.luxury);

      final BitmapDescriptor premium = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(20, 34)), AppImages.premium);

      final BitmapDescriptor suv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(20, 34)), AppImages.suv);
      final marker = (driver['vehicle_type_icon'] == 'truck')
          ? truckMarker
          : (driver['vehicle_type_icon'] == 'motor_bike')
              ? bikeMarker
              : (driver['vehicle_type_icon'] == 'auto')
                  ? autoMarker
                  : (driver['vehicle_type_icon'] == 'lcv')
                      ? lcv
                      : (driver['vehicle_type_icon'] == 'ehcv')
                          ? ehcv
                          : (driver['vehicle_type_icon'] == 'hatchback')
                              ? hatchBack
                              : (driver['vehicle_type_icon'] == 'hcv')
                                  ? hcv
                                  : (driver['vehicle_type_icon'] == 'mcv')
                                      ? mcv
                                      : (driver['vehicle_type_icon'] ==
                                              'luxury')
                                          ? luxury
                                          : (driver['vehicle_type_icon'] ==
                                                  'premium')
                                              ? premium
                                              : (driver['vehicle_type_icon'] ==
                                                      'suv')
                                                  ? suv
                                                  : carMarker;

      if (vsync != null &&
          (driverPosition != null &&
              driverPosition!.latitude != driver["l"][0] &&
              driverPosition!.longitude != driver["l"][1]) &&
          ((mapType == 'google_map' && googleMapController != null) ||
              (mapType != 'google_map' && fmController != null))) {
        animationController1 = AnimationController(
            vsync: vsync, duration: const Duration(milliseconds: 1500));
        animateCar(
            driverPosition!.latitude,
            driverPosition!.longitude,
            driver["l"][0],
            driver["l"][1],
            vsync,
            (mapType == 'google_map') ? googleMapController! : fmController!,
            'marker#${driver['id']}#${driver['vehicle_type_icon']}',
            marker,
            mapType);
      }
      if (isFromRequstStream != null && isFromRequstStream) {
        driverPosition = LatLng(driver["l"][0], driver["l"][1]);
        if (!markerList.any((element) => element.markerId.value.contains('#'))) {
          markerList.add(Marker(
            markerId: MarkerId(
                'marker#${driver['id']}#${driver['vehicle_type_icon']}'),
            position: LatLng(driver["l"][0], driver["l"][1]),
            rotation: 0.0,
            icon: marker,
          ));
        }
        if (requestData != null &&
            requestData!.arrivedAt != "" &&
            dropAddressList.length > 1) {
          for (var i = 0; i < dropAddressList.length; i++) {
            markerList.add(Marker(
              markerId: MarkerId("drop$i"),
              position: LatLng(dropAddressList[i].lat, dropAddressList[i].lng),
              rotation: 0.0,
              icon: await MarkerWidget(
                isPickup: false,
                count: '${i + 1}',
                text: dropAddressList[i].address,
              ).toBitmapDescriptor(
                  logicalSize: const Size(30, 30),
                  imageSize: const Size(200, 200)),
            ));
          }
        }
        await addDistanceMarker(
            (requestData != null && requestData!.arrivedAt == "")
                ? LatLng(double.parse(requestData!.pickLat),
                    double.parse(requestData!.pickLng))
                : LatLng(double.parse(requestData!.dropLat),
                    double.parse(requestData!.dropLng)),
            double.tryParse(distance)!,
            time: double.parse(duration));

        markerList.add(Marker(
          markerId: const MarkerId("drop"),
          position: (requestData != null && requestData!.arrivedAt == "")
              ? LatLng(double.parse(requestData!.pickLat),
                  double.parse(requestData!.pickLng))
              : LatLng(double.parse(requestData!.dropLat),
                  double.parse(requestData!.dropLng)),
          rotation: 0.0,
          icon: await MarkerWidget(
            isPickup: (requestData != null && requestData!.arrivedAt == "")
                ? true
                : false,
            text: requestData!.dropAddress,
          ).toBitmapDescriptor(
              logicalSize: const Size(30, 30), imageSize: const Size(200, 200)),
        ));
        if (requestData != null && requestData!.arrivedAt == "") {
          mapBound(
              driver["l"][0],
              driver["l"][1],
              double.parse(requestData!.pickLat),
              double.parse(requestData!.pickLng),
              isInitCall: false);
        } else {
          mapBound(
              driver["l"][0],
              driver["l"][1],
              double.parse(requestData!.dropLat),
              double.parse(requestData!.dropLng),
              isInitCall: false);
        }
        decodeEncodedPolyline(polyLine, isDriverStream: true);
      }
    });
  }

  // Reviews
  Future<void> ratingsSelectEvent(
      BookingRatingsSelectEvent event, Emitter<BookingState> emit) async {
    selectedRatingsIndex = event.selectedIndex;
    emit(BookingRatingsUpdateState());
  }

  Future<void> userRatings(
      BookingUserRatingsEvent event, Emitter<BookingState> emit) async {
    final data = await serviceLocator<BookingUsecase>().userReview(
        requestId: event.requestId,
        ratings: event.ratings,
        feedBack: event.feedBack);
    data.fold(
      (error) {
        debugPrint(error.toString());
        if (error.message == 'logout') {
          emit(LogoutState());
        }
      },
      (success) {
        emit(BookingUserRatingsSuccessState());
      },
    );
  }

  Future<void> getGoodsType(
      GetGoodsTypeEvent event, Emitter<BookingState> emit) async {
    if (goodsTypeList.isEmpty) {
      final data = await serviceLocator<BookingUsecase>().getGoodsTypes();
      data.fold(
        (error) {
          debugPrint(error.toString());
          if (error.message == 'logout') {
            emit(LogoutState());
          }
        },
        (success) {
          goodsTypeList = success.data;
          emit(SelectGoodsTypeState());
        },
      );
    } else {
      emit(SelectGoodsTypeState());
    }
  }

  Future<void> enableBiddingEvent(
      EnableBiddingEvent event, Emitter<BookingState> emit) async {
    emit(ShowBiddingState());
  }

  Future<void> biddingFareIncreaseDecrease(
      BiddingIncreaseOrDecreaseEvent event, Emitter<BookingState> emit) async {
    final String bidHighPercentage = isMultiTypeVechiles
        ? sortedEtaDetailsList[selectedVehicleIndex].biddingHighPercentage
        : etaDetailsList[selectedVehicleIndex].biddingHighPercentage;
    final String bidLowPercentage = isMultiTypeVechiles
        ? sortedEtaDetailsList[selectedVehicleIndex].biddingLowPercentage
        : etaDetailsList[selectedVehicleIndex].biddingLowPercentage;
    final double basePrice = isMultiTypeVechiles
        ? sortedEtaDetailsList[selectedVehicleIndex].basePrice
        : etaDetailsList[selectedVehicleIndex].basePrice;
    final double totalValue = isMultiTypeVechiles
        ? (event.isOutStation && isRoundTrip)
            ? (sortedEtaDetailsList[selectedVehicleIndex].total * 2)
            : sortedEtaDetailsList[selectedVehicleIndex].total
        : (event.isOutStation && isRoundTrip)
            ? (etaDetailsList[selectedVehicleIndex].total * 2)
            : etaDetailsList[selectedVehicleIndex].total;

    if (farePriceController.text.isEmpty) {
      farePriceController.text = (requestData != null)
          ? requestData!.offerredRideFare
          : totalValue.toString();
    }
    if (requestData == null) {
      if (event.isIncrease) {
        if (bidHighPercentage == "0" ||
            (double.parse(farePriceController.text.toString()) +
                    (double.parse(userData!.biddingAmountIncreaseOrDecrease
                        .toString()))) <=
                (totalValue +
                    ((double.parse(bidHighPercentage) / 100) * totalValue))) {
          isBiddingIncreaseLimitReach = false;
          isBiddingDecreaseLimitReach = false;
          farePriceController.text = (farePriceController.text.isEmpty)
              ? (basePrice +
                      double.parse(
                          userData!.biddingAmountIncreaseOrDecrease.toString()))
                  .toStringAsFixed(2)
              : (double.parse(farePriceController.text.toString()) +
                      double.parse(
                          userData!.biddingAmountIncreaseOrDecrease.toString()))
                  .toStringAsFixed(2);
        } else {
          isBiddingIncreaseLimitReach = true;
          isBiddingDecreaseLimitReach = false;
        }
        emit(BookingUpdateState());
      } else {
        if (farePriceController.text.isNotEmpty &&
            double.parse(farePriceController.text.toString()) > totalValue &&
            (bidLowPercentage == "0" ||
                (double.parse(farePriceController.text.toString()) -
                        double.parse(
                            userData!.biddingAmountIncreaseOrDecrease)) >=
                    (totalValue -
                        ((double.parse(bidLowPercentage) / 100) *
                            totalValue)))) {
          isBiddingDecreaseLimitReach = false;
          isBiddingIncreaseLimitReach = false;
          farePriceController.text = (farePriceController.text.isEmpty)
              ? (totalValue -
                      (double.parse(userData!.biddingAmountIncreaseOrDecrease
                          .toString())))
                  .toStringAsFixed(2)
              : (double.parse(farePriceController.text.toString()) -
                      (double.parse(userData!.biddingAmountIncreaseOrDecrease
                          .toString())))
                  .toStringAsFixed(2);
        } else {
          isBiddingDecreaseLimitReach = true;
          isBiddingIncreaseLimitReach = false;
        }
        emit(BookingUpdateState());
      }
    } else {
      if (event.isIncrease) {
        if ((requestData != null &&
                requestData!.biddingHighPercentage == "0") ||
            (double.parse(farePriceController.text.toString()) +
                    (double.parse(userData!.biddingAmountIncreaseOrDecrease
                        .toString()))) <=
                (double.parse(requestData!.requestEtaAmount) +
                    ((double.parse(requestData!.biddingHighPercentage) / 100) *
                        double.parse(requestData!.requestEtaAmount)))) {
          isBiddingIncreaseLimitReach = false;
          isBiddingDecreaseLimitReach = false;
          farePriceController.text = (farePriceController.text.isEmpty)
              ? (double.parse(requestData!.offerredRideFare) +
                      double.parse(
                          userData!.biddingAmountIncreaseOrDecrease.toString()))
                  .toStringAsFixed(2)
              : (double.parse(farePriceController.text.toString()) +
                      double.parse(
                          userData!.biddingAmountIncreaseOrDecrease.toString()))
                  .toStringAsFixed(2);
          if (!((double.parse(farePriceController.text.toString()) +
                  (double.parse(
                      userData!.biddingAmountIncreaseOrDecrease.toString()))) <=
              (double.parse(requestData!.requestEtaAmount) +
                  ((double.parse(requestData!.biddingHighPercentage) / 100) *
                      double.parse(requestData!.requestEtaAmount))))) {
            isBiddingIncreaseLimitReach = true;
            isBiddingDecreaseLimitReach = false;
          }
        } else {
          isBiddingIncreaseLimitReach = true;
          isBiddingDecreaseLimitReach = false;
        }
        emit(BookingUpdateState());
      } else {
        if (farePriceController.text.isNotEmpty &&
            requestData != null &&
            double.parse(farePriceController.text.toString()) >
                double.parse(requestData!.requestEtaAmount) &&
            ((requestData!.biddingLowPercentage == "0") ||
                (double.parse(farePriceController.text.toString()) -
                        double.parse(
                            userData!.biddingAmountIncreaseOrDecrease)) >=
                    (double.parse(requestData!.requestEtaAmount) -
                        ((double.parse(requestData!.biddingLowPercentage) /
                                100) *
                            double.parse(requestData!.requestEtaAmount))))) {
          isBiddingDecreaseLimitReach = false;
          isBiddingIncreaseLimitReach = false;
          farePriceController.text = (farePriceController.text.isEmpty)
              ? double.parse(requestData!.offerredRideFare).toStringAsFixed(2)
              : (double.parse(farePriceController.text.toString()) -
                      (double.parse(userData!.biddingAmountIncreaseOrDecrease
                          .toString())))
                  .toStringAsFixed(2);
          if (double.parse(farePriceController.text.toString()) ==
              double.parse(requestData!.requestEtaAmount)) {
            isBiddingDecreaseLimitReach = true;
            isBiddingIncreaseLimitReach = false;
          }
        } else {
          isBiddingDecreaseLimitReach = true;
          isBiddingIncreaseLimitReach = false;
        }
        emit(BookingUpdateState());
      }
    }
    emit(BookingUpdateState());
  }

  Future<void> biddingCreateRequest(
      BiddingCreateRequestEvent event, Emitter<BookingState> emit) async {
    isLoading = true;
    final data = await serviceLocator<BookingUsecase>().createRequest(
        userData: event.userData,
        vehicleData: event.vehicleData,
        pickupAddressList: event.pickupAddressList,
        dropAddressList: event.dropAddressList,
        selectedTransportType: event.selectedTransportType,
        paidAt: event.paidAt,
        parcelType: event.parcelType,
        selectedPaymentType:
            event.cardToken.isNotEmpty ? 'card' : event.selectedPaymentType,
        cardToken: event.cardToken,
        scheduleDateTime: event.scheduleDateTime,
        isEtaRental: false,
        isBidRide: true,
        goodsTypeId: event.goodsTypeId,
        goodsQuantity:
            event.goodsQuantity.isEmpty ? 'Loose' : event.goodsQuantity,
        offeredRideFare: event.offeredRideFare,
        polyLine: event.polyLine,
        isPetAvailable: event.isPetAvailable,
        isLuggageAvailable: event.isLuggageAvailable,
        isAirport: ((event.pickupAddressList.first.isAirportLocation != null &&
                    event.pickupAddressList.first.isAirportLocation!) ||
                (event.dropAddressList.any((element) =>
                    (element.isAirportLocation != null &&
                        element.isAirportLocation!))))
            ? true
            : false,
        isParcel: (event.selectedTransportType == 'delivery') ? true : false,
        isOutstationRide: event.isOutstationRide,
        isRoundTrip: event.isRoundTrip,
        scheduleDateTimeForReturn: event.scheduleDateTimeForReturn,
        taxiInstruction: instructionsController.text);
    data.fold(
      (error) {
        isLoading = false;
        if (error.message == 'logout') {
          emit(LogoutState());
        } else {
          showToast(message: '${error.message}');
          emit(BiddingCreateRequestFailureState());
        }
      },
      (success) {
        isLoading = false;
        requestData = OnTripRequestData.fromJson(success["data"]);
        isBiddingDecreaseLimitReach = false;
        isBiddingIncreaseLimitReach = false;

        if (success['success'])  {
          FirebaseDatabase.instance
              .ref()
              .child('bid-meta/${requestData!.id}')
              .update({
            'user_id': userData!.id.toString(),
            'price': requestData!.offerredRideFare,
            'base_price': event.vehicleData.total.toString(),
            'g': GeoHasher().encode(double.parse(requestData!.pickLng),
                double.parse(requestData!.pickLat)),
            'user_name': userData!.name,
            'updated_at': ServerValue.timestamp,
            'user_img': userData!.profilePicture,
            'vehicle_type': requestData!.vehicleTypeId,
            'request_id': requestData!.id,
            'request_no': requestData!.requestNumber,
            'pick_address': requestData!.pickAddress,
            'drop_address': requestData!.dropAddress,
            'trip_stops': (event.dropAddressList.length > 1)
                ? jsonEncode(event.dropAddressList)
                : 'null',
            'goods': (requestData!.transportType != 'taxi' &&
                    requestData!.goodsType != '-')
                ? '${requestData!.goodsType} - ${requestData!.goodsTypeQuantity}'
                : 'null',
            'pick_lat': double.parse(requestData!.pickLat),
            'drop_lat': double.parse(requestData!.dropLat),
            'pick_lng': double.parse(requestData!.pickLng),
            'drop_lng': double.parse(requestData!.dropLng),
            'currency': userData!.currencySymbol,
            'is_out_station': event.isOutstationRide,
            'distance': event.isOutstationRide
                ? userData!.distanceUnit == 'mi'
                    ? ((double.parse(requestData!.totalDistance) * 1.60934) *
                            1000)
                        .toString()
                    : (double.parse(requestData!.totalDistance) * 1000).toString()
                : isMultiTypeVechiles
                    ? sortedEtaDetailsList[selectedVehicleIndex].distance
                    : etaDetailsList[selectedVehicleIndex].distance.toString(),
            'is_pet_available': event.isPetAvailable,
            'is_luggage_available': event.isLuggageAvailable,
            'completed_ride_count': userData!.completedRideCount,
            'ratings': userData!.rating,
            'trip_type': event.isOutstationRide
                ? event.isRoundTrip
                    ? 'Round Trip'
                    : 'One Way Trip'
                : 'Bidding',
            'start_date': requestData!.tripStartTime,
            'return_date': requestData!.returnTime,
            'polyline': requestData!.polyLine,
            'duration': requestData!.totalTime.toString(),
            'transport_type': event.selectedTransportType,
            'taxi_instruction': instructionsController.text,
            'pick_poc_instruction': requestData!.pickupPocInstruction,
          });
          if (event.scheduleDateTime.isEmpty) {
            isTripStart = true;
            nearByVechileSubscription?.cancel();
            etaDurationStream?.cancel();
            isBiddingRideSearching = true;
            isNormalRideSearching = false;
            biddingStreamRequest();
            isBiddingDecreaseLimitReach = true;
            if (mapType == 'google_map') {
              if (googleMapController != null) {
                googleMapController!
                    .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                  target: LatLng(event.pickupAddressList.first.lat,
                      event.pickupAddressList.first.lng),
                  zoom: 17.0,
                )));
              }
            } else {
              if (fmController != null) {
                fmController!.move(
                    fmlt.LatLng(event.pickupAddressList.first.lat,
                        event.pickupAddressList.first.lng),
                    13);
              }
            }
            emit(BiddingCreateRequestSuccessState());
          } else {
            emit(BookingLaterCreateRequestSuccessState(
                isOutstation: event.isOutstationRide));
          }
        }else{
          showToast(message: '${success['message']}');
          emit(BiddingCreateRequestFailureState());
        }
      },
    );
  }

  Future<void> biddingFareUpdate(
      BiddingFareUpdateEvent event, Emitter<BookingState> emit) async {
    isLoading = true;
    await FirebaseDatabase.instance
        .ref()
        .child('bid-meta/${requestData!.id}')
        .update({
      'price': farePriceController.text,
      'updated_at': ServerValue.timestamp,
    });
    await FirebaseDatabase.instance
        .ref()
        .child('bid-meta/${requestData!.id}/drivers')
        .remove();
    isLoading = false;
    emit(BiddingFareUpdateState());
  }

  //biddingStream
  biddingStreamRequest() {
    if (biddingRequestStream != null) {
      biddingRequestStream?.cancel();
    }
    biddingRequestStream = FirebaseDatabase.instance
        .ref()
        .child('bid-meta/${requestData!.id}')
        .onValue
        .handleError((onError) {
      biddingRequestStream?.cancel();
    }).listen(
      (DatabaseEvent event) {
        debugPrint("BIDDING STREAM");
        Map rideList = {};
        DataSnapshot snapshots = event.snapshot;
        if (snapshots.value != null) {
          rideList = jsonDecode(jsonEncode(snapshots.value));
          if (rideList['request_id'] != null) {
            if (rideList['drivers'] != null) {
              biddingDriverList.clear();
              Map driver = rideList['drivers'];
              driver.forEach((key, value) {
                if (driver[key]['is_rejected'] == 'none') {
                  biddingDriverList.add(value);
                  if (biddingDriverList.isNotEmpty) {
                    audioPlayers.play(AssetSource(AppAudio.notification));
                  }
                }
                biddingTimerEvent(
                    duration: int.parse(
                            userData!.maximumTimeForFindDriversForBittingRide) +
                        5);
              });
            }
          } else {
            if (requestData != null && requestData!.isOutStation == '0') {
              add(BookingCancelRequestEvent(requestId: requestData!.id));
            }
          }
        }
        add(UpdateEvent());
      },
    );
  }

  biddingTimerEvent({required int duration}) async {
    int count = duration;

    biddingRideTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      count--;
      if (count <= 0) {
        biddingRideTimer?.cancel();
      }
      add(UpdateEvent());
    });
  }

  Future<void> biddingAcceptOrDecline(
      BiddingAcceptOrDeclineEvent event, Emitter<BookingState> emit) async {
    if (event.isAccept) {
      final data = await serviceLocator<BookingUsecase>().biddingAccept(
          requestId: (requestData != null)
              ? requestData!.id
              : (event.id != null)
                  ? event.id!
                  : '',
          driverId: event.driver['driver_id'].toString(),
          acceptRideFare: event.driver['price'].toString(),
          offeredRideFare: farePriceController.text);
      data.fold(
        (error) {
          isLoading = false;
          if (error.message == 'logout') {
            emit(LogoutState());
          } else {
            showToast(message: '${error.message}');
            emit(BiddingCreateRequestFailureState());
          }
        },
        (success) async {
          if (requestData != null) {
            await FirebaseDatabase.instance
                .ref()
                .child('bid-meta/${requestData!.id}')
                .remove();
            driverStreamRide(driverId: event.driver["driver_id"]);
            biddingDriverList.removeWhere(
                (element) => element["driver_id"] == event.driver["driver_id"]);
            add(BookingGetUserDetailsEvent(requestId: requestData!.id));
          }
          add(UpdateEvent());
        },
      );
    } else {
      await FirebaseDatabase.instance
          .ref()
          .child(
              'bid-meta/${requestData!.id}/drivers/driver_${event.driver["driver_id"]}')
          .update({"is_rejected": 'by_user'});
      if (biddingDriverList.isNotEmpty) {
        biddingDriverList.removeWhere(
            (element) => element["driver_id"] == event.driver["driver_id"]);
        emit(BookingUpdateState());
      }
      emit(BookingUpdateState());
    }
  }

  Future<void> getCancelReasons(
      CancelReasonsEvent event, Emitter<BookingState> emit) async {
    final data = await serviceLocator<BookingUsecase>().cancelReasons(
        beforeOrAfter: event.beforeOrAfter, requestId: requestData!.id);
    data.fold(
      (error) {
        if (error.message == 'logout') {
          emit(LogoutState());
        } else {
          showToast(message: '${error.message}');
          emit(BookingUpdateState());
        }
      },
      (success) {
        cancelReasonsList = success.data;
        emit(CancelReasonState());
      },
    );
  }

  FutureOr<void> getPolyline(
      PolylineEvent event, Emitter<BookingState> emit) async {
    final data = await serviceLocator<BookingUsecase>().getPolyline(
      pickLat: event.pickLat,
      pickLng: event.pickLng,
      dropLat: event.dropLat,
      dropLng: event.dropLng,
      stops: event.stops,
      isOpenStreet: mapType == 'open_street_map',
    );
    data.fold(
      (error) {
        debugPrint(error.toString());
        showToast(message: error.message ?? '');
        emit(BookingUpdateState());
      },
      (success) async {
        distance = success.distance;
        if (success.duration.contains('.')) {
          duration = double.parse(success.duration).toStringAsFixed(1);
        } else {
          duration = success.duration;
        }
        polyLine = success.polyString;
        if (event.isInitCall != null &&
            event.isInitCall! &&
            event.arg != null) {
            add(BookingEtaRequestEvent(
                picklat: event.arg!.picklat,
                picklng: event.arg!.picklng,
                droplat: event.arg!.droplat,
                droplng: event.arg!.droplng,
                ridetype: 1,
                transporttype: transportType,
                distance: distance,
                duration: duration,
                polyLine: polyLine,
                pickupAddressList: event.arg!.pickupAddressList,
                dropAddressList: event.arg!.stopAddressList,
                isOutstationRide: event.arg!.isOutstationRide,
                isWithoutDestinationRide:
                    event.arg!.isWithoutDestinationRide ?? false));
          
        }
          if (event.icon != null) {
            driverPosition = LatLng(event.pickLat, event.pickLng);
          }
          if (event.isDriverStream != null && event.isDriverStream!) {
            markerList.clear();
          }
          if (event.arg != null &&
              ((event.arg!.isWithoutDestinationRide != null &&
                      !event.arg!.isWithoutDestinationRide!) ||
                  (event.arg!.isWithoutDestinationRide == null)) &&
              ((event.arg!.isRentalRide != null && !event.arg!.isRentalRide!) ||
                  event.arg!.isRentalRide == null)) {
            await addDistanceMarker(LatLng(event.dropLat, event.dropLng),
                double.tryParse(distance)!,
                time: double.parse(duration));
          }
          markerList.add(Marker(
            markerId: event.markerId != null
                ? MarkerId(event.markerId!)
                : const MarkerId("pick"),
            position: LatLng(event.pickLat, event.pickLng),
            rotation: 0.0,
            icon: event.icon ??
                await MarkerWidget(
                  isPickup: true,
                  text: event.pickAddress,
                ).toBitmapDescriptor(
                    logicalSize: const Size(30, 30),
                    imageSize: const Size(200, 200)),
          ));
          if (userData != null &&
              event.stops.isEmpty &&
              ((userData!.metaRequest != null && userData!.metaRequest != "") ||
                  (userData!.onTripRequest != null &&
                      userData!.onTripRequest != ""))) {
            if (event.arg != null &&
                ((event.arg!.isWithoutDestinationRide != null &&
                        !event.arg!.isWithoutDestinationRide!) ||
                    (event.arg!.isWithoutDestinationRide == null)) &&
                ((event.arg!.isRentalRide != null &&
                        !event.arg!.isRentalRide!) ||
                    event.arg!.isRentalRide == null)) {
              await addDistanceMarker(LatLng(event.dropLat, event.dropLng),
                  double.tryParse(distance)!,
                  time: double.parse(duration));
            }
            markerList.add(Marker(
              markerId: const MarkerId("drop"),
              position: LatLng(event.dropLat, event.dropLng),
              rotation: 0.0,
              icon: await MarkerWidget(
                isPickup:
                    (event.isDriverToPick != null && event.isDriverToPick!)
                        ? true
                        : false,
                text: event.dropAddress,
              ).toBitmapDescriptor(
                  logicalSize: const Size(30, 30),
                  imageSize: const Size(200, 200)),
            ));
          } else if (event.stops.isNotEmpty) {
            for (var i = 0; i < event.stops.length; i++) {
              markerList.add(Marker(
                markerId: MarkerId("drop$i"),
                position: LatLng(event.stops[i].lat, event.stops[i].lng),
                rotation: 0.0,
                icon: await MarkerWidget(
                  isPickup: false,
                  count: '${i + 1}',
                  text: event.stops[i].address,
                ).toBitmapDescriptor(
                    logicalSize: const Size(30, 30),
                    imageSize: const Size(200, 200)),
              ));
            }
          } else {
            if (event.arg != null &&
                ((event.arg!.isWithoutDestinationRide != null &&
                        !event.arg!.isWithoutDestinationRide!) ||
                    (event.arg!.isWithoutDestinationRide == null)) &&
                ((event.arg!.isRentalRide != null &&
                        !event.arg!.isRentalRide!) ||
                    event.arg!.isRentalRide == null)) {
              await addDistanceMarker(LatLng(event.dropLat, event.dropLng),
                  double.tryParse(distance)!,
                  time: double.parse(duration));
            }
            markerList.add(Marker(
              markerId: const MarkerId("drop"),
              position: LatLng(event.dropLat, event.dropLng),
              rotation: 0.0,
              icon: await MarkerWidget(
                isPickup:
                    (event.isDriverToPick != null && event.isDriverToPick!)
                        ? true
                        : false,
                text: event.dropAddress,
              ).toBitmapDescriptor(
                  logicalSize: const Size(30, 30),
                  imageSize: const Size(200, 200)),
            ));
          }
          if (event.isDropChanged != null && event.isDropChanged!) {
            await addDistanceMarker(LatLng(event.dropLat, event.dropLng),
                double.tryParse(distance)!,
                time: double.parse(duration));
          }
          mapBound(event.pickLat, event.pickLng, event.dropLat, event.dropLng,
              isInitCall: event.isInitCall);
          decodeEncodedPolyline(success.polyString,
              isDriverStream: event.isDriverStream);
        
      },
    );
    emit(BookingUpdateState());
  }

  mapBound(double pickLat, double pickLng, double dropLat, double dropLng,
      {bool? isInitCall, bool? isRentalRide}) {
    dynamic pick = LatLng(pickLat, pickLng);
    dynamic drop = LatLng(dropLat, dropLng);
    if (pick.latitude > drop.latitude && pick.longitude > drop.longitude) {
      bound = LatLngBounds(southwest: drop, northeast: pick);
    } else if (pick.longitude > drop.longitude) {
      bound = LatLngBounds(
          southwest: LatLng(pick.latitude, drop.longitude),
          northeast: LatLng(drop.latitude, pick.longitude));
    } else if (pick.latitude > drop.latitude) {
      bound = LatLngBounds(
          southwest: LatLng(drop.latitude, pick.longitude),
          northeast: LatLng(pick.latitude, drop.longitude));
    } else {
      bound = LatLngBounds(southwest: pick, northeast: drop);
    }

    if (isInitCall != null && isInitCall) {
      var dist = calculateDistance(
        lat1: pickLat,
        lon1: pickLng,
        lat2: dropLat,
        lon2: dropLng,
      );

      // Adjust the southwest point to move the bounds up
      if (dist > 3) {
        double adjustmentFactor = 0.096; // Adjust as needed
        double adjustmentFactor1 = 0.005;
        double newSouthwestLat = bound!.southwest.latitude - adjustmentFactor;
        double newNorthEastLat = bound!.northeast.latitude + adjustmentFactor1;

        // Create new bounds with the adjusted southwest point
        bound = LatLngBounds(
          southwest: LatLng(newSouthwestLat, bound!.southwest.longitude),
          northeast: LatLng(newNorthEastLat, bound!.northeast.longitude),
          // northeast: bound!.northeast,
        );
      } else {
        double adjustmentFactor = 0.046; // Adjust as needed
        double adjustmentFactor1 = 0.005;
        double newSouthwestLat = bound!.southwest.latitude - adjustmentFactor;
        double newNorthEastLat = bound!.northeast.latitude + adjustmentFactor1;

        // Create new bounds with the adjusted southwest point
        bound = LatLngBounds(
          southwest: LatLng(newSouthwestLat, bound!.southwest.longitude),
          northeast: LatLng(newNorthEastLat, bound!.northeast.longitude),
          // northeast: bound!.northeast,
        );
      }
    } else if (isRentalRide != null && isRentalRide) {
      double adjustmentFactor = 0.106; // Adjust as needed
      double adjustmentFactor1 = 0.030;
      double newSouthwestLat = bound!.southwest.latitude - adjustmentFactor;
      double newNorthEastLat = bound!.northeast.latitude + adjustmentFactor1;

      // Create new bounds with the adjusted southwest point
      bound = LatLngBounds(
        southwest: LatLng(newSouthwestLat, bound!.southwest.longitude),
        northeast: LatLng(newNorthEastLat, bound!.northeast.longitude),
        // northeast: bound!.northeast,
      );
    }
  }

  List<LatLng> polylist = [];
  Future<List<PointLatLng>> decodeEncodedPolyline(String encoded,
      {bool? isDriverStream}) async {
    polylist.clear();
    List<PointLatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    polylines.clear();
    fmpoly.clear();

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      polylist.add(p);
      fmpoly.add(
        fmlt.LatLng(p.latitude, p.longitude),
      );
    }

    polylines.add(
      Polyline(
          polylineId: const PolylineId('1'),
          color: AppColors.blue,
          visible: true,
          width: 4,
          points: polylist),
    );

    // // Optionally, zoom in a bit
    if (isDriverStream == null) {
      if (mapType == 'google_map') {
        googleMapController
            ?.animateCamera(CameraUpdate.newLatLngBounds(bound!, 100));
      } else {
        if (fmController != null) {
          fmController!.move(
              fmlt.LatLng(
                  bound!.northeast.latitude, bound!.northeast.longitude),
              13);
        }
      }
    }
    if (!isClosed) {
      add(UpdateEvent());
    }
    return poly;
  }

  FutureOr<void> chatWithDriver(
      ChatWithDriverEvent event, Emitter<BookingState> emit) async {
    add(GetChatHistoryEvent(requestId: event.requestId));
    emit(ChatWithDriverState());
  }

  FutureOr<void> getChatHistory(
      GetChatHistoryEvent event, Emitter<BookingState> emit) async {
    final data = await serviceLocator<BookingUsecase>()
        .getChatHistory(requestId: event.requestId);
    data.fold((error) {
      debugPrint(error.toString());
      if (error.message == 'logout') {
        emit(LogoutState());
      } else {
        emit(BookingUpdateState());
      }
    }, (success) {
      chatHistoryList = success.data;
      if (chatHistoryList.isNotEmpty) {
        add(SeenChatMessageEvent(requestId: event.requestId));
      }
      emit(BookingUpdateState());
    });
  }

  FutureOr<void> sendChatMessage(
      SendChatMessageEvent event, Emitter<BookingState> emit) async {
    final data = await serviceLocator<BookingUsecase>()
        .sendChatMessage(requestId: event.requestId, message: event.message);
    data.fold((error) {
      debugPrint(error.toString());
      if (error.message == 'logout') {
        emit(LogoutState());
      } else {
        emit(BookingUpdateState());
      }
    }, (success) {
      add(GetChatHistoryEvent(requestId: event.requestId));
      FirebaseDatabase.instance
          .ref('requests/${event.requestId}')
          .update({'message_by_user': chatHistoryList.length});
      emit(BookingUpdateState());
    });
  }

  FutureOr<void> seenChatMessage(
      SeenChatMessageEvent event, Emitter<BookingState> emit) async {
    final data = await serviceLocator<BookingUsecase>()
        .seenChatMessage(requestId: event.requestId);
    data.fold((error) {
      debugPrint(error.toString());
      if (error.message == 'logout') {
        emit(LogoutState());
      } else {
        emit(BookingUpdateState());
      }
    }, (success) {
      emit(BookingUpdateState());
    });
  }

  FutureOr<void> sosEvent(SOSEvent event, Emitter<BookingState> emit) async {
    emit(SosState());
  }

  FutureOr<void> notifyAdmin(
      NotifyAdminEvent event, Emitter<BookingState> emit) async {
    await FirebaseDatabase.instance
        .ref()
        .child('SOS/${event.requestId}')
        .update({
      "is_driver": "0",
      "is_user": "1",
      "req_id": event.requestId,
      "serv_loc_id": event.serviceLocId,
      "updated_at": ServerValue.timestamp
    });
    emit(BookingUpdateState());
  }

  @override
  Future<void> close() {
    // Dispose the DraggableScrollableController when the bloc is closed
    _draggableScrollableController.dispose();
    if (animationController != null) {
      animationController?.dispose();
    }
    if (animationController1 != null) {
      animationController1?.dispose();
    }
    if (requestStreamStart != null) {
      requestStreamStart?.cancel();
    }
    if (biddingRequestStream != null) {
      biddingRequestStream?.cancel();
    }
    if (driverDataStream != null) {
      driverDataStream?.cancel();
    }

    if (etaDurationStream != null) {
      etaDurationStream?.cancel();
    }
    if (nearByVechileSubscription != null) {
      nearByVechileSubscription?.cancel();
    }

    return super.close();
  }

  // ===========================VECHILE MARKER ADD======================================>

  nearByVechileCheckStream(
      BuildContext context, dynamic vsync, LatLng currentLatLng) async {
    GeoHasher geo = GeoHasher();
    double lat = 0.0144927536231884;
    double lon = 0.0181818181818182;
    double lowerLat = 0.0;
    double lowerLon = 0.0;
    double greaterLat = 0.0;
    double greaterLon = 0.0;
    lowerLat = currentLatLng.latitude - (lat * 1.24);
    lowerLon = currentLatLng.longitude - (lon * 1.24);

    greaterLat = currentLatLng.latitude + (lat * 1.24);
    greaterLon = currentLatLng.longitude + (lon * 1.24);

    var lower = geo.encode(lowerLon, lowerLat);
    var higher = geo.encode(greaterLon, greaterLat);

    if (nearByVechileSubscription != null) {
      nearByVechileSubscription?.cancel();
    }
    nearByVechileSubscription = FirebaseDatabase.instance
        .ref('drivers')
        .orderByChild('g')
        .startAt(lower)
        .endAt(higher)
        .onValue
        .listen((onData) {
      debugPrint('Pickup NearBy Vechiles : ${onData.snapshot.children}');
      if (onData.snapshot.exists) {
        // List driverData = [];
        nearByDriversData.clear();
        for (var element in onData.snapshot.children) {
          nearByDriversData.add(element.value);
        }
        checkNearByEta(nearByDriversData, vsync);
      }
      // context.read<BookingBloc>().add(UpdateEvent());
    });
  }

  Future<void> checkNearByEta(List<dynamic> driverData, vsync) async {
    final BitmapDescriptor bikeMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.bike);

    final BitmapDescriptor carMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.car);

    final BitmapDescriptor autoMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.auto);

    final BitmapDescriptor truckMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.truck);

    final BitmapDescriptor ehcv = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.ehcv);

    final BitmapDescriptor hatchBack = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.hatchBack);

    final BitmapDescriptor hcv = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.hcv);

    final BitmapDescriptor lcv = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.lcv);

    final BitmapDescriptor mcv = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.mcv);

    final BitmapDescriptor luxury = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.luxury);

    final BitmapDescriptor premium = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.premium);

    final BitmapDescriptor suv = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.suv);

    List etaList = !isRentalRide
        ? isMultiTypeVechiles
            ? sortedEtaDetailsList
            : etaDetailsList
        : rentalEtaDetailsList;
    String choosenEtaTypeId =
        etaList.isNotEmpty ? etaList[selectedVehicleIndex].typeId : '';
    for (var element in driverData) {
      if (element['is_active'] == 1 &&
          element['is_available'] == true &&
          ((element['vehicle_types'] != null &&
                  element['vehicle_types'].contains(choosenEtaTypeId)) ||
              (element['vehicle_type'] != null &&
                  element['vehicle_type'] == choosenEtaTypeId))) {
        if (((transportType == 'taxi' && element['transport_type'] == 'taxi') ||
                (transportType == 'delivery' &&
                    element['transport_type'] == 'delivery') ||
                element['transport_type'] == 'bidding' ||
                element['transport_type'] == 'both')
            // || (transportType == 'delivery' &&  element['transport_type'] == 'both')
            ) {
          DateTime dt =
              DateTime.fromMillisecondsSinceEpoch(element['updated_at']);

          if (DateTime.now().difference(dt).inMinutes <= 2) {
            if (markerList
                .where((e) => e.markerId.toString().contains(
                    'marker#${element['id']}#${element['vehicle_type_icon']}'))
                .isEmpty) {
              markerList.add(Marker(
                markerId: MarkerId(
                    'marker#${element['id']}#${element['vehicle_type_icon']}'),
                rotation: (myBearings[element['id'].toString()] != null)
                    ? myBearings[element['id'].toString()]
                    : 0.0,
                position: LatLng(element['l'][0], element['l'][1]),
                icon: (element['vehicle_type_icon'] == 'truck')
                    ? truckMarker
                    : (element['vehicle_type_icon'] == 'motor_bike')
                        ? bikeMarker
                        : (element['vehicle_type_icon'] == 'auto')
                            ? autoMarker
                            : (element['vehicle_type_icon'] == 'lcv')
                                ? lcv
                                : (element['vehicle_type_icon'] == 'ehcv')
                                    ? ehcv
                                    : (element['vehicle_type_icon'] ==
                                            'hatchback')
                                        ? hatchBack
                                        : (element['vehicle_type_icon'] ==
                                                'hcv')
                                            ? hcv
                                            : (element['vehicle_type_icon'] ==
                                                    'mcv')
                                                ? mcv
                                                : (element['vehicle_type_icon'] ==
                                                        'luxury')
                                                    ? luxury
                                                    : (element['vehicle_type_icon'] ==
                                                            'premium')
                                                        ? premium
                                                        : (element['vehicle_type_icon'] ==
                                                                'suv')
                                                            ? suv
                                                            : carMarker,
              ));
            } else {
              if (markerList
                          .lastWhere((e) => e.markerId.toString().contains(
                              'marker#${element['id']}#${element['vehicle_type_icon']}'))
                          .position
                          .latitude !=
                      element['l'][0] ||
                  markerList
                          .lastWhere((e) => e.markerId.toString().contains(
                              'marker#${element['id']}#${element['vehicle_type_icon']}'))
                          .position
                          .longitude !=
                      element['l'][1]) {
                var dist = calculateDistance(
                  lat1: markerList
                      .lastWhere((e) => e.markerId.toString().contains(
                          'marker#${element['id']}#${element['vehicle_type_icon']}'))
                      .position
                      .latitude,
                  lon1: markerList
                      .lastWhere((e) => e.markerId.toString().contains(
                          'marker#${element['id']}#${element['vehicle_type_icon']}'))
                      .position
                      .longitude,
                  lat2: double.parse(element['l'][0].toString()),
                  lon2: double.parse(element['l'][1].toString()),
                  unit: userData?.distanceUnit ?? 'km',
                );
                if (dist > 100) {
                  animationController1 = AnimationController(
                    duration: const Duration(
                        milliseconds: 1500), //Animation duration of marker
                    vsync: vsync, //From the widget
                  );
                  animateCar(
                      markerList
                          .lastWhere((e) => e.markerId.toString().contains(
                              'marker#${element['id']}#${element['vehicle_type_icon']}'))
                          .position
                          .latitude,
                      markerList
                          .lastWhere((e) => e.markerId.toString().contains(
                              'marker#${element['id']}#${element['vehicle_type_icon']}'))
                          .position
                          .longitude,
                      double.parse(element['l'][0].toString()),
                      double.parse(element['l'][1].toString()),
                      // _mapMarkerSink,
                      vsync,
                      (mapType == 'google_map')
                          ? googleMapController!
                          : fmController!,
                      'marker#${element['id']}#${element['vehicle_type_icon']}',
                      (element['vehicle_type_icon'] == 'truck')
                          ? truckMarker
                          : (element['vehicle_type_icon'] == 'motor_bike')
                              ? bikeMarker
                              : (element['vehicle_type_icon'] == 'auto')
                                  ? autoMarker
                                  : (element['vehicle_type_icon'] == 'lcv')
                                      ? lcv
                                      : (element['vehicle_type_icon'] == 'ehcv')
                                          ? ehcv
                                          : (element['vehicle_type_icon'] ==
                                                  'hatchback')
                                              ? hatchBack
                                              : (element['vehicle_type_icon'] ==
                                                      'hcv')
                                                  ? hcv
                                                  : (element['vehicle_type_icon'] ==
                                                          'mcv')
                                                      ? mcv
                                                      : (element['vehicle_type_icon'] ==
                                                              'luxury')
                                                          ? luxury
                                                          : (element['vehicle_type_icon'] ==
                                                                  'premium')
                                                              ? premium
                                                              : (element['vehicle_type_icon'] ==
                                                                      'suv')
                                                                  ? suv
                                                                  : carMarker,
                      mapType);
                }
              }
            }
          }
        }
      } else {
        if (markerList
            .where((e) => e.markerId.toString().contains(
                'marker#${element['id']}#${element['vehicle_type_icon']}'))
            .isNotEmpty) {
          markerList.removeWhere((e) => e.markerId.toString().contains(
              'marker#${element['id']}#${element['vehicle_type_icon']}'));
        }
      }
    }
    // add(UpdateEvent());
  }

  // =======================================================================================>

  double getBearing(LatLng begin, LatLng end) {
    double lat = (begin.latitude - end.latitude).abs();

    double lng = (begin.longitude - end.longitude).abs();

    if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
      return vector.degrees(math.atan(lng / lat));
    } else if (begin.latitude >= end.latitude &&
        begin.longitude < end.longitude) {
      return (90 - vector.degrees(math.atan(lng / lat))) + 90;
    } else if (begin.latitude >= end.latitude &&
        begin.longitude >= end.longitude) {
      return vector.degrees(math.atan(lng / lat)) + 180;
    } else if (begin.latitude < end.latitude &&
        begin.longitude >= end.longitude) {
      return (90 - vector.degrees(math.atan(lng / lat))) + 270;
    }

    return -1;
  }

  animateCar(
      double fromLat, //Starting latitude

      double fromLong, //Starting longitude

      double toLat, //Ending latitude

      double toLong, //Ending longitude

      // StreamSink<List<Marker>>
      //     mapMarkerSink, //Stream build of map to update the UI

      TickerProvider
          provider, //Ticker provider of the widget. This is used for animation

      dynamic controller, //Google map controller of our widget

      markerid,
      icon,
      map) async {
    final double bearing =
        getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

    dynamic carMarker;
    carMarker = Marker(
        markerId: MarkerId(markerid.toString()),
        position: LatLng(fromLat, fromLong),
        icon: icon,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        draggable: false);

    Tween<double> tween = Tween(begin: 0, end: 1);

    _animation1 = tween.animate(animationController1!)
      ..addListener(() async {
        markerList.removeWhere((element) => element.markerId.value == markerid);

        final v = _animation1!.value;

        double lng = v * toLong + (1 - v) * fromLong;

        double lat = v * toLat + (1 - v) * fromLat;

        LatLng newPos = LatLng(lat, lng);

        //New marker location
        List<LatLng> polyList = polylines
            .firstWhere((e) => e.mapsId == const PolylineId('1'))
            .points;
        List polys = [];
        dynamic nearestLat;
        dynamic pol;
        for (var e in polyList) {
          var dist = calculateDistance(
            lat1: newPos.latitude,
            lon1: newPos.longitude,
            lat2: e.latitude,
            lon2: e.longitude,
            unit: userData?.distanceUnit ?? 'km',
          );
          if (pol == null) {
            polys.add(dist);
            pol = dist;
            nearestLat = e;
          } else {
            if (dist < pol) {
              polys.add(dist);
              pol = dist;
              nearestLat = e;
            }
          }
        }
        int currentNumber =
            polyList.indexWhere((element) => element == nearestLat);
        for (var i = 0; i < currentNumber; i++) {
          polyList.removeAt(0);
        }
        polylines.clear();
        polylines.add(
          Polyline(
              polylineId: const PolylineId('1'),
              color: AppColors.blue,
              visible: true,
              width: 4,
              points: polyList),
        );

        carMarker = Marker(
            markerId: MarkerId(markerid.toString()),
            position: newPos,
            icon: icon,
            rotation: bearing,
            anchor: const Offset(0.5, 0.5),
            flat: true,
            draggable: false);

        markerList.add(carMarker);
        if (!isClosed) {
          add(UpdateMarkersEvent(markers: markerList));
        }
      });

    //Starting the animation
    driverPosition = LatLng(toLat, toLong);
    await animationController1!.forward();
    if (userData != null &&
        userData!.onTripRequest != "" &&
        userData!.onTripRequest != null) {
      if (map == 'google_map') {
        controller.getVisibleRegion().then((value) {
          if (value.contains(markerList
                  .firstWhere(
                      (element) => element.markerId == MarkerId(markerid))
                  .position) ==
              false) {
            debugPrint('Animating correctly');
            controller.animateCamera(CameraUpdate.newLatLng(markerList
                .firstWhere((element) => element.markerId == MarkerId(markerid))
                .position));
          } else {
            debugPrint('Animating wrongly');
          }
        });
      } else {
        final latLng = markerList
            .firstWhere((element) => element.markerId == MarkerId(markerid))
            .position;
        controller!.move(
            fmlt.LatLng(double.parse(latLng.latitude.toString()),
                double.parse(latLng.longitude.toString())),
            13.0);
      }
    }

    animationController1 = null;
  }

  Future<void> enableEtaScrollingList(
      UpdateScrollPhysicsEvent event, Emitter<BookingState> emit) async {
    enableEtaScrolling = event.enableEtaScrolling;
    emit(BookingScrollPhysicsUpdated(enableEtaScrolling: enableEtaScrolling));
  }

  double snapToPosition(double currentSize, double minSize, double maxSize) {
    if (currentSize >= (minSize + maxSize) / 2) {
      return maxSize;
    } else {
      return minSize;
    }
  }

  void updateScrollHeight(double height) {
    scrollHeight = height;
    enableEtaScrolling = scrollHeight >= maxChildSize;
    add(UpdateScrollPhysicsEvent(enableEtaScrolling: enableEtaScrolling));
  }

  void scrollToMinChildSize(double targetMinChildSize) {
    currentSize = maxChildSize;
  }

  void scrollToBottomFunction(int length) {
    if (length == 1) {
      currentSize = minChildSize;
    } else if (length == 2) {
      currentSizeTwo = minChildSizeTwo;
    } else {
      currentSizeThree = minChildSizeThree;
    }
  }

  Future<void> enableDetailsViewFunction(
      DetailViewUpdateEvent event, Emitter<BookingState> emit) async {
    detailView = event.detailView;
    emit(DetailViewUpdateState(detailView));
  }

  FutureOr<void> walletPageReUpdate(
      WalletPageReUpdateEvents event, Emitter<BookingState> emit) async {
    emit(WalletPageReUpdateStates(
        currencySymbol: event.currencySymbol,
        money: event.money,
        requestId: event.requestId,
        url: event.url,
        userId: event.userId));
  }

  FutureOr<void> invoiceInit(
      InvoiceInitEvent event, Emitter<BookingState> emit) async {
    requestData = event.arg.requestData;
    driverData = event.arg.driverData;
    requestBillData = event.arg.requestBillData;
    if (requestData!.enableDriverTipsFeature == '1' &&
        requestBillData!.driverTips == '0') {
      selectedPaymentType = requestData!.paymentTypeString;
      printWrapped("Getting payment type:$selectedPaymentType");
      emit(ShowAddTipState(isDriverReceivedPayment: isDriverReceivedPayment));
    } else {
      emit(BookingUpdateState());
    }
    streamRide();
  }

  FutureOr<void> showAddTip(
      ShowAddTipEvent event, Emitter<BookingState> emit) async {}

  FutureOr<void> addTipEvent(
      AddTipsEvent event, Emitter<BookingState> emit) async {
    final data = await serviceLocator<BookingUsecase>()
        .addTips(requestId: event.requestId, amount: event.amount);
    data.fold(
      (error) {
        debugPrint(error.toString());
        if (error.message == 'logout') {
          emit(LogoutState());
        }
      },
      (success) {
        if (success['success']) {
          requestBillData = RequestBillData.fromJson(success['data']);
          FirebaseDatabase.instance
              .ref('requests/${event.requestId}')
              .update({'driver_tips': event.amount});
        }
        emit(TipsAddedState(requestBillData: requestBillData!));
      },
    );
  }

  Future addDistanceMarker(LatLng position, double distanceMeter,
      {double? time}) async {
    markerList.removeWhere(
        (element) => element.markerId == const MarkerId('distance'));
    double duration;
    String totalDistance;
    String unitLabel;

    bool isMiles = userData?.distanceUnit == 'mi';

    double convertedDistance =
        isMiles ? ((distanceMeter / 1000) * 0.621371) : (distanceMeter / 1000);

    unitLabel = isMiles ? 'MI' : 'KM';

    if (convertedDistance < 0.5) {
      totalDistance = '0.5';
      duration = 1;
      fmDistance = '0.5';
      fmDuration = 1;
      add(UpdateEvent());
    } else {
      totalDistance = convertedDistance.toStringAsFixed(1);
      duration = (time != null)
          ? (time > 0 ? time : 2)
          : (convertedDistance * 1.5).roundToDouble();
      fmDistance = convertedDistance.toStringAsFixed(1);
      fmDuration = (time != null)
          ? (time > 0 ? time : 2)
          : (convertedDistance * 1.5).roundToDouble();
      add(UpdateEvent());
    }
    // if (time != null) {
    //   if (time > 0) {
    //     duration = time;
    //   } else {
    //     duration = 2;
    //   }
    // } else {
    //   if ((distanceMeter / 1000) > 0) {
    //     duration = ((distanceMeter / 1000) * 1.5).roundToDouble();
    //   } else {
    //     duration = 2;
    //   }
    // }

    // if ((distanceMeter / 1000).toStringAsFixed(0) == '0') {
    //   totalDistance = '0.5';
    //   duration = 1;
    // } else {
    //   totalDistance = (distanceMeter / 1000).toStringAsFixed(0);
    // }

    markerList.add(Marker(
      anchor: const Offset(0.5, 0.0),
      markerId: const MarkerId("distance"),
      position: position,
      rotation: 0.0,
      icon: await Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            height: 40,
            width: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: AppColors.primary, width: 1)),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5)),
                      color: AppColors.primary),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        text: totalDistance,
                        textStyle: AppTextStyle.normalStyle().copyWith(
                            color: ThemeData.light().scaffoldBackgroundColor,
                            fontSize: 12),
                      ),
                      MyText(
                        text: unitLabel,
                        textStyle: AppTextStyle.normalStyle().copyWith(
                            color: ThemeData.light().scaffoldBackgroundColor,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5)),
                        color: ThemeData.light().scaffoldBackgroundColor),
                    child: MyText(
                      text: ((duration) > 60)
                          ? '${(duration / 60).toStringAsFixed(1)} hrs'
                          : '${duration.toStringAsFixed(0)} mins',
                      textStyle: AppTextStyle.normalStyle()
                          .copyWith(color: AppColors.primary, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          )).toBitmapDescriptor(
        logicalSize: const Size(100, 30),
        imageSize: const Size(100, 30),
      ),
    ));
    if (!isClosed) {
      add(UpdateEvent());
    }
  }

  Future<void> changePaymentMethodListener(
      ChangePaymentMethodEvent event, Emitter<BookingState> emit) async {
    final data = await serviceLocator<BookingUsecase>().changePaymentMethod(
        requestId: event.requestData.id, paymentOption: event.paymentMethod);
    data.fold((error) {
      showToast(message: error.message.toString());
    }, (success) {
      FirebaseDatabase.instance
          .ref('requests/${event.requestData.id}')
          .update({'payment_method': event.paymentMethod});
    });
    emit(ChangePaymentState());
  }

  Future<void> locateMe(
      BookingLocateMeEvent event, Emitter<BookingState> emit) async {
    await Permission.location.request();
    PermissionStatus status = await Permission.location.status;
    if (status.isGranted || status.isLimited) {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        double lat = position.latitude;
        double long = position.longitude;
        final currentLatLng = LatLng(lat, long);
        AppConstants.currentLocations = LatLng(lat, long);
        if (event.mapType == 'google_map') {
          if (event.controller != null) {
            event.controller!
                .animateCamera(CameraUpdate.newLatLng(currentLatLng));
          }
        } else {
          if (event.controller != null) {
            event.controller!.move(fmlt.LatLng(lat, long), 15);
          }
        }
      }
    } else {
      showToast(
          message: 'allow location permission to get your current location');
    }
  }

  Future<void> editLocation(
      EditLocationEvent event, Emitter<BookingState> emit) async {
    List<AddressModel> addressList = [];

    if (event.requestData != null &&
        event.requestData!.requestStops != null &&
        event.requestData!.requestStops.data.isNotEmpty) {
      for (var i = 0; i < event.requestData!.requestStops.data.length; i++) {
        addressList.add(AddressModel(
            orderId: '${i + 1}',
            address: event.requestData!.requestStops.data[i].address,
            lat: event.requestData!.requestStops.data[i].latitude,
            lng: event.requestData!.requestStops.data[i].longitude,
            name: event.requestData!.requestStops.data[i].pocName,
            number: event.requestData!.requestStops.data[i].pocMobile,
            instructions:
                event.requestData!.requestStops.data[i].pocInstruction,
            pickup: false));
      }
    } else if (event.requestData != null &&
        event.requestData!.dropAddress.isNotEmpty) {
      addressList.add(AddressModel(
          orderId: '2',
          address: event.requestData!.dropAddress,
          lat: double.parse(event.requestData!.dropLat),
          lng: double.parse(event.requestData!.dropLng),
          name: event.requestData!.dropPocName,
          number: event.requestData!.dropPocMobile,
          instructions: event.requestData!.dropPocInstruction,
          pickup: false));
    }

    if (event.requestData != null) {
      emit(EditLocationState(
          requestData: event.requestData!, addressList: addressList));
    }
  }

  Future editLocationInit(
      EditLocationPageInitEvent event, Emitter<BookingState> emit) async {
    dropAddressList = event.arg.addressList;
    requestData = event.arg.requestData;
    mapType = event.arg.mapType;
    polyLine = event.arg.requestData.polyLine;
    distance = event.arg.requestData.unit == 'MILES'
        ? ((double.parse(event.arg.requestData.totalDistance) * 1.60934) * 1000)
            .toString()
        : (double.parse(event.arg.requestData.totalDistance) * 1000).toString();
    duration = event.arg.requestData.totalTime;
    for (var i = 0; i < dropAddressList.length; i++) {
      addressTextControllerList
          .add(TextEditingController(text: dropAddressList[i].address));
    }
    markerList.add(Marker(
      markerId: const MarkerId("pick"),
      position: LatLng(double.parse(event.arg.requestData.pickLat),
          double.parse(event.arg.requestData.pickLng)),
      rotation: 0.0,
      icon: await MarkerWidget(
        isPickup: true,
        text: event.arg.requestData.pickAddress,
      ).toBitmapDescriptor(
          logicalSize: const Size(30, 30), imageSize: const Size(200, 200)),
    ));
    mapBound(
        double.parse(event.arg.requestData.pickLat),
        double.parse(event.arg.requestData.pickLng),
        double.parse(event.arg.requestData.dropLat),
        double.parse(event.arg.requestData.dropLng),
        isRentalRide: true);
    if (event.arg.addressList.length > 1) {
      for (var i = 0; i < event.arg.addressList.length; i++) {
        markerList.add(Marker(
          markerId: MarkerId("drop$i"),
          position: LatLng(
              event.arg.addressList[i].lat, event.arg.addressList[i].lng),
          rotation: 0.0,
          icon: await MarkerWidget(
            isPickup: false,
            count: '${i + 1}',
            text: event.arg.addressList[i].address,
          ).toBitmapDescriptor(
              logicalSize: const Size(30, 30), imageSize: const Size(200, 200)),
        ));
      }
    } else {
      markerList.add(Marker(
        markerId: const MarkerId("drop"),
        position: LatLng(double.parse(event.arg.requestData.dropLat),
            double.parse(event.arg.requestData.dropLng)),
        rotation: 0.0,
        icon: await MarkerWidget(
          isPickup: false,
          text: event.arg.requestData.dropAddress,
        ).toBitmapDescriptor(
            logicalSize: const Size(30, 30), imageSize: const Size(200, 200)),
      ));
    }

    await addDistanceMarker(
        LatLng(double.parse(event.arg.requestData.dropLat),
            double.parse(event.arg.requestData.dropLng)),
        (double.tryParse(distance)!),
        time: double.parse(duration));
    await decodeEncodedPolyline(polyLine);
    emit(BookingUpdateState());
  }

  Future<void> reOrderAddress(
      ReorderEvent event, Emitter<BookingState> emit) async {
    if (event.oldIndex < event.newIndex) {
      event.newIndex -= 1;
    }
    final item = dropAddressList.removeAt(event.oldIndex);
    final itemController = addressTextControllerList.removeAt(event.oldIndex);
    dropAddressList.insert(event.newIndex, item);
    addressTextControllerList.insert(event.newIndex, itemController);
    add(UpdateEvent());
  }

  Future<void> addNewAddressStop(
      AddStopEvent event, Emitter<BookingState> emit) async {
    dropAddressList.add(AddressModel(
        orderId: '',
        address: '',
        lat: 0,
        lng: 0,
        name: '',
        number: '',
        pickup: false));
    addressTextControllerList.add(TextEditingController(text: ''));
    emit(BookingUpdateState());
  }

  Future<void> selectFromMap(
      SelectFromMapEvent event, Emitter<BookingState> emit) async {
    emit(SelectFromMapState());
  }

  FutureOr<void> addOrEditStopAddress(BookingAddOrEditStopAddressEvent event,
      Emitter<BookingState> emit) async {
    addressTextControllerList[event.choosenAddressIndex].text =
        event.newAddress.address;
    dropAddressList[event.choosenAddressIndex] = event.newAddress;
    if (requestData != null) {
      add(PolylineEvent(
        pickLat: double.parse(requestData!.pickLat),
        pickLng: double.parse(requestData!.pickLng),
        dropLat: dropAddressList.last.lat,
        dropLng: dropAddressList.last.lng,
        stops: (dropAddressList.length > 1) ? dropAddressList : [],
        pickAddress: requestData!.pickAddress,
        dropAddress: dropAddressList.last.address,
        isDropChanged: true,
      ));
    }
    emit(BookingUpdateState());
  }

  Future<void> receiverContactDetails(
      ReceiverContactEvent event, Emitter<BookingState> emit) async {
    isMyself = event.isReceiveMyself;
    receiverNameController.text = event.name;
    receiverMobileController.text = event.number;
    emit(BookingUpdateState());
  }

  Future<void> selectContactDetails(
      SelectContactDetailsEvent event, Emitter<BookingState> emit) async {
    await Permission.contacts.request();
    PermissionStatus status = await Permission.contacts.status;
    if (status.isGranted) {
      emit(BookingLoadingStartState());
      if (contactsList.isEmpty) {
        if (await FlutterContacts.requestPermission()) {
          List<Contact> contacts =
              await FlutterContacts.getContacts(withProperties: true);
          for (var contact in contacts) {
            for (var phone in contact.phones) {
              contactsList.add(ContactsModel(
                name: contact.displayName,
                number: phone.number,
              ));
            }
          }
        }
      }
      emit(BookingLoadingStopState());
      emit(SelectContactDetailsState());
    } else {
      debugPrint("Permission Denied");
      bool isOpened = await openAppSettings();
      if (isOpened) {
        debugPrint('App settings opened.');
      } else {
        debugPrint('Failed to open app settings.');
      }
      emit(BookingUpdateState());
    }
  }

  Future<void> changeDestination(
      ChangeDestinationEvent event, Emitter<BookingState> emit) async {
    final data = await serviceLocator<BookingUsecase>().changeDestinationApi(
        requestId: event.requestId,
        dropLat: event.dropAddressList.last.lat.toString(),
        dropLng: event.dropAddressList.last.lng.toString(),
        dropAddress: event.dropAddressList.last.address,
        duration: event.duration,
        distance: event.distance,
        polyLine: event.polyLine,
        stops: event.dropAddressList);
    data.fold((error) {
      showToast(message: error.message.toString());
    }, (success) {
      requestData = OnTripRequestData.fromJson(success.data.toJson());
      FirebaseDatabase.instance.ref('requests/${event.requestId}').update({
        'polyline': event.polyLine,
        'distance': event.distance,
        'duration': event.duration,
        'destination_change': ServerValue.timestamp
      });
      emit(DestinationChangeSuccessState(
          requestData: requestData!, dropAddressList: event.dropAddressList));
    });
  }

  Future<void> addMarkers(
      AddMarkersEvent event, Emitter<BookingState> emit) async {
    if (event.addressList == null) {
      markerList.removeWhere(
          (element) => !element.markerId.value.toString().contains('#'));
      if (event.requestData.requestStops != null &&
          event.requestData.requestStops.data.length > 1) {
        for (var i = 0; i < event.requestData.requestStops.data.length; i++) {
          markerList.add(Marker(
            markerId: MarkerId("drop$i"),
            position: LatLng(event.requestData.requestStops.data[i].latitude,
                event.requestData.requestStops.data[i].longitude),
            rotation: 0.0,
            icon: await MarkerWidget(
              isPickup: false,
              count: '${i + 1}',
              text: event.requestData.requestStops.data[i].address,
            ).toBitmapDescriptor(
                logicalSize: const Size(30, 30),
                imageSize: const Size(200, 200)),
          ));
        }
      } else {
        markerList.add(Marker(
          markerId: const MarkerId("drop"),
          position: LatLng(double.parse(event.requestData.dropLat),
              double.parse(event.requestData.dropLng)),
          rotation: 0.0,
          icon: await MarkerWidget(
            isPickup: false,
            text: event.requestData.dropAddress,
          ).toBitmapDescriptor(
              logicalSize: const Size(30, 30), imageSize: const Size(200, 200)),
        ));
      }
      await addDistanceMarker(
          LatLng(double.parse(event.requestData.dropLat),
              double.parse(event.requestData.dropLng)),
          event.requestData.unit == 'MILES'
              ? ((double.parse(event.requestData.totalDistance) * 1.60934) *
                  1000)
              : (double.parse(event.requestData.totalDistance) * 1000),
          time: double.parse(event.requestData.totalTime));
    } else {
      markerList.removeWhere(
          (element) => !element.markerId.value.toString().contains('#'));
      if (event.addressList!.length > 1) {
        for (var i = 0; i < event.addressList!.length; i++) {
          markerList.add(Marker(
            markerId: MarkerId("drop$i"),
            position:
                LatLng(event.addressList![i].lat, event.addressList![i].lng),
            rotation: 0.0,
            icon: await MarkerWidget(
              isPickup: false,
              count: '${i + 1}',
              text: event.addressList![i].address,
            ).toBitmapDescriptor(
                logicalSize: const Size(30, 30),
                imageSize: const Size(200, 200)),
          ));
        }
      } else {
        markerList.add(Marker(
          markerId: const MarkerId("drop"),
          position:
              LatLng(event.addressList!.last.lat, event.addressList!.last.lng),
          rotation: 0.0,
          icon: await MarkerWidget(
            isPickup: false,
            text: event.addressList!.last.address,
          ).toBitmapDescriptor(
              logicalSize: const Size(30, 30), imageSize: const Size(200, 200)),
        ));
      }
      await addDistanceMarker(
          LatLng(event.addressList!.last.lat, event.addressList!.last.lng),
          (double.tryParse(distance)!),
          time: double.parse(duration));
    }
    emit(BookingUpdateState());
  }

  Future<void> updateMarkers(
      UpdateMarkersEvent event, Emitter<BookingState> emit) async {
    markerList = event.markers;
    emit(BookingUpdateState());
  }

  FutureOr onRidePaymentWebViewUrl(
      OnRidePaymentWebViewUrlEvent event, Emitter<BookingState> emit) async {
    String paymentUrl = '';    
    if (event.from == '1') {
      paymentUrl =
          '${event.url}?amount=${event.money}&payment_for=request&currency=${event.currencySymbol}&user_id=${event.userId.toString()}&request_id=${event.requestId.toString()}';
    }
    final Uri uri = Uri.parse(paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
        const SnackBar(content: Text("Could not open payment page")),
      );
    }
  }

  Future<void> updateMapType(
      UpdateMapTypeEvent event, Emitter<BookingState> emit) async {
    _selectedMapType = event.mapType;
    emit(BookingUpdateState());
  }
}
