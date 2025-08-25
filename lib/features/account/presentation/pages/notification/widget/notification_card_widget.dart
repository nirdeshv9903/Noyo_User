import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_dialoges.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/notifications_model.dart';

class NotificationCardWidget extends StatelessWidget {
  final BuildContext cont;
  final NotificationData notification;
  const NotificationCardWidget(
      {super.key, required this.cont, required this.notification});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return Container(
            margin: EdgeInsets.only(bottom: size.width * 0.05),
            padding: EdgeInsets.all(size.width * 0.025),
            decoration: BoxDecoration(
                color: AppColors.darkGrey.withAlpha((0.15 * 255).toInt()),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    width: size.width * 0.0025, color: AppColors.darkGrey)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: Theme.of(context).primaryColorDark,
                            size: 18,
                          ),
                          SizedBox(
                            width: size.width * 0.02,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: notification.title,
                                  textStyle:
                                      Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 5,
                                ),
                                MyText(
                                  text: notification.body,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color:
                                              Theme.of(context).disabledColor),
                                  maxLines: 150,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            MyText(
                              text:
                                  notification.convertedCreatedAt.split(' ')[0],
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context).disabledColor),
                            ),
                            MyText(
                              text:
                                  notification.convertedCreatedAt.split(' ')[1],
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context).disabledColor),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: size.width * 0.01,
                        ),
                        Container(
                            height: size.width * 0.1,
                            width: size.width * 0.002,
                            color: Theme.of(context).disabledColor),
                        SizedBox(
                          width: size.width * 0.01,
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext _) {
                                return BlocProvider.value(
                                  value: BlocProvider.of<AccBloc>(context),
                                  child: CustomSingleButtonDialoge(
                                    title: AppLocalizations.of(context)!
                                        .deleteNotification,
                                    content: AppLocalizations.of(context)!
                                        .deleteNotificationText,
                                    btnName:
                                        AppLocalizations.of(context)!.confirm,
                                    onTap: () {
                                      context.read<AccBloc>().add(
                                          DeleteNotificationEvent(
                                              id: notification.id));
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          child: Icon(Icons.cancel_rounded,
                              color: Theme.of(context).disabledColor),
                        )
                      ],
                    ),
                  ],
                ),
                notification.image != null && notification.image!.isNotEmpty
                    ? Column(
                        children: [
                          SizedBox(height: size.height * 0.01),
                          CachedNetworkImage(
                            imageUrl: notification.image!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: Loader(),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Text(""),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox()
              ],
            ),
          );
        },
      ),
    );
  }
}
