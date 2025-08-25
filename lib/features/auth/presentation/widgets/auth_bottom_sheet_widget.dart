import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../account/presentation/pages/settings/page/terms_privacy_policy_view_page.dart';

class AuthBottomSheetWidget extends StatefulWidget {
  final TextEditingController emailOrMobile;
  final dynamic continueFunc;
  final bool showLoginBtn;
  final bool isLoginByEmail;
  final Function()? onTapEvent;
  final Function(String)? onChangeEvent;
  final Function(String)? onSubmitEvent;
  final Function()? countrySelectFunc;
  final GlobalKey<FormState> formKey;
  final String dialCode;
  final String flagImage;
  final FocusNode focusNode;
  final bool isShowLoader;
  const AuthBottomSheetWidget(
      {super.key,
      required this.emailOrMobile,
      required this.continueFunc,
      required this.showLoginBtn,
      required this.isLoginByEmail,
      this.onTapEvent,
      this.onChangeEvent,
      this.onSubmitEvent,
      required this.formKey,
      required this.dialCode,
      required this.flagImage,
      this.countrySelectFunc,
      required this.focusNode,
      required this.isShowLoader});

  @override
  State<StatefulWidget> createState() => AuthBottomSheetWidgetState();
}

class AuthBottomSheetWidgetState extends State<AuthBottomSheetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.linearToEaseOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continuePressed() {
    _controller.forward();
  }

  _closeDialog() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Container(
          height: widget.showLoginBtn ? size.height * 0.42 : size.height * 0.28,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    height: 4,
                    width: size.width * 0.15,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: size.width * 0.04),
                
                // Welcome Header
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: MyText(
                        text: '${AppLocalizations.of(context)!.welcome}, ${AppLocalizations.of(context)!.user}',
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleLarge?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColorDark,
                            ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    SvgPicture.asset(AppImages.hi, height: 24, width: 30)
                  ],
                ),
                SizedBox(height: size.width * 0.06),
                
                // Input Field Label
                MyText(
                  text: '${AppLocalizations.of(context)!.email}/${AppLocalizations.of(context)!.mobile}',
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: size.width * 0.03),
                
                // Input Field
                Form(
                  key: widget.formKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CustomTextField(
                      controller: widget.emailOrMobile,
                      filled: false,
                      focusNode: widget.focusNode,
                      hintText: AppLocalizations.of(context)!.emailAddressOrMobileNumber,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.width * 0.035,
                      ),
                      prefixConstraints: BoxConstraints(maxWidth: size.width * 0.25),
                      prefixIcon: !widget.isLoginByEmail
                          ? Container(
                              margin: EdgeInsets.only(left: size.width * 0.02),
                              child: InkWell(
                                onTap: widget.countrySelectFunc,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.02,
                                    vertical: size.width * 0.015,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 25,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: widget.flagImage,
                                          fit: BoxFit.fill,
                                          placeholder: (context, url) => const Center(
                                            child: Loader(),
                                          ),
                                          errorWidget: (context, url, error) => const Center(
                                            child: Text(""),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.01),
                                      MyText(
                                        text: widget.dialCode,
                                        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : null,
                      onTap: widget.onTapEvent,
                      onSubmitted: widget.onSubmitEvent,
                      onChange: widget.onChangeEvent,
                      validator: (value) {
                        if (value!.isNotEmpty &&
                            !AppValidation.emailValidate(value) &&
                            !AppValidation.mobileNumberValidate(value)) {
                          return AppLocalizations.of(context)!.validEmailMobile;
                        } else if (value.isEmpty) {
                          return AppLocalizations.of(context)!.enterEmailMobile;
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                ),
                
                SizedBox(height: size.width * 0.06),
                
                // Continue Button
                Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.emailOrMobile.text.isEmpty)
                            ? Colors.transparent
                            : Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomButton(
                    buttonName: AppLocalizations.of(context)!.continueN,
                    borderRadius: 16,
                    width: size.width,
                    height: size.width * 0.12,
                    textColor: AppColors.white,
                    buttonColor: (widget.emailOrMobile.text.isEmpty)
                        ? Theme.of(context).primaryColor.withOpacity(0.3)
                        : null,
                    onTap: () {
                      if (widget.formKey.currentState!.validate() &&
                          widget.emailOrMobile.text.isNotEmpty) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _continuePressed();
                      }
                    },
                  ),
                ),
                
                SizedBox(height: size.width * 0.04),
                
                // Terms and Privacy Policy
                Container(
                  width: size.width,
                  padding: EdgeInsets.all(size.width * 0.03),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      MyText(
                        text: '${AppLocalizations.of(context)!.byContinuing} ',
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodySmall?.copyWith(
                              color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                            ),
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.pushNamed(
                              context, TermsPrivacyPolicyViewPage.routeName,
                              arguments: TermsAndPrivacyPolicyArguments(
                                  isPrivacyPolicy: false,
                                  url: AppConstants.termsCondition));
                        },
                        child: MyText(
                          text: '${AppLocalizations.of(context)!.terms} ',
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                      ),
                      MyText(
                        text: AppLocalizations.of(context)!.and,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodySmall?.copyWith(
                              color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                            ),
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.pushNamed(
                              context, TermsPrivacyPolicyViewPage.routeName,
                              arguments: TermsAndPrivacyPolicyArguments(
                                  isPrivacyPolicy: true,
                                  url: AppConstants.privacyPolicy));
                        },
                        child: MyText(
                          text: '${AppLocalizations.of(context)!.privacyPolicy} ',
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.04),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0.05),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Contact Info Display
                          Container(
                            padding: EdgeInsets.all(size.width * 0.04),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if(!widget.isLoginByEmail) ...[
                                  MyText(
                                    text: widget.dialCode,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium?.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                  ),
                                  SizedBox(width: size.width * 0.01),
                                ],
                                Expanded(
                                  child: MyText(
                                    text: widget.emailOrMobile.text,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium?.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).primaryColorDark,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.width * 0.04),
                          
                          // Confirmation Text
                          MyText(
                            text: AppLocalizations.of(context)!.isThisCorrect,
                            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.width * 0.02),
                          
                          // Edit Link
                          InkWell(
                            onTap: _closeDialog,
                            child: MyText(
                              text: AppLocalizations.of(context)!.edit,
                              textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          SizedBox(height: size.width * 0.04),
                          
                          // Continue Button
                          Container(
                            width: size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CustomButton(
                              buttonName: AppLocalizations.of(context)!.continueN,
                              borderRadius: 16,
                              width: size.width,
                              height: size.width * 0.12,
                              isLoader: widget.isShowLoader,
                              onTap: widget.continueFunc,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
