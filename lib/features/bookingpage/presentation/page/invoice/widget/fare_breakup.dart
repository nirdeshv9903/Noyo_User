import 'package:flutter/material.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';

class FareBreakup extends StatelessWidget {
  final String text;
  final String price;
  final Color? textcolor;
  final Color? pricecolor;
  final dynamic fntweight;
  final dynamic showBorder;
  final dynamic padding;
  const FareBreakup(
      {super.key,
      required this.text,
      required this.price,
      this.textcolor,
      this.pricecolor,
      this.fntweight,
      this.showBorder,
      this.padding});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
          top: padding ?? size.width * 0.025,
          bottom: padding ?? size.width * 0.025),
      decoration: BoxDecoration(
          border: (showBorder == null || showBorder == true)
              ? Border(
                  bottom: BorderSide(
                      color: Theme.of(context)
                          .dividerColor
                          .withAlpha((0.2 * 255).toInt())))
              : (showBorder == 'top')
                  ? Border(
                      top: BorderSide(
                          color: AppColors.textSelectionColor
                              .withAlpha((0.5 * 255).toInt())))
                  : const Border()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: size.width * 0.6,
            child: MyText(
              text: text,
              textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.04,
                  color: textcolor ?? Theme.of(context).primaryColorDark),
              maxLines: 5,
            ),
          ),
          SizedBox(
            width: size.width * 0.25,
            child: MyText(
              text: price,
              maxLines: 2,
              textAlign: TextAlign.right,
              textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.04,
                  color: pricecolor ?? Theme.of(context).primaryColorDark),
            ),
          ),
        ],
      ),
    );
  }
}
