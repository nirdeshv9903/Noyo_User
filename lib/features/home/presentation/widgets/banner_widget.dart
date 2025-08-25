import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/home_bloc.dart';

class BannerWidget extends StatelessWidget {
  final BuildContext cont;
  const BannerWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
        value: cont.read<HomeBloc>(),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CarouselSlider(
                      items: List.generate(
                        context
                            .read<HomeBloc>()
                            .userData!
                            .bannerImage
                            .data
                            .length,
                        (index) {
                          return CachedNetworkImage(
                            imageUrl: context
                                .read<HomeBloc>()
                                .userData!
                                .bannerImage
                                .data[index]
                                .image,
                            width: size.width,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: size.width * 0.18,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: size.width * 0.18,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.5),
                                  size: 32,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      options: CarouselOptions(
                        height: size.width * 0.18,
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.95,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 500),
                        autoPlayCurve: Curves.easeInOut,
                        enlargeCenterPage: true,
                        enlargeFactor: 0.1,
                        scrollDirection: Axis.horizontal,
                        onPageChanged: (index, reason) {
                          context.read<HomeBloc>().bannerIndex = index;
                          context.read<HomeBloc>().add(UpdateEvent());
                        },
                      ),
                    ),
                  ),
                ),

                // Page indicators
                if (context.read<HomeBloc>().userData!.bannerImage.data.length >
                    1) ...[
                  SizedBox(height: size.width * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      context
                          .read<HomeBloc>()
                          .userData!
                          .bannerImage
                          .data
                          .length,
                      (index) {
                        return Container(
                          margin: EdgeInsets.only(right: size.width * 0.015),
                          height: size.width * 0.015,
                          width: context.read<HomeBloc>().bannerIndex == index
                              ? size.width * 0.04
                              : size.width * 0.015,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.01),
                            color: context.read<HomeBloc>().bannerIndex == index
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.3),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        ));
  }
}
