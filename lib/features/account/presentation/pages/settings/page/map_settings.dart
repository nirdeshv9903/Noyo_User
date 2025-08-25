import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../core/utils/custom_appbar.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/acc_bloc.dart';

class MapSettingsPage extends StatelessWidget {
  static const String routeName = '/mapSettings';

  const MapSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()..add(AccGetDirectionEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {},
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.mapSettings,
            ),
            body: Column(
              children: [
                SizedBox(height: size.width * 0.05),
                CarouselSlider(
                  items: [
                    InkWell(
                      onTap: () {
                        context
                            .read<AccBloc>()
                            .add(ChooseMapOnTapEvent(chooseMapIndex: 0));
                      },
                      child: Container(
                        margin: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/googlemap.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                            alignment: Alignment.bottomCenter,
                            width: size.width * 0.8,
                            child: Container(
                              width: size.width * 0.8,
                              padding: EdgeInsets.all(size.width * 0.025),
                              color: (context.read<AccBloc>().choosenMapIndex ==
                                      0)
                                  ? Theme.of(context).primaryColor
                                  : Colors.black.withAlpha((0.5 * 255).toInt()),
                              child: MyText(
                                text: AppLocalizations.of(context)!.googleMap,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            )),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context
                            .read<AccBloc>()
                            .add(ChooseMapOnTapEvent(chooseMapIndex: 1));
                      },
                      child: Container(
                        margin: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/fluttermap.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                            alignment: Alignment.bottomCenter,
                            width: size.width * 0.8,
                            child: Container(
                              width: size.width * 0.8,
                              padding: EdgeInsets.all(size.width * 0.025),
                              color: (context.read<AccBloc>().choosenMapIndex ==
                                      1)
                                  ? Theme.of(context).primaryColor
                                  : Colors.black.withAlpha((0.5 * 255).toInt()),
                              child: MyText(
                                text: AppLocalizations.of(context)!.openStreet,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            )),
                      ),
                    ),
                  ],
                  options: CarouselOptions(
                    height: size.width * 1.5,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    aspectRatio: 16 / 9,
                    enableInfiniteScroll: false,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    viewportFraction: 0.75,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
