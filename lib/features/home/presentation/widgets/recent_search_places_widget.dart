import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/custom_text.dart';
import '../../application/home_bloc.dart';

class RecentSearchPlacesWidget extends StatelessWidget {
  final BuildContext cont;
  const RecentSearchPlacesWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              itemCount: context.read<HomeBloc>().recentSearchPlaces.length > 2
                  ? 2
                  : context.read<HomeBloc>().recentSearchPlaces.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(size.width * 0.03),
              itemBuilder: (context, index) {
                final recentPlace = context
                    .read<HomeBloc>()
                    .recentSearchPlaces
                    .reversed
                    .elementAt(index);
                return InkWell(
                  onTap: () {
                    if (context.read<HomeBloc>().pickupAddressList.isNotEmpty) {
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
                            RecentSearchPlaceSelectEvent(
                                address: recentPlace,
                                isPickupSelect: false,
                                transportType: 'taxi'));
                      } else {
                        context
                            .read<HomeBloc>()
                            .add(ServiceTypeChangeEvent(serviceTypeIndex: 1));
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.03,
                      vertical: size.width * 0.025,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: size.width * 0.08,
                          width: size.width * 0.08,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.history,
                            size: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(width: size.width * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MyText(
                                text: recentPlace.address.split(',')[0],
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                maxLines: 1,
                              ),
                              SizedBox(height: size.width * 0.005),
                              MyText(
                                text: recentPlace.address,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .primaryColorDark
                                          .withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context)
                              .primaryColorDark
                              .withOpacity(0.4),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
