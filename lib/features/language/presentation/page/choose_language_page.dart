import 'package:flutter/material.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_appbar.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../landing/presentation/page/landing_page.dart';
import '../../application/language_bloc.dart';
import '../../../../app/localization.dart';
import '../../domain/models/language_listing_model.dart';

class ChooseLanguagePage extends StatelessWidget {
  static const String routeName = '/chooseLanguage';
  final ChooseLanguageArguments arg;

  const ChooseLanguagePage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return builderList(size);
  }

  Widget builderList(Size size) {
    return BlocProvider(
      create: (context) => LanguageBloc()
        ..add(LanguageInitialEvent())
        ..add(LanguageGetEvent(
            isInitialLanguageChange: arg.isInitialLanguageChange)),
      child: BlocListener<LanguageBloc, LanguageState>(
        listener: (context, state) {
          if (state is LanguageInitialState) {
            CustomLoader.loader(context);
          } else if (state is LanguageLoadingState) {
            CustomLoader.loader(context);
          } else if (state is LanguageSuccessState) {
            CustomLoader.dismiss(context);
          } else if (state is LanguageFailureState) {
            CustomLoader.dismiss(context);
          } else if (state is LanguageUpdateState) {
            // Reload the app with the selected language
            if (arg.isInitialLanguageChange) {
              Navigator.pushNamedAndRemoveUntil(
                  context, LandingPage.routeName, (route) => false);
            } else {
              Navigator.pop(context);
            }
          }
        },
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, state) {
            return Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.chooseLanguage,
                automaticallyImplyLeading:
                    arg.isInitialLanguageChange ? false : true,
                onBackTap: () {
                  Navigator.pop(context);
                  context.read<LocalizationBloc>().add(LocalizationInitialEvent(
                      isDark: Theme.of(context).brightness == Brightness.dark,
                      locale: Locale(
                          context.read<LanguageBloc>().choosedLanguage)));
                },
              ),
              body: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.language,
                                size: 48,
                                color: AppColors.white,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Choose Your Language',
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
                                'Select your preferred language for the best experience',
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

                        const SizedBox(height: 24),

                        // Language List Section
                        Text(
                          'Available Languages',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),

                        const SizedBox(height: 16),

                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                buildLanguageList(
                                    size, AppConstants.languageList)
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: size.width * 0.05),
                        confirmButton(size, context),
                        SizedBox(height: size.width * 0.05),
                      ],
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

// Language List
  Widget buildLanguageList(Size size, List<LocaleLanguageList> languageList) {
    return languageList.isNotEmpty
        ? RawScrollbar(
            radius: const Radius.circular(20),
            child: ListView.builder(
              itemCount: languageList.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final isSelected =
                    context.read<LanguageBloc>().selectedIndex == index;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8),
                  child: InkWell(
                    onTap: () {
                      context.read<LanguageBloc>().add(
                          LanguageSelectEvent(selectedLanguageIndex: index));
                      context.read<LocalizationBloc>().add(
                          LocalizationInitialEvent(
                              isDark: Theme.of(context).brightness ==
                                  Brightness.dark,
                              locale: Locale(languageList[index].lang)));
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 60,
                      width: size.width,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 2.0 : 1.0),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: MyText(
                                  text: languageList[index].name,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        : const SizedBox();
  }

  Widget confirmButton(Size size, BuildContext context) {
    return Center(
      child: CustomButton(
        buttonName: AppLocalizations.of(context)!.confirm,
        height: size.width * 0.12,
        width: size.width * 0.85,
        onTap: () async {
          final selectedIndex = context.read<LanguageBloc>().selectedIndex;
          context.read<LanguageBloc>().add(LanguageSelectUpdateEvent(
              selectedLanguage:
                  AppConstants.languageList.elementAt(selectedIndex).lang));
        },
      ),
    );
  }
}
