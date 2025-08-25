import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../loading/application/loader_bloc.dart';
import '../../application/auth_bloc.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

class VerifyPage extends StatefulWidget {
  static const String routeName = '/verifyPage';
  final VerifyArguments arg;
  const VerifyPage({super.key, required this.arg});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage>
    with SingleTickerProviderStateMixin {
  Timer? timer;
  timerCount(BuildContext cont,
      {required int duration, bool? isCloseTimer}) async {
    int count = duration;

    if (isCloseTimer == null) {
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        count--;
        if (count <= 0) {
          timer?.cancel();
        }
        cont.read<AuthBloc>().add(VerifyTimerEvent(duration: count));
      });
    }

    if (isCloseTimer != null && isCloseTimer) {
      timer?.cancel();
      cont.read<AuthBloc>().add(VerifyTimerEvent(duration: 0));
    }
  }

  @override
  void dispose() {
    if (timer != null) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()
        ..add(GetDirectionEvent())
        ..add(GetCommonModuleEvent()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          } else if (state is AuthDataLoadingState) {
            CustomLoader.loader(context);
          } else if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
            if (!widget.arg.userExist && widget.arg.isOtpVerify) {
              context.read<AuthBloc>().add(
                    SignInWithOTPEvent(
                      isOtpVerify: widget.arg.isOtpVerify,
                      isForgotPassword: false,
                      mobileOrEmail: widget.arg.mobileOrEmail,
                      dialCode: widget.arg.dialCode,
                      isLoginByEmail: widget.arg.isLoginByEmail,
                      context: context,
                    ),
                  );
              timerCount(context, duration: 60);
            }
          } else if (state is ForgotPasswordOTPSendState) {
            Navigator.pushNamed(
              context,
              ForgotPasswordPage.routeName,
              arguments: ForgotPasswordPageArguments(
                isLoginByEmail: widget.arg.isLoginByEmail,
                contryCode: widget.arg.dialCode,
                countryFlag: widget.arg.countryFlag,
                emailOrMobile: widget.arg.mobileOrEmail,
              ),
            );
          } else if (state is NewUserRegisterState) {
            Navigator.pushNamed(context, RegisterPage.routeName,
                arguments: RegisterPageArguments(
                  isLoginByEmail: widget.arg.isLoginByEmail,
                  dialCode: widget.arg.dialCode,
                  contryCode: widget.arg.countryCode,
                  countryFlag: widget.arg.countryFlag,
                  emailOrMobile: widget.arg.mobileOrEmail,
                  countryList: widget.arg.countryList,
                  isRefferalEarnings: widget.arg.isRefferalEarnings,
                ));
          } else if (state is LoginSuccessState ||
              state is ConfirmMobileOrEmailState) {
            context.read<LoaderBloc>().add(UpdateUserLocationEvent());
            Navigator.pushNamedAndRemoveUntil(
                context, HomePage.routeName, (route) => false);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Directionality(
                textDirection: context.read<AuthBloc>().textDirection == 'rtl'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Scaffold(
                  body: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.backgroundGradient,
                    ),
                    child: SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top -
                                MediaQuery.of(context).padding.bottom,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.1),

                                  // Header Section
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        const BoxShadow(
                                          color: AppColors.shadow,
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.verified_user,
                                          size: 48,
                                          color: AppColors.white,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          context.read<AuthBloc>().isOtpVerify
                                              ? 'Verify OTP'
                                              : 'Enter Password',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        context.read<AuthBloc>().isOtpVerify
                                            ? Text(
                                                AppLocalizations.of(context)!
                                                    .otpSendContent,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      color: AppColors.white
                                                          .withValues(
                                                              alpha: 0.9),
                                                    ),
                                              )
                                            : Text(
                                                AppLocalizations.of(context)!
                                                    .passwordContent,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      color: AppColors.white
                                                          .withValues(
                                                              alpha: 0.9),
                                                    ),
                                                maxLines: 2,
                                              ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Contact Info Section
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border:
                                          Border.all(color: AppColors.border),
                                    ),
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        if (!widget.arg.isLoginByEmail)
                                          SizedBox(
                                            height: 20,
                                            width: 30,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    widget.arg.countryFlag,
                                                fit: BoxFit.fill,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                  child: Loader(),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Center(
                                                  child: Text(""),
                                                ),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 10),
                                        Text(
                                          widget.arg.mobileOrEmail,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        const SizedBox(width: 10),
                                        InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .change,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Input Fields
                                  if (widget.arg.userExist &&
                                      !context.read<AuthBloc>().isOtpVerify)
                                    passwordField(context),
                                  if (!widget.arg.userExist ||
                                      context.read<AuthBloc>().isOtpVerify)
                                    buildPinField(context),
                                  const SizedBox(height: 20),
                                  buildLoginButton(context),

                                  // Add extra padding at bottom for keyboard
                                  SizedBox(
                                    height: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom >
                                            0
                                        ? MediaQuery.of(context)
                                                .viewInsets
                                                .bottom +
                                            20
                                        : 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget passwordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.password,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            InkWell(
              onTap: () {
                context.read<AuthBloc>().isOtpVerify = true;
                context.read<AuthBloc>().add(SignInWithOTPEvent(
                      isOtpVerify: true,
                      isForgotPassword: false,
                      dialCode: widget.arg.dialCode,
                      mobileOrEmail: widget.arg.mobileOrEmail,
                      isLoginByEmail: widget.arg.isLoginByEmail,
                      context: context,
                    ));

                timerCount(context, duration: 60);
              },
              child: Text(
                AppLocalizations.of(context)!.signInUsingOtp,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: context.read<AuthBloc>().passwordController,
          filled: true,
          obscureText: !context.read<AuthBloc>().showPassword,
          hintText: AppLocalizations.of(context)!.enterYourPassword,
          suffixIcon: InkWell(
            onTap: () {
              context.read<AuthBloc>().add(ShowPasswordIconEvent(
                  showPassword: context.read<AuthBloc>().showPassword));
            },
            child: !context.read<AuthBloc>().showPassword
                ? const Icon(
                    Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  )
                : const Icon(
                    Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            context.read<AuthBloc>().add(
                  SignInWithOTPEvent(
                    isOtpVerify: true,
                    isForgotPassword: true,
                    mobileOrEmail: widget.arg.mobileOrEmail,
                    dialCode: widget.arg.dialCode,
                    isLoginByEmail: widget.arg.isLoginByEmail,
                    context: context,
                  ),
                );
          },
          child: Text(
            '${AppLocalizations.of(context)!.forgetPassword} ?',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget buildPinField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.enterOtp,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            if (widget.arg.userExist &&
                context.read<AuthBloc>().timerDuration == 0)
              InkWell(
                onTap: () {
                  context.read<AuthBloc>().isOtpVerify = false;
                  timerCount(context, duration: 0, isCloseTimer: true);
                },
                child: Text(
                  AppLocalizations.of(context)!.signInUsingPass,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        PinCodeTextField(
          appContext: context,
          controller: context.read<AuthBloc>().otpController,
          textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
          length: 6,
          obscureText: false,
          blinkWhenObscuring: false,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(12),
            fieldHeight: 50,
            fieldWidth: 50,
            activeFillColor: AppColors.surface,
            inactiveFillColor: AppColors.surface,
            inactiveColor: AppColors.border,
            selectedFillColor: AppColors.surface,
            selectedColor: AppColors.primary,
            selectedBorderWidth: 2,
            inactiveBorderWidth: 1,
            activeBorderWidth: 2,
            activeColor: AppColors.primary,
          ),
          cursorColor: AppColors.primary,
          animationDuration: const Duration(milliseconds: 300),
          enableActiveFill: true,
          enablePinAutofill: false,
          autoDisposeControllers: false,
          keyboardType: TextInputType.number,
          boxShadows: [
            const BoxShadow(
              offset: Offset(0, 2),
              color: AppColors.shadow,
              blurRadius: 8,
            )
          ],
          beforeTextPaste: (_) => false,
          onChanged: (_) => context.read<AuthBloc>().add(OTPOnChangeEvent()),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: context.read<AuthBloc>().timerDuration != 0
              ? null
              : () {
                  context.read<AuthBloc>().add(
                        SignInWithOTPEvent(
                          isOtpVerify: true,
                          isForgotPassword: false,
                          dialCode: widget.arg.dialCode,
                          mobileOrEmail: widget.arg.mobileOrEmail,
                          isLoginByEmail: widget.arg.isLoginByEmail,
                          context: context,
                        ),
                      );
                  timerCount(context, duration: 60);
                },
          child: Text(
            context.read<AuthBloc>().timerDuration != 0
                ? '${AppLocalizations.of(context)!.resendOtp} 00:${context.read<AuthBloc>().timerDuration}'
                : AppLocalizations.of(context)!.resendOtp,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.read<AuthBloc>().timerDuration != 0
                      ? AppColors.textTertiary
                      : AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: CustomButton(
            borderRadius: 12,
            height: MediaQuery.of(context).size.height * 0.06,
            buttonName: (!widget.arg.userExist)
                ? AppLocalizations.of(context)!.confirm
                : AppLocalizations.of(context)!.login,
            isLoader: context.read<AuthBloc>().isLoading,
            onTap: () {
              if (widget.arg.isOtpVerify ||
                  context.read<AuthBloc>().isOtpVerify) {
                // OTPverify
                context.read<AuthBloc>().add(
                      ConfirmOrVerifyOTPEvent(
                        isUserExist: widget.arg.userExist,
                        isLoginByEmail: widget.arg.isLoginByEmail,
                        isOtpVerify: context.read<AuthBloc>().isOtpVerify,
                        isForgotPasswordVerify: false,
                        mobileOrEmail: widget.arg.mobileOrEmail,
                        otp: context.read<AuthBloc>().otpController.text,
                        password:
                            context.read<AuthBloc>().passwordController.text,
                        firebaseVerificationId:
                            context.read<AuthBloc>().firebaseVerificationId,
                        context: context,
                      ),
                    );
              } else {
                // PasswordLogin
                context.read<AuthBloc>().add(LoginUserEvent(
                      emailOrMobile: widget.arg.mobileOrEmail,
                      otp: context.read<AuthBloc>().otpController.text,
                      password:
                          context.read<AuthBloc>().passwordController.text,
                      isOtpLogin: context.read<AuthBloc>().isOtpVerify,
                      isLoginByEmail: widget.arg.isLoginByEmail,
                      context: context,
                    ));
              }
            },
          ),
        );
      },
    );
  }
}
