import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;

import '../../../../common/common.dart';
import '../../../../common/pickup_icon.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_navigation_icon.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../application/home_bloc.dart';
import '../../domain/models/user_details_model.dart';
import 'bottom_sheet_widget.dart';

class HomeBodyWidget extends StatelessWidget {
  final BuildContext cont;

  const HomeBodyWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final screenWidth = size.width;
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Stack(
            children: [
              // The map and other widgets
              SizedBox(
                height: size.height,
                width: size.width,
                child: Stack(
                  children: [
                    (context.read<HomeBloc>().mapType == 'google_map')
                        // GOOGLE MAP
                        ? SizedBox(
                            height: size.height,
                            width: size.width,
                            child: GoogleMap(
                              mapType: context.read<HomeBloc>().selectedMapType,
                              gestureRecognizers: {
                                Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                                ),
                              },
                              onMapCreated: (GoogleMapController controller) {
                                if (context
                                        .read<HomeBloc>()
                                        .googleMapController ==
                                    null) {
                                  context.read<HomeBloc>().add(
                                      GoogleControllAssignEvent(
                                          controller: controller,
                                          isFromHomePage: true,
                                          isEditAddress: false,
                                          latlng: context
                                              .read<HomeBloc>()
                                              .currentLatLng));
                                } else {
                                  context.read<HomeBloc>().add(LocateMeEvent(
                                      mapType:
                                          context.read<HomeBloc>().mapType));
                                }
                              },
                              padding: EdgeInsets.only(
                                  bottom: screenWidth + size.width * 0.01),
                              initialCameraPosition: CameraPosition(
                                target: context.read<HomeBloc>().currentLatLng,
                                zoom: 15.0,
                              ),
                              onTap: (argument) {
                                context.read<HomeBloc>().currentLatLng =
                                    argument;
                                if (context
                                        .read<HomeBloc>()
                                        .googleMapController !=
                                    null) {
                                  context
                                      .read<HomeBloc>()
                                      .googleMapController!
                                      .animateCamera(
                                          CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                  target: argument, zoom: 15)));
                                }
                              },
                              onCameraMoveStarted: () {
                                context.read<HomeBloc>().setDragging(true);

                                context.read<HomeBloc>().isCameraMoveComplete =
                                    true;
                              },
                              onCameraMove: (CameraPosition? position) {
                                if (position != null) {
                                  if (!context.mounted) return;
                                  context.read<HomeBloc>().currentLatLng =
                                      position.target;
                                }
                              },
                              onCameraIdle: () {
                                context.read<HomeBloc>().setDragging(false);
                                if (context
                                    .read<HomeBloc>()
                                    .isCameraMoveComplete) {
                                  if (context
                                      .read<HomeBloc>()
                                      .pickupAddressList
                                      .isEmpty) {
                                    context.read<HomeBloc>().add(
                                        UpdateLocationEvent(
                                            isFromHomePage: true,
                                            latLng: context
                                                .read<HomeBloc>()
                                                .currentLatLng,
                                            mapType: context
                                                .read<HomeBloc>()
                                                .mapType));
                                  } else {
                                    context.read<HomeBloc>().confirmPinAddress =
                                        true;
                                    context.read<HomeBloc>().add(UpdateEvent());
                                  }
                                }
                              },
                              markers:
                                  context.read<HomeBloc>().markerList.isNotEmpty
                                      ? Set.from(
                                          context.read<HomeBloc>().markerList)
                                      : {},
                              minMaxZoomPreference:
                                  const MinMaxZoomPreference(13, 20),
                              buildingsEnabled: false,
                              zoomControlsEnabled: false,
                              compassEnabled: false,
                              mapToolbarEnabled: false,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                            ),
                          ) // OPEN STREET MAP
                        : SizedBox(
                            height: size.height * 0.55,
                            width: size.width,
                            child: fm.FlutterMap(
                              mapController:
                                  context.read<HomeBloc>().fmController,
                              options: fm.MapOptions(
                                onTap: (tapPosition, latLng) {
                                  context.read<HomeBloc>().currentLatLng =
                                      LatLng(latLng.latitude, latLng.longitude);
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (context.read<HomeBloc>().fmController !=
                                        null) {
                                      context
                                          .read<HomeBloc>()
                                          .fmController!
                                          .move(latLng, 15);
                                    }
                                  });
                                  context.read<HomeBloc>().add(
                                        UpdateLocationEvent(
                                          isFromHomePage: true,
                                          latLng: context
                                              .read<HomeBloc>()
                                              .currentLatLng,
                                          mapType:
                                              context.read<HomeBloc>().mapType,
                                        ),
                                      );
                                },
                                onMapEvent: (v) async {
                                  if (v.source ==
                                      fm.MapEventSource.nonRotatedSizeChange) {
                                    context.read<HomeBloc>().fmLatLng =
                                        fmlt.LatLng(v.camera.center.latitude,
                                            v.camera.center.longitude);
                                    context.read<HomeBloc>().currentLatLng =
                                        LatLng(v.camera.center.latitude,
                                            v.camera.center.longitude);
                                    context.read<HomeBloc>().add(
                                          UpdateLocationEvent(
                                            isFromHomePage: true,
                                            latLng: context
                                                .read<HomeBloc>()
                                                .currentLatLng,
                                            mapType: context
                                                .read<HomeBloc>()
                                                .mapType,
                                          ),
                                        );
                                  }
                                  if (v.source == fm.MapEventSource.onDrag) {
                                    context.read<HomeBloc>().currentLatLng =
                                        LatLng(v.camera.center.latitude,
                                            v.camera.center.longitude);
                                    context.read<HomeBloc>().add(UpdateEvent());
                                  }
                                  if (v.source == fm.MapEventSource.dragEnd) {
                                    context.read<HomeBloc>().add(
                                          UpdateLocationEvent(
                                            isFromHomePage: true,
                                            latLng: LatLng(
                                                v.camera.center.latitude,
                                                v.camera.center.longitude),
                                            mapType: context
                                                .read<HomeBloc>()
                                                .mapType,
                                          ),
                                        );
                                  }
                                },
                                onPositionChanged: (p, l) async {
                                  if (l == false) {
                                    context.read<HomeBloc>().currentLatLng =
                                        LatLng(p.center.latitude,
                                            p.center.longitude);
                                    context.read<HomeBloc>().add(UpdateEvent());
                                  }
                                },
                                initialCenter: fmlt.LatLng(
                                    context
                                        .read<HomeBloc>()
                                        .currentLatLng
                                        .latitude,
                                    context
                                        .read<HomeBloc>()
                                        .currentLatLng
                                        .longitude),
                                initialZoom: 16,
                                minZoom: 13,
                                maxZoom: 20,
                              ),
                              children: [
                                fm.TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.app',
                                ),
                                fm.MarkerLayer(
                                  markers: context
                                      .read<HomeBloc>()
                                      .markerList
                                      .asMap()
                                      .map(
                                        (k, value) {
                                          final marker = context
                                              .read<HomeBloc>()
                                              .markerList
                                              .elementAt(k);
                                          return MapEntry(
                                            k,
                                            fm.Marker(
                                              alignment: Alignment.topCenter,
                                              point: fmlt.LatLng(
                                                  marker.position.latitude,
                                                  marker.position.longitude),
                                              child: RotationTransition(
                                                turns: AlwaysStoppedAnimation(
                                                    marker.rotation / 360),
                                                child: Image.asset(
                                                  (marker.markerId.value
                                                          .toString()
                                                          .contains('truck'))
                                                      ? AppImages.truck
                                                      : marker.markerId.value
                                                              .toString()
                                                              .contains(
                                                                  'motor_bike')
                                                          ? AppImages.bike
                                                          : marker.markerId
                                                                  .value
                                                                  .toString()
                                                                  .contains(
                                                                      'auto')
                                                              ? AppImages.auto
                                                              : marker.markerId
                                                                      .value
                                                                      .toString()
                                                                      .contains(
                                                                          'lcv')
                                                                  ? AppImages
                                                                      .lcv
                                                                  : marker.markerId
                                                                          .value
                                                                          .toString()
                                                                          .contains(
                                                                              'ehcv')
                                                                      ? AppImages
                                                                          .ehcv
                                                                      : marker.markerId
                                                                              .value
                                                                              .toString()
                                                                              .contains('hatchback')
                                                                          ? AppImages.hatchBack
                                                                          : marker.markerId.value.toString().contains('hcv')
                                                                              ? AppImages.hcv
                                                                              : marker.markerId.value.toString().contains('mcv')
                                                                                  ? AppImages.mcv
                                                                                  : marker.markerId.value.toString().contains('luxury')
                                                                                      ? AppImages.luxury
                                                                                      : marker.markerId.value.toString().contains('premium')
                                                                                          ? AppImages.premium
                                                                                          : marker.markerId.value.toString().contains('suv')
                                                                                              ? AppImages.suv
                                                                                              : AppImages.car,
                                                  width: 16,
                                                  height: 25,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                      .values
                                      .toList(),
                                ),
                                const fm.RichAttributionWidget(
                                  attributions: [],
                                ),
                              ],
                            ),
                          ),

                    // Marker in the center of the screen
                    Positioned(
                      child: Container(
                        height: size.height * 0.8,
                        width: size.width * 1,
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: screenWidth * 0.6 + size.width * 0.06),
                          child: Image.asset(
                            AppImages.confirmationPin,
                            width: size.width * 0.12,
                            height: size.width * 0.12,
                          ),
                        ),
                      ),
                    ),

                    if (context.read<HomeBloc>().confirmPinAddress)
                      Positioned(
                        top: screenWidth * 0.09,
                        right: screenWidth * 0.38,
                        child: Container(
                          height: size.height * 0.8,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: screenWidth * 0.6 + size.width * 0.06),
                            child: Row(
                              children: [
                                BlocBuilder<HomeBloc, HomeState>(
                                  builder: (context, state) {
                                    return context.read<HomeBloc>().isDragging
                                        ? CustomButton(
                                            buttonColor: Theme.of(context)
                                                .disabledColor
                                                .withAlpha((0.5 * 255).toInt()),
                                            height: size.width * 0.08,
                                            width: size.width * 0.25,
                                            onTap: () {},
                                            textSize: 12,
                                            buttonName:
                                                AppLocalizations.of(context)!
                                                    .pickMeHere,
                                          )
                                        : CustomButton(
                                            buttonColor:
                                                Theme.of(context).primaryColor,
                                            height: size.width * 0.08,
                                            width: size.width * 0.25,
                                            onTap: () {
                                              context
                                                  .read<HomeBloc>()
                                                  .confirmPinAddress = false;
                                              context.read<HomeBloc>().add(
                                                    UpdateLocationEvent(
                                                      isFromHomePage: true,
                                                      latLng: context
                                                          .read<HomeBloc>()
                                                          .currentLatLng,
                                                      mapType: context
                                                          .read<HomeBloc>()
                                                          .mapType,
                                                    ),
                                                  );
                                            },
                                            textSize: 12,
                                            buttonName:
                                                AppLocalizations.of(context)!
                                                    .confirm,
                                          );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Locate Me
              Positioned(
                bottom: size.height * 0.51,
                right: size.width * 0.04,
                child: Column(
                  children: [
                    if (context.read<HomeBloc>().mapType == 'google_map')
                      Container(
                        margin: EdgeInsets.only(bottom: size.width * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: PopupMenuButton<MapType>(
                          color: Colors.white,
                          icon: Container(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.layers_outlined,
                              color: Theme.of(context).primaryColorDark,
                              size: 20,
                            ),
                          ),
                          onSelected: (mapType) {
                            context
                                .read<HomeBloc>()
                                .add(UpdateMapTypeEvent(mapType));
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                                value: MapType.normal,
                                child: MyText(
                                    text:
                                        AppLocalizations.of(context)!.normal)),
                            PopupMenuItem(
                                value: MapType.satellite,
                                child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .satellite)),
                            PopupMenuItem(
                              value: MapType.terrain,
                              child: MyText(
                                  text: AppLocalizations.of(context)!.terrain),
                            ),
                            PopupMenuItem(
                              value: MapType.hybrid,
                              child: MyText(
                                  text: AppLocalizations.of(context)!.hybrid),
                            ),
                          ],
                        ),
                      ),
                    InkWell(
                      onTap: () {
                        // Remove confirmPinAddress for envato code
                        context.read<HomeBloc>().confirmPinAddress = false;
                        context.read<HomeBloc>().add(LocateMeEvent(
                            mapType: context.read<HomeBloc>().mapType));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: size.width * 0.12,
                        width: size.width * 0.12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.my_location,
                            size: size.width * 0.06,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Navigation and location bar
              SafeArea(
                bottom: false,
                top: true,
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.04),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: NavigationIconWidget(
                          icon: InkWell(
                            onTap: () {
                              if (context.read<HomeBloc>().userData != null) {
                                Navigator.pushNamed(
                                        context, AccountPage.routeName,
                                        arguments: AccountPageArguments(
                                            userData: context
                                                .read<HomeBloc>()
                                                .userData!))
                                    .then(
                                  (value) {
                                    if (!context.mounted) return;
                                    context
                                        .read<HomeBloc>()
                                        .add(GetDirectionEvent());
                                    if (value != null) {
                                      context.read<HomeBloc>().userData =
                                          value as UserDetail;
                                      context
                                          .read<HomeBloc>()
                                          .add(UpdateEvent());
                                    }
                                  },
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.menu,
                                size: 20,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                          isShadowWidget: false,
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (context
                                        .read<HomeBloc>()
                                        .userData!
                                        .enableModulesForApplications ==
                                    'both' ||
                                context
                                        .read<HomeBloc>()
                                        .userData!
                                        .enableModulesForApplications ==
                                    'taxi') {
                              context.read<HomeBloc>().add(
                                  DestinationSelectEvent(isPickupChange: true));
                            } else {
                              context.read<HomeBloc>().add(
                                  ServiceTypeChangeEvent(serviceTypeIndex: 1));
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04,
                              vertical: size.width * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(size.width * 0.02),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const PickupIcon(),
                                ),
                                SizedBox(width: size.width * 0.03),
                                Expanded(
                                  child: MyText(
                                    text: context
                                        .read<HomeBloc>()
                                        .currentLocation,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontWeight: FontWeight.w500,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.6),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    double sheetSize = context.read<HomeBloc>().sheetSize;
                    double minChildSize =
                        context.read<HomeBloc>().minChildSize; // Bottom
                    double midChildSize =
                        context.read<HomeBloc>().midChildSize; // Midpoint
                    double maxChildSize =
                        context.read<HomeBloc>().maxChildSize; // Top
                    double currentSize = sheetSize;
                    return GestureDetector(
                      onVerticalDragUpdate: (details) {
                        final dragAmount = details.primaryDelta ?? 0;

                        currentSize =
                            (currentSize - dragAmount / context.size!.height)
                                .clamp(minChildSize, maxChildSize);
                        context
                            .read<HomeBloc>()
                            .add(UpdateScrollPositionEvent(currentSize));
                      },
                      onVerticalDragEnd: (details) {
                        // If scrolling up, snap to the top or midpoint
                        if (details.velocity.pixelsPerSecond.dy < 0) {
                          currentSize = currentSize >= midChildSize
                              ? maxChildSize
                              : midChildSize;
                        } else {
                          // If scrolling down, skip the midpoint and go directly to the bottom
                          currentSize = minChildSize;
                        }

                        context
                            .read<HomeBloc>()
                            .add(UpdateScrollPositionEvent(currentSize));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height:
                            MediaQuery.of(context).size.height * currentSize,
                        curve: Curves.easeInOut,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24)),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .shadowColor
                                    .withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: context.read<HomeBloc>().serviceAvailable
                                ? BottomSheetWidget(cont: context)
                                : Column(
                                    children: [
                                      SizedBox(height: size.width * 0.03),
                                      Image.asset(AppImages.noDataFound,
                                          height: size.width * 0.5,
                                          width: size.width),
                                      SizedBox(height: size.width * 0.02),
                                      MyText(
                                          text: AppLocalizations.of(context)!
                                              .serviceNotAvailable)
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    );
                    // },);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
