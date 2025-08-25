import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restart_tagxi/core/utils/payment_received_stream.dart';
import '../features/account/domain/models/history_model.dart';
import '../features/auth/domain/models/country_list_model.dart';
import '../features/home/domain/models/user_details_model.dart';
import '../features/home/domain/models/stop_address_model.dart';

// Page arguments for data transfer

class VerifyArguments {
  final String mobileOrEmail;
  final String dialCode;
  final String countryCode;
  final String countryFlag;
  final bool isLoginByEmail;
  final bool isOtpVerify;
  final bool userExist;
  final bool isDemoLogin;
  final List<Country> countryList;
  final int isRefferalEarnings;

  VerifyArguments({
    required this.mobileOrEmail,
    required this.dialCode,
    required this.countryCode,
    required this.countryFlag,
    required this.isLoginByEmail,
    required this.isOtpVerify,
    required this.userExist,
    required this.isDemoLogin,
    required this.countryList,
    required this.isRefferalEarnings,
  });
}

class RegisterPageArguments {
  final String emailOrMobile;
  final String dialCode;
  final String contryCode;
  final String countryFlag;
  final bool isLoginByEmail;
  final List<Country> countryList;
  final int isRefferalEarnings;

  RegisterPageArguments({
    required this.isLoginByEmail,
    required this.dialCode,
    required this.contryCode,
    required this.countryFlag,
    required this.emailOrMobile,
    required this.countryList,
    required this.isRefferalEarnings,
  });
}

class ReferralArguments {
  final String title;
  final UserDetail userData;

  ReferralArguments({required this.title, required this.userData});
}

class ForgotPasswordPageArguments {
  final String emailOrMobile;
  final String contryCode;
  final String countryFlag;
  final bool isLoginByEmail;

  ForgotPasswordPageArguments({
    required this.isLoginByEmail,
    required this.contryCode,
    required this.countryFlag,
    required this.emailOrMobile,
  });
}

class UpdatePasswordPageArguments {
  final String emailOrMobile;
  final bool isLoginByEmail;

  UpdatePasswordPageArguments({
    required this.isLoginByEmail,
    required this.emailOrMobile,
  });
}

class DestinationPageArguments {
  final String title;
  final String? pickupAddress;
  final LatLng? pickupLatLng;
  final String? dropAddress;
  final LatLng? dropLatLng;
  UserDetail userData;
  final bool pickUpChange;
  final String mapType;
  final String transportType;
  final bool isOutstationRide;

  DestinationPageArguments({
    required this.title,
    required this.userData,
    this.pickupAddress,
    this.pickupLatLng,
    this.dropAddress,
    this.dropLatLng,
    required this.pickUpChange,
    required this.mapType,
    required this.transportType,
    required this.isOutstationRide,
  });
}

class ConfirmLocationPageArguments {
  final UserDetail userData;
  final bool isPickupEdit;
  final bool isEditAddress;
  final bool isOutstationRide;
  final LatLng? latlng;
  final String transportType;
  final String mapType;

  ConfirmLocationPageArguments({
    required this.userData,
    required this.isPickupEdit,
    required this.isEditAddress,
    required this.isOutstationRide,
    this.latlng,
    required this.mapType,
    required this.transportType,
  });
}

class ConfirmRidePageArguments {
  final List<AddressModel> pickupAddressList;
  final List<AddressModel> stopAddressList;
  final UserDetail userData;
  final String selectedTransportType;

  ConfirmRidePageArguments(
      {required this.pickupAddressList,
      required this.stopAddressList,
      required this.userData,
      required this.selectedTransportType});
}

class UpdateDetailsArguments {
  final String header;
  final String text;
  final UserDetail userData;

  UpdateDetailsArguments({
    required this.header,
    required this.text,
    required this.userData,
  });
}

class AccountPageArguments {
  final UserDetail userData;

  AccountPageArguments({
    required this.userData,
  });
}

class OutstationHistoryPageArguments {
  final bool isFromBooking;

  OutstationHistoryPageArguments({
    required this.isFromBooking,
  });
}

class BookingPageArguments {
  final String picklat;
  final String picklng;
  final String droplat;
  final String droplng;
  final List<AddressModel> pickupAddressList;
  final List<AddressModel> stopAddressList;
  final UserDetail userData;
  final String transportType;
  final String? requestId;
  final String polyString;
  final String distance;
  final String duration;
  final String mapType;
  final String? title;
  final bool isOutstationRide;
  final bool? isRentalRide;
  final bool? isWithoutDestinationRide;

  BookingPageArguments({
    required this.picklat,
    required this.picklng,
    required this.droplat,
    required this.droplng,
    required this.pickupAddressList,
    required this.stopAddressList,
    required this.userData,
    required this.transportType,
    this.requestId,
    required this.polyString,
    required this.distance,
    required this.duration,
    required this.mapType,
    this.title,
    this.isRentalRide,
    this.isWithoutDestinationRide,
    required this.isOutstationRide,
  });
}

class ProfileInfoPageArguments {
  final UserDetail userData;

  ProfileInfoPageArguments({
    required this.userData,
  });
}

class UpdateProfileArguments {
  final UserDetail userData;

  UpdateProfileArguments({
    required this.userData,
  });
}

class ComplaintPageArguments {
  final String title;
  final String complaintTitleId;
  final String? selectedHistoryId;

  ComplaintPageArguments(
      {required this.title,
      required this.complaintTitleId,
      this.selectedHistoryId});
}

class HistoryPageArguments {
  final String isSupportTicketEnabled;

  HistoryPageArguments({required this.isSupportTicketEnabled});
}

class TripHistoryPageArguments {
  final HistoryData historyData;
  final RequestBillData? requestbillData;
  final String isSupportTicketEnabled;
  final int? historyIndex;
  final int pageNumber;

  TripHistoryPageArguments(
      {required this.historyData,
      required this.pageNumber,
      required this.isSupportTicketEnabled,
      this.requestbillData,
      this.historyIndex});
}

class InvoicePageArguments {
  final OnTripRequestData requestData;
  RequestBillData requestBillData;
  final DriverDetailData driverData;
  final RideRepository rideRepository;

  InvoicePageArguments(
      {required this.requestData,
      required this.requestBillData,
      required this.driverData,
      required this.rideRepository});
}

class ReviewPageArguments {
  final String requestId;
  final String orderNo;
  final DriverDetailData driverData;

  ReviewPageArguments(
      {required this.requestId,
      required this.orderNo,
      required this.driverData});
}

class OnGoingRidesPageArguments {
  final UserDetail userData;
  final String mapType;

  OnGoingRidesPageArguments({required this.userData, required this.mapType});
}

class ChooseLanguageArguments {
  final bool isInitialLanguageChange;

  ChooseLanguageArguments({required this.isInitialLanguageChange});
}

class ComplaintListPageArguments {
  final String? choosenHistoryId;

  ComplaintListPageArguments({
    this.choosenHistoryId,
  });
}

class FavouriteLocationPageArguments {
  final UserDetail userData;

  FavouriteLocationPageArguments({required this.userData});
}

class ConfirmFavouriteLocationPageArguments {
  final AddressModel selectedAddress;
  final UserDetail userData;

  ConfirmFavouriteLocationPageArguments(
      {required this.selectedAddress, required this.userData});
}

class PaymentGateWayPageArguments {
  final String from;
  final String url;
  final String userId;
  final String requestId;
  final String currencySymbol;
  final String money;

  PaymentGateWayPageArguments(
      {required this.from,
      required this.url,
      required this.userId,
      required this.requestId,
      required this.currencySymbol,
      required this.money});
}

class DeliveryDetailsPageArguments {
  final String pickupAddress;
  final LatLng pickupLatLng;
  final UserDetail userData;
  final String transportType;

  DeliveryDetailsPageArguments({
    required this.pickupAddress,
    required this.pickupLatLng,
    required this.userData,
    required this.transportType,
  });
}

class SOSPageArguments {
  final List<SOSDatum> sosData;

  SOSPageArguments({
    required this.sosData,
  });
}

class AdminChatPageArguments {
  final UserDetail userData;

  AdminChatPageArguments({
    required this.userData,
  });
}

class WalletPageArguments {
  final UserDetail userData;

  WalletPageArguments({required this.userData});
}

class PaymentMethodArguments {
  final UserDetail userData;

  PaymentMethodArguments({required this.userData});
}

class OutStationOfferedPageArguments {
  final String requestId;
  final String offeredFare;
  final String currencySymbol;
  final String pickAddress;
  final String dropAddress;
  final String updatedAt;
  // final UserDetail userData;

  OutStationOfferedPageArguments({
    required this.requestId,
    required this.offeredFare,
    required this.currencySymbol,
    required this.pickAddress,
    required this.dropAddress,
    required this.updatedAt,
    // required this.userData,
  });
}

class SupportTicketPageArguments {
  final bool isFromRequest;
  final String requestId;

  SupportTicketPageArguments(
      {required this.isFromRequest, required this.requestId});
}

class ViewTicketPageArguments {
  final bool isViewTicketPage;
  final String ticketId;
  final String id;

  ViewTicketPageArguments(
      {required this.isViewTicketPage,
      required this.ticketId,
      required this.id});
}

class SettingsPageArguments {
  final UserDetail userData;

  SettingsPageArguments({required this.userData});
}

class EditLocationPageArguments {
  final OnTripRequestData requestData;
  final UserDetail userData;
  final List<AddressModel> addressList;
  final String mapType;

  EditLocationPageArguments({
    required this.requestData,
    required this.addressList,
    required this.mapType,
    required this.userData,
  });
}

class TermsAndPrivacyPolicyArguments {
  final bool isPrivacyPolicy;
  final String url;

  TermsAndPrivacyPolicyArguments({required this.isPrivacyPolicy,required this.url});
}
