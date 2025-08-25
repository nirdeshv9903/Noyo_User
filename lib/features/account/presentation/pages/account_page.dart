import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/outstation/page/outstation_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/support_ticket/page/support_ticket.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_appbar.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/domain/models/user_details_model.dart';
import '../../../language/presentation/page/choose_language_page.dart';
import '../../application/acc_bloc.dart';
import '../widgets/page_options.dart';
import 'admin_chat/page/admin_chat.dart';
import 'profile/page/profile_info_page.dart';
import 'fav_location/page/fav_location.dart';
import 'history/page/history_page.dart';
import 'notification/page/notification_page.dart';
import 'refferal/page/referral_page.dart';
import 'settings/page/settings_page.dart';
import 'sos/page/sos_page.dart';
import 'wallet/page/wallet_page.dart';

class AccountPage extends StatelessWidget {
  static const String routeName = '/accountPage';
  final AccountPageArguments arg;

  const AccountPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(UserDataInitEvent(userDetails: arg.userData)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {},
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          return (accBloc.userData != null)
              ? Directionality(
                  textDirection: context.read<AccBloc>().textDirection == 'rtl'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Scaffold(
                    appBar: CustomAppBar(
                      title: AppLocalizations.of(context)!.myAccount,
                      centerTitle: true,
                      onBackTap: () {
                        Navigator.pop(context, accBloc.userData);
                      },
                    ),
                    body: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.width * 0.05),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                        context, ProfileInfoPage.routeName,
                                        arguments: ProfileInfoPageArguments(
                                            userData: context
                                                .read<AccBloc>()
                                                .userData!))
                                    .then((value) {
                                  if (!context.mounted) {
                                    return;
                                  }

                                  if (value != null) {
                                    context.read<AccBloc>().userData =
                                        value as UserDetail;
                                    context
                                        .read<AccBloc>()
                                        .add(AccUpdateEvent());
                                  }
                                });
                              },
                              child: Container(
                                width: size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  border: Border.all(
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 2, top: 10, bottom: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: size.width * 0.15,
                                            width: size.width * 0.15,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(35),
                                                color: Theme.of(context)
                                                    .dividerColor),
                                            child: (accBloc.userData!
                                                    .profilePicture.isEmpty)
                                                ? const Icon(
                                                    Icons.person,
                                                    size: 50,
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            35),
                                                    child: CachedNetworkImage(
                                                      imageUrl: accBloc
                                                          .userData!
                                                          .profilePicture,
                                                      height: size.width * 0.15,
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
                                          SizedBox(width: size.width * 0.03),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                IntrinsicWidth(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: MyText(
                                                          text: accBloc
                                                              .userData!.name,
                                                          maxLines: 4,
                                                          textStyle: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge!
                                                              .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: size.width * 0.01),
                                                MyText(
                                                    text:
                                                        "${AppLocalizations.of(context)!.totalRides} : ${accBloc.userData!.completedRideCount}",
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark,
                                                            fontSize: 12)),
                                                SizedBox(
                                                    height: size.width * 0.01),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.star,
                                                        color: AppColors
                                                            .goldenColor,
                                                        size: 20),
                                                    MyText(
                                                      text: accBloc
                                                          .userData!.rating,
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark),
                                                    ),
                                                  ],
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
                            ),
                          ),
                          SizedBox(height: size.width * 0.01),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: size.width * 0.05),
                                    PageOptions(
                                      label: AppLocalizations.of(context)!
                                          .notifications,
                                      icon: Icons.notifications,
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            NotificationPage.routeName);
                                      },
                                    ),
                                    PageOptions(
                                      label:
                                          AppLocalizations.of(context)!.history,
                                      icon: Icons.history,
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, HistoryPage.routeName,
                                          arguments: HistoryPageArguments(isSupportTicketEnabled: context
                                            .read<AccBloc>()
                                            .userData!
                                            .enableSupportTicketFeature)  );
                                      },
                                    ),
                                    if (context
                                            .read<AccBloc>()
                                            .userData!
                                            .showOutstationRideFeature ==
                                        '1')
                                      PageOptions(
                                        label: AppLocalizations.of(context)!
                                            .outStation,
                                        icon: Icons.taxi_alert_outlined,
                                        onTap: () {
                                          Navigator.pushNamed(context,
                                              OutstationHistoryPage.routeName,
                                              arguments:
                                                  OutstationHistoryPageArguments(
                                                      isFromBooking: false));
                                        },
                                      ),
                                    if (context
                                            .read<AccBloc>()
                                            .userData!
                                            .showWalletFeatureOnMobileApp ==
                                        '1')
                                      PageOptions(
                                        label: AppLocalizations.of(context)!
                                            .payment,
                                        icon: Icons.payment,
                                        onTap: () {
                                          Navigator.pushNamed(context,
                                                  WalletHistoryPage.routeName,
                                                  arguments:
                                                      WalletPageArguments(
                                                          userData: context
                                                              .read<AccBloc>()
                                                              .userData!))
                                              .then(
                                            (value) {
                                              if (!context.mounted) return;
                                              context.read<AccBloc>().add(
                                                  AccGetUserDetailsEvent());
                                            },
                                          );
                                        },
                                      ),
                                    PageOptions(
                                      label: AppLocalizations.of(context)!
                                          .referEarn,
                                      icon: Icons.share,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          ReferralPage.routeName,
                                          arguments: ReferralArguments(
                                              title:
                                                  AppLocalizations.of(context)!
                                                      .referEarn,
                                              userData: context
                                                  .read<AccBloc>()
                                                  .userData!),
                                        );
                                      },
                                    ),
                                    PageOptions(
                                      label: AppLocalizations.of(context)!
                                          .changeLanguage,
                                      icon: Icons.language,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          ChooseLanguagePage.routeName,
                                          arguments: ChooseLanguageArguments(
                                              isInitialLanguageChange: false),
                                        ).then(
                                          (value) {
                                            if (!context.mounted) return;
                                            context
                                                .read<AccBloc>()
                                                .add(AccGetDirectionEvent());
                                          },
                                        );
                                      },
                                    ),
                                    PageOptions(
                                      label: AppLocalizations.of(context)!
                                          .favoriteLocation,
                                      icon: Icons.favorite_border,
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                                FavoriteLocationPage.routeName,
                                                arguments:
                                                    FavouriteLocationPageArguments(
                                                        userData: context
                                                            .read<AccBloc>()
                                                            .userData!))
                                            .then(
                                          (value) {
                                            if (!context.mounted) return;
                                            if (value != null) {
                                              context.read<AccBloc>().userData =
                                                  value as UserDetail;
                                              context
                                                  .read<AccBloc>()
                                                  .add(AccUpdateEvent());
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    PageOptions(
                                      label: AppLocalizations.of(context)!.sos,
                                      icon: Icons.sos,
                                      onTap: () {
                                        Navigator.pushNamed(
                                                context, SosPage.routeName,
                                                arguments: SOSPageArguments(
                                                    sosData: context
                                                        .read<AccBloc>()
                                                        .userData!
                                                        .sos
                                                        .data))
                                            .then(
                                          (value) {
                                            if (!context.mounted) return;
                                            if (value != null) {
                                              final sos =
                                                  value as List<SOSDatum>;
                                              context.read<AccBloc>().sosdata =
                                                  sos;
                                              context
                                                      .read<AccBloc>()
                                                      .userData!
                                                      .sos
                                                      .data =
                                                  context
                                                      .read<AccBloc>()
                                                      .sosdata;
                                              context
                                                  .read<AccBloc>()
                                                  .add(AccUpdateEvent());
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    SizedBox(height: size.width * 0.03),
                                    MyText(
                                      text:
                                          AppLocalizations.of(context)!.general,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(fontSize: 18),
                                    ),
                                    SizedBox(height: size.width * 0.03),
                                    PageOptions(
                                      label: AppLocalizations.of(context)!
                                          .chatWithUs,
                                      icon: Icons.chat,
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, AdminChat.routeName,
                                            arguments: AdminChatPageArguments(
                                                userData: context
                                                    .read<AccBloc>()
                                                    .userData!));
                                      },
                                    ),
                                    // PageOptions(
                                    //   label: AppLocalizations.of(context)!
                                    //       .makeComplaint,
                                    //   icon: Icons.help,
                                    //   onTap: () {
                                    //     Navigator.pushNamed(
                                    //         context, ComplaintListPage.routeName,
                                    //         arguments: ComplaintListPageArguments(
                                    //             choosenHistoryId: ''));
                                    //   },
                                    // ),
                                    if (context
                                            .read<AccBloc>()
                                            .userData!
                                            .enableSupportTicketFeature ==
                                        '1')
                                      PageOptions(
                                        label: AppLocalizations.of(context)!
                                            .supportTicket,
                                        icon: Icons.support,
                                        onTap: () {
                                          Navigator.pushNamed(context,
                                              SupportTicketPage.routeName,
                                              arguments:
                                                  SupportTicketPageArguments(
                                                      isFromRequest: false,
                                                      requestId: ''));
                                        },
                                      ),
                                    PageOptions(
                                      label: AppLocalizations.of(context)!
                                          .settings,
                                      icon: Icons.settings,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          SettingsPage.routeName,
                                          arguments: SettingsPageArguments(
                                              userData: accBloc.userData!),
                                        );
                                      },
                                    ),
                                    SizedBox(height: size.width * 0.1),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : const Scaffold(
                  body: Loader(),
                );
        }),
      ),
    );
  }
}
