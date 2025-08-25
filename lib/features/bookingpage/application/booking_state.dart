part of 'booking_bloc.dart';

abstract class BookingState {}

// Eta Details
final class BookingInitialState extends BookingState {}

final class BookingLoadingStartState extends BookingState {}

final class BookingLoadingStopState extends BookingState {}

final class BookingSuccessState extends BookingState {}

final class BookingUpdateState extends BookingState {}

final class BookingNavigatorPopState extends BookingState {}

final class EtaSelectState extends BookingState {}

final class RentalPackageSelectState extends BookingState {}

final class RentalPackageConfirmState extends BookingState {}

final class EtaNotAvailableState extends BookingState {}

final class ShowEtaInfoState extends BookingState {
  final int infoIndex;

  ShowEtaInfoState({required this.infoIndex});
}

final class LogoutState extends BookingState {}

final class TimerState extends BookingState {}

final class BookingCreateRequestSuccessState extends BookingState {}

final class BookingLaterCreateRequestSuccessState extends BookingState {
  final bool isOutstation;

  BookingLaterCreateRequestSuccessState({required this.isOutstation});
}

final class BookingCreateRequestFailureState extends BookingState {}

final class BookingNoDriversFoundState extends BookingState {}

final class BookingOnTripRequestState extends BookingState {}

final class BookingStreamRequestState extends BookingState {}

final class TripCompletedState extends BookingState {
  final RideRepository rideRepository;

  TripCompletedState({required this.rideRepository});
}

final class TripRideCancelState extends BookingState {
  final bool isCancelByDriver;

  TripRideCancelState({required this.isCancelByDriver});
}

final class BookingRatingsUpdateState extends BookingState {}

final class BookingUserRatingsSuccessState extends BookingState {}

final class SelectGoodsTypeState extends BookingState {}

final class SelectContactDetailsState extends BookingState {}

final class ShowBiddingState extends BookingState {}

final class BiddingCreateRequestSuccessState extends BookingState {}

final class BiddingCreateRequestFailureState extends BookingState {}

final class BiddingFareUpdateState extends BookingState {}

final class BookingRequestCancelState extends BookingState {}

final class CancelReasonState extends BookingState {}

final class ChatWithDriverState extends BookingState {}

final class SosState extends BookingState {}

final class BookingScrollPhysicsUpdated extends BookingState {
  final bool enableEtaScrolling;

  BookingScrollPhysicsUpdated({required this.enableEtaScrolling});
}

class DetailViewUpdateState extends BookingState {
  final bool detailView;

  DetailViewUpdateState(this.detailView);
}

class WalletPageReUpdateStates extends BookingState {
  String url;
  String userId;
  String requestId;
  String currencySymbol;
  String money;
  WalletPageReUpdateStates(
      {required this.url,
      required this.userId,
      required this.requestId,
      required this.currencySymbol,
      required this.money});
}

class ShowAddTipState extends BookingState {
  final bool isDriverReceivedPayment;

  ShowAddTipState({required this.isDriverReceivedPayment});
}

class TipsAddedState extends BookingState {
  final RequestBillData requestBillData;

  TipsAddedState({required this.requestBillData});
}

class ChangePaymentState extends BookingState {}

class BookingConfirmAddressState extends BookingState {}

class EditLocationState extends BookingState {
  final List<AddressModel> addressList;
  final OnTripRequestData requestData;

  EditLocationState(
      {required this.addressList,
      required this.requestData});
}

class SelectFromMapState extends BookingState {}

class DestinationChangeSuccessState extends BookingState {
  final OnTripRequestData requestData;
  final List<AddressModel> dropAddressList;

  DestinationChangeSuccessState({required this.requestData,required this.dropAddressList});
}
