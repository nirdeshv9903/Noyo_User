import 'package:flutter/material.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';

class EditOptions extends StatelessWidget {
  final String text;
  final String header;
  final Function()? onTap;
  final Icon? icon;

  const EditOptions(
      {super.key,
      required this.text,
      required this.header,
      required this.onTap,
      this.icon});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bool showEditIcon = header == AppLocalizations.of(context)!.name ||
        header == AppLocalizations.of(context)!.gender ||
        header == AppLocalizations.of(context)!.emailAddress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: header,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    MyText(
                      text: text,
                      maxLines: 5,
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).disabledColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
              (showEditIcon)
                  ? InkWell(
                      onTap: onTap,
                      highlightColor:
                          Theme.of(context).disabledColor.withAlpha((0.1 * 255).toInt()),
                      splashColor:
                          Theme.of(context).disabledColor.withAlpha((0.2 * 255).toInt()),
                      hoverColor:
                          Theme.of(context).disabledColor.withAlpha((0.05 * 255).toInt()),
                      child: Icon(
                        Icons.edit,
                        size: 15,
                        color: Theme.of(context).disabledColor,
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ),
        const SizedBox(height: 5),
        const Divider(
          height: 1,
          color: Color(0xFFD9D9D9),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}
