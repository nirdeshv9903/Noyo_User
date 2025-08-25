import 'package:flutter/material.dart';

import 'custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackTap;
  final Color? backgroundColor;
  final Color? textColor;
  final bool centerTitle;
  final bool? automaticallyImplyLeading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double? leadingWidth;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackTap,
    this.backgroundColor,
    this.textColor,
    this.centerTitle = true,
    this.automaticallyImplyLeading,
    this.actions,
    this.bottom,
    this.leadingWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Use theme colors if not explicitly provided
    final effectiveBackgroundColor =
        backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor;
    final effectiveTextColor =
        textColor ?? Theme.of(context).appBarTheme.foregroundColor;

    return AppBar(
      backgroundColor: effectiveBackgroundColor,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      title: MyText(
        text: title,
        textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: effectiveTextColor,
              fontWeight: FontWeight.w600,
            ),
      ),
      centerTitle: centerTitle,
      leadingWidth: leadingWidth,
      leading:
          ((automaticallyImplyLeading != null && automaticallyImplyLeading!) ||
                  automaticallyImplyLeading == null)
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: effectiveTextColor),
                  onPressed: onBackTap ?? () => Navigator.pop(context),
                )
              : null,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      bottom != null ? bottom!.preferredSize.height : kToolbarHeight);
}
