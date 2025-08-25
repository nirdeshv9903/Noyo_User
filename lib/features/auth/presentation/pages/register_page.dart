import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';

import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../loading/application/loader_bloc.dart';
import '../../application/auth_bloc.dart';
import '../widgets/select_country_widget.dart';
import 'refferal_page.dart';

class RegisterPage extends StatelessWidget {
  static const String routeName = '/registerPage';
  final RegisterPageArguments arg;
  const RegisterPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AuthBloc()
        ..add(GetDirectionEvent())
        ..add(RegisterPageInitEvent(arg: arg)),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          }
          if (state is AuthDataLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
          }
          if (state is LoginSuccessState) {
            context.read<LoaderBloc>().add(UpdateUserLocationEvent());
            if (arg.isRefferalEarnings == 1) {
              Navigator.pushNamedAndRemoveUntil(
                  context, RefferalPage.routeName, (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, HomePage.routeName, (route) => false);
            }
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
                              padding: const EdgeInsets.all(20),
                              child: Form(
                                key: context.read<AuthBloc>().formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                            Icons.person_add,
                                            size: 48,
                                            color: AppColors.white,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .register,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: AppColors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Create your account to get started',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: AppColors.white
                                                      .withValues(alpha: 0.9),
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: size.width * 0.08),

                                    // Profile Picture Section
                                    buildProfilePick(size, context),

                                    SizedBox(height: size.width * 0.06),

                                    // Form Fields
                                    Text(
                                      AppLocalizations.of(context)!.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    SizedBox(height: size.width * 0.02),
                                    buildUserNameField(context),

                                    SizedBox(height: size.width * 0.04),

                                    Text(
                                      AppLocalizations.of(context)!.mobile,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    SizedBox(height: size.width * 0.02),
                                    buildMobileField(context, size),

                                    SizedBox(height: size.width * 0.04),

                                    Text(
                                      AppLocalizations.of(context)!.email,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    SizedBox(height: size.width * 0.02),
                                    buildEmailField(context),

                                    SizedBox(height: size.width * 0.04),

                                    Text(
                                      AppLocalizations.of(context)!.gender,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    SizedBox(height: size.width * 0.02),
                                    buildDropDownGenderField(context),

                                    SizedBox(height: size.width * 0.04),

                                    Text(
                                      AppLocalizations.of(context)!.password,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    SizedBox(height: size.width * 0.02),
                                    buildPasswordField(context, size),

                                    SizedBox(height: size.width * 0.08),
                                    buildButton(context),

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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildProfilePick(Size size, BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            height: size.width * 0.25,
            width: size.width * 0.25,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(size.width * 0.125),
              border: Border.all(color: AppColors.border, width: 2),
              boxShadow: [
                const BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size.width * 0.125),
              child: context.read<AuthBloc>().profileImage.isNotEmpty
                  ? Image.file(
                      File(context.read<AuthBloc>().profileImage),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(size.width * 0.125),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(height: size.width * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<AuthBloc>()
                      .add(ImageUpdateEvent(source: ImageSource.camera));
                },
                icon: const Icon(Icons.camera_alt, size: 18),
                label: Text(
                  'Camera',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<AuthBloc>()
                      .add(ImageUpdateEvent(source: ImageSource.gallery));
                },
                icon: const Icon(Icons.photo_library, size: 18),
                label: Text(
                  'Gallery',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context) {
    return Center(
      child: CustomButton(
        buttonName: AppLocalizations.of(context)!.register,
        borderRadius: 12,
        height: MediaQuery.of(context).size.height * 0.06,
        isLoader: context.read<AuthBloc>().isLoading,
        onTap: () {
          if (context.read<AuthBloc>().formKey.currentState!.validate() &&
              !context.read<AuthBloc>().isLoading) {
            context.read<AuthBloc>().add(RegisterUserEvent(
                userName: context.read<AuthBloc>().rUserNameController.text,
                mobileNumber: context.read<AuthBloc>().rMobileController.text,
                emailAddress: context.read<AuthBloc>().rEmailController.text,
                password: context.read<AuthBloc>().rPasswordController.text,
                countryCode: context.read<AuthBloc>().countryCode,
                gender: context.read<AuthBloc>().selectedGender,
                profileImage: context.read<AuthBloc>().profileImage,
                context: context));
          }
        },
      ),
    );
  }

  Widget buildPasswordField(BuildContext context, Size size) {
    return CustomTextField(
      controller: context.read<AuthBloc>().rPasswordController,
      filled: true,
      obscureText: !context.read<AuthBloc>().showPassword,
      hintText: AppLocalizations.of(context)!.enterYourPassword,
      suffixConstraints: BoxConstraints(maxWidth: size.width * 0.2),
      suffixIcon: InkWell(
        onTap: () {
          context.read<AuthBloc>().add(ShowPasswordIconEvent(
              showPassword: context.read<AuthBloc>().showPassword));
        },
        child: !context.read<AuthBloc>().showPassword
            ? const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
              )
            : const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.visibility,
                  color: AppColors.textSecondary,
                ),
              ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return AppLocalizations.of(context)!.enterPassword;
        } else if (value.length < 8) {
          return AppLocalizations.of(context)!.minPassRequired;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildEmailField(BuildContext context) {
    return CustomTextField(
      controller: context.read<AuthBloc>().rEmailController,
      enabled: !context.read<AuthBloc>().isLoginByEmail,
      filled: true,
      fillColor:
          context.read<AuthBloc>().isLoginByEmail ? AppColors.greyLight : null,
      hintText:
          '${AppLocalizations.of(context)!.enterYourEmail} (${AppLocalizations.of(context)!.optional})',
      validator: (value) {
        if (value!.isNotEmpty && !AppValidation.emailValidate(value)) {
          return AppLocalizations.of(context)!.validEmail;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildMobileField(BuildContext context, Size size) {
    return CustomTextField(
      controller: context.read<AuthBloc>().rMobileController,
      filled: true,
      hintText: AppLocalizations.of(context)!.enterYourMobile,
      prefixIcon: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (context.read<AuthBloc>().flagImage.isNotEmpty)
              SizedBox(
                height: 20,
                width: 30,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: context.read<AuthBloc>().flagImage,
                    fit: BoxFit.fill,
                    placeholder: (context, url) => const Center(
                      child: Loader(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Text(""),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Text(
              context.read<AuthBloc>().dialCode,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SelectCountryWidget(
                    countries: arg.countryList,
                    cont: context,
                  ),
                );
              },
              child: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      validator: (value) {
        if (value!.isNotEmpty && !AppValidation.mobileNumberValidate(value)) {
          return AppLocalizations.of(context)!.validMobile;
        } else if (value.isEmpty) {
          return AppLocalizations.of(context)!.enterMobile;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildUserNameField(BuildContext context) {
    return CustomTextField(
      controller: context.read<AuthBloc>().rUserNameController,
      filled: true,
      hintText: AppLocalizations.of(context)!.enterYourName,
      validator: (value) {
        if (value!.isEmpty) {
          return AppLocalizations.of(context)!.enterUserName;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildDropDownGenderField(BuildContext context) {
    List<String> showGenderList = [
      AppLocalizations.of(context)!.male,
      AppLocalizations.of(context)!.female,
      AppLocalizations.of(context)!.preferNotSay,
    ];
    return DropdownButtonFormField<String>(
      value: context.read<AuthBloc>().selectedGender.isEmpty
          ? null
          : context.read<AuthBloc>().selectedGender,
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintText: AppLocalizations.of(context)!.selectGender,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.surface,
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.error, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (context.read<AuthBloc>().selectedGender.isEmpty) {
          return AppLocalizations.of(context)!.requiredField;
        } else {
          return null;
        }
      },
      items: showGenderList.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        context.read<AuthBloc>().selectedGender = newValue ?? '';
      },
    );
  }
}
