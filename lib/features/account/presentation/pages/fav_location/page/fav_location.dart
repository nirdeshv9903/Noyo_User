import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../common/app_arguments.dart';
import '../../../../../../core/utils/custom_appbar.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../home/domain/models/stop_address_model.dart';
import '../../../../../home/presentation/pages/confirm_location_page.dart';
import '../../../../application/acc_bloc.dart';
import '../widget/delete_address_widget.dart';
import '../widget/favourites_shimmer_loading.dart';
import 'confirm_fav_location.dart';

class FavoriteLocationPage extends StatelessWidget {
  final FavouriteLocationPageArguments arg;
  static const String routeName = '/favoriteLocation';

  const FavoriteLocationPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(GetFavListEvent(
            userData: arg.userData,
            favAddressList: arg.userData.favouriteLocations.data)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is SelectFromFavAddressState) {
            Navigator.pushNamed(context, ConfirmLocationPage.routeName,
                    arguments: ConfirmLocationPageArguments(
                        isEditAddress: false,
                        userData: arg.userData,
                        isOutstationRide: false,
                        isPickupEdit: false,
                        mapType: context.read<AccBloc>().userData!.mapType,
                        transportType: ''))
                .then(
              (value) {
                if (!context.mounted) return;
                if (value != null) {
                  final address = value as AddressModel;
                  if (state.addressType == 'Home' ||
                      state.addressType == 'Work') {
                    context.read<AccBloc>().add(AddFavAddressEvent(
                        isOther: false,
                        address: address.address,
                        name: state.addressType,
                        lat: address.lat.toString(),
                        lng: address.lng.toString()));
                  } else {
                    if (context.read<AccBloc>().userData != null) {
                      Navigator.pushNamed(context, ConfirmFavLocation.routeName,
                              arguments: ConfirmFavouriteLocationPageArguments(
                                  userData: context.read<AccBloc>().userData!,
                                  selectedAddress: address))
                          .then(
                        (value) {
                          if (!context.mounted) return;
                          context.read<AccBloc>().add(AccGetUserDetailsEvent());
                        },
                      );
                    }
                  }
                }
              },
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.favoriteLocation,
              automaticallyImplyLeading: true,
              onBackTap: () {
                Navigator.pop(context, context.read<AccBloc>().userData);
              },
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        size.width * 0.05,
                        size.width * 0.025,
                        size.width * 0.05,
                        size.width * 0.025),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height:size.width * 0.05),
                        if (context.read<AccBloc>().isFavLoading)
                          ListView.builder(
                            itemCount: 6,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return FavouriteShimmerLoading(size: size);
                            },
                          ),
                        if (!context.read<AccBloc>().isFavLoading) ...[
                          (context.read<AccBloc>().home.isNotEmpty)
                              ? Container(
                                decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                      children: [
                                        Icon(
                                          Icons.home,
                                          color: Theme.of(context).primaryColorDark,
                                          size: size.width * 0.06,
                                        ),
                                        SizedBox(width: size.width * 0.02),
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!.home,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold),
                                            ),
                                            MyText(
                                              text: context
                                                  .read<AccBloc>()
                                                  .home[0]
                                                  .pickAddress,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .disabledColor
                                                          .withAlpha((0.6 * 255).toInt())),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        )),
                                        SizedBox(width: size.width * 0.015),
                                        InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                builder: (_) {
                                                  return DeleteAddressWidget(
                                                     cont: context,
                                                        isHome: true,
                                                        isWork: false,
                                                        isOthers: false,
                                                        addressId: context
                                                            .read<AccBloc>()
                                                            .home[0]
                                                            .id
                                                  );
                                                });
                                          },
                                          child: Container(
                                              height: size.width * 0.07,
                                              width: size.width * 0.07,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.red.shade50),
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.delete,
                                                size: size.width * 0.05,
                                                color: Colors.red,
                                              )),
                                        ),
                                      ],
                                    ),
                                ),
                              )
                              : InkWell(
                                  onTap: () {
                                    context.read<AccBloc>().add(
                                        SelectFromFavAddressEvent(
                                            addressType: 'Home'));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.home,
                                            color: Theme.of(context).primaryColorDark,
                                            size: size.width * 0.06,
                                          ),
                                          SizedBox(width: size.width * 0.02),
                                          Expanded(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyText(
                                                text: AppLocalizations.of(context)!
                                                    .home,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold),
                                              ),
                                              MyText(
                                                text: AppLocalizations.of(context)!
                                                    .tapAddAddress,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .disabledColor
                                                            .withAlpha((0.6 * 255).toInt()),
                                                        fontSize: 16),
                                              ),
                                            ],
                                          )),
                                          Icon(
                                            Icons.add_circle_outline,
                                            color: Theme.of(context).primaryColorDark,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          SizedBox(height: size.width *0.02),      
                          (context.read<AccBloc>().work.isNotEmpty)
                              ? Container(
                                decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                      children: [
                                        Icon(
                                          Icons.work,
                                          color: Theme.of(context).primaryColorDark,
                                          size: size.width * 0.06,
                                        ),
                                        SizedBox(width: size.width * 0.02),
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!.work,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                            ),
                                            MyText(
                                              text: context
                                                  .read<AccBloc>()
                                                  .work[0]
                                                  .pickAddress,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .disabledColor
                                                          .withAlpha((0.6 * 255).toInt())),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        )),
                                        InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                builder: (_) {
                                                  return DeleteAddressWidget(
                                                              cont: context,
                                                             isHome: false,
                                                        isWork: true,
                                                        isOthers: false,
                                                        addressId: context
                                                            .read<AccBloc>()
                                                            .work[0]
                                                            .id);
                                                  
                                                });
                                          },
                                          child: Container(
                                              height: size.width * 0.07,
                                              width: size.width * 0.07,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.red.shade50),
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.delete,
                                                size: size.width * 0.05,
                                                color: Colors.red,
                                              )),
                                        ),
                                      ],
                                    ),
                                ),
                              )
                              : InkWell(
                                  onTap: () {
                                    context.read<AccBloc>().add(
                                        SelectFromFavAddressEvent(
                                            addressType: 'Work'));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.work,
                                            color: Theme.of(context).primaryColorDark,
                                            size: size.width * 0.06,
                                          ),
                                          SizedBox(width: size.width * 0.02),
                                          Expanded(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyText(
                                                text: AppLocalizations.of(context)!
                                                    .work,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold),
                                              ),
                                              MyText(
                                                text: AppLocalizations.of(context)!
                                                    .tapAddAddress,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        fontSize: 16,
                                                        color: Theme.of(context)
                                                            .disabledColor
                                                            .withAlpha((0.6 * 255).toInt())),
                                              ),
                                            ],
                                          )),
                                          Icon(
                                            Icons.add_circle_outline,
                                            color: Theme.of(context).primaryColorDark,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          SizedBox(height: size.width * 0.02),      
                          if (context.read<AccBloc>().others.isNotEmpty)
                            ListView.builder(
                              itemCount: context.read<AccBloc>().others.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 30),
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Container(
                                       decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.bookmark,
                                              color: Theme.of(context)
                                                  .dividerColor
                                                  .withAlpha((0.5 * 255).toInt()),
                                            ),
                                            SizedBox(width: size.width * 0.02),
                                            Expanded(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                MyText(
                                                  text: context
                                                      .read<AccBloc>()
                                                      .others[index]
                                                      .addressName,
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                MyText(
                                                  text: context
                                                      .read<AccBloc>()
                                                      .others[index]
                                                      .pickAddress,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                          color: Theme.of(context)
                                                              .disabledColor),
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            )),
                                            InkWell(
                                              onTap: () {
                                                showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (_) {
                                                      return DeleteAddressWidget(
                                                            cont: context,
                                                            isHome: false,
                                                            isWork: false,
                                                            isOthers: true,
                                                            addressId: context
                                                                .read<AccBloc>()
                                                                .others[index]
                                                                .id);
                                                    });
                                              },
                                              child: Container(
                                                  height: size.width * 0.07,
                                                  width: size.width * 0.07,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.red.shade50),
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.delete,
                                                    size: size.width * 0.05,
                                                    color: Colors.red,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.width *0.02),
                                  ],
                                );
                              },
                            ),
                          SizedBox(height: size.width * 0.02),    
                          if (context.read<AccBloc>().others.length < 2)
                            InkWell(
                              onTap: () async {
                                context
                                    .read<AccBloc>()
                                    .newAddressController
                                    .text = '';
                                context.read<AccBloc>().add(
                                    SelectFromFavAddressEvent(
                                        addressType: context
                                            .read<AccBloc>()
                                            .newAddressController
                                            .text));
                              },
                              child: Row(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withAlpha((0.15 * 255).toInt()),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Icon(
                                          Icons.add,
                                          size: 20,
                                          color:
                                              Theme.of(context).primaryColorDark,
                                        ),
                                      )),
                                  SizedBox(width: size.width * 0.02),
                                  MyText(
                                    text: AppLocalizations.of(context)!.addMore,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color:
                                              Theme.of(context).primaryColorDark,
                                          fontSize: 16,
                                        ),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ],
                    ),
                  ),
                ),
            ),
          );
        }),
      ),
    );
  }
}
