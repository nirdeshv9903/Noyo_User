import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_background.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../language/presentation/page/choose_language_page.dart';
import '../../application/auth_bloc.dart';

class AuthBodyWidget extends StatelessWidget {
  final BuildContext cont;
  const AuthBodyWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AuthBloc>(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return CustomBackground(
            child: Column(
              children: [
                // Language Selector
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.04),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
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
                                    .read<AuthBloc>()
                                    .add(GetDirectionEvent());
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03,
                              vertical: size.width * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                MyText(
                                  text: context
                                      .read<AuthBloc>()
                                      .languageCode
                                      .toUpperCase(),
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                                SizedBox(width: size.width * 0.01),
                                Icon(
                                  Icons.language_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                // Carousel Section
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CarouselSlider(
                        items: context.read<AuthBloc>().splashImages,
                        options: CarouselOptions(
                          height: double.infinity,
                          aspectRatio: 16 / 9,
                          viewportFraction: 1,
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
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom spacing for bottom sheet
                SizedBox(height: size.width * 0.04),
              ],
            ),
          );
        },
      ),
    );
  }
}
