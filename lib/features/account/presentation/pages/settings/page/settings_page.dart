import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_appbar.dart';
import '../../../../../../core/utils/custom_dialoges.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../auth/presentation/pages/auth_page.dart';
import '../../../../application/acc_bloc.dart';
import '../../../widgets/page_options.dart';
import 'delete_account.dart';
import 'faq_page.dart';
import 'map_settings.dart';
import 'terms_privacy_policy_view_page.dart';

class SettingsPage extends StatelessWidget {
  static const String routeName = '/settingsPage';
  final SettingsPageArguments args;
  const SettingsPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(GetAppVersionEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is DeleteAccountLoadingState) {
            CustomLoader.loader(context);
          } else if (state is DeleteAccountFailureState) {
            CustomLoader.dismiss(context);
          } else if (state is LogoutSuccess) {
            Navigator.pushNamedAndRemoveUntil(
                context, AuthPage.routeName, (route) => false);
            await AppSharedPreference.setLoginStatus(false);
            await AppSharedPreference.setToken('');
          } else if (state is DeleteAccountSuccess) {
            CustomLoader.dismiss(context);
            Navigator.pushNamed(context, DeleteAccount.routeName);
            await AppSharedPreference.setLoginStatus(false);
            await AppSharedPreference.setToken('');
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          return Directionality(
              textDirection: context.read<AccBloc>().textDirection == 'rtl'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                appBar: CustomAppBar(
                  title: AppLocalizations.of(context)!.settings,
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.03),
                      PageOptions(
                        label: 'Theme',
                        icon: Theme.of(context).brightness == Brightness.dark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        showTheme: true,
                        onTap: () {},
                      ),
                      // If you comment this, also change in HomeBloc GetUserDetails change MapType
                      if (args.userData.enableMapAppearanceChange == '1')
                        PageOptions(
                          label: AppLocalizations.of(context)!.mapAppearance,
                          icon: Icons.map,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              MapSettingsPage.routeName,
                            );
                          },
                        ),
                      PageOptions(
                        label: AppLocalizations.of(context)!.faq,
                        icon: Icons.question_answer,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            FaqPage.routeName,
                          );
                        },
                      ),
                      PageOptions(
                        label:
                            AppLocalizations.of(context)!.privacyPolicyAccounts,
                        icon: Icons.privacy_tip,
                        onTap: () async {
                          const browseUrl = AppConstants.privacyPolicy;

                          Navigator.pushNamed(
                              context, TermsPrivacyPolicyViewPage.routeName,
                              arguments: TermsAndPrivacyPolicyArguments(
                                  isPrivacyPolicy: true, url: browseUrl));
                        },
                      ),
                      PageOptions(
                        label: AppLocalizations.of(context)!.logout,
                        icon: Icons.logout,
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Theme.of(context).shadowColor,
                            builder: (BuildContext _) {
                              return BlocProvider.value(
                                value: BlocProvider.of<AccBloc>(context),
                                child: CustomDoubleButtonDialoge(
                                  title: AppLocalizations.of(context)!
                                      .comeBackSoon,
                                  content:
                                      AppLocalizations.of(context)!.logoutText,
                                  noBtnName: AppLocalizations.of(context)!.no,
                                  yesBtnName: AppLocalizations.of(context)!.yes,
                                  yesBtnFunc: () {
                                    context.read<AccBloc>().add(LogoutEvent());
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                      PageOptions(
                        label: AppLocalizations.of(context)!.deleteAccount,
                        icon: Icons.delete,
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Theme.of(context).shadowColor,
                            builder: (BuildContext _) {
                              return BlocProvider.value(
                                value: BlocProvider.of<AccBloc>(context),
                                child: CustomSingleButtonDialoge(
                                  title:
                                      '${AppLocalizations.of(context)!.deleteAccount} ?',
                                  content:
                                      AppLocalizations.of(context)!.deleteText,
                                  btnName: AppLocalizations.of(context)!
                                      .deleteAccount,
                                  btnColor: AppColors.errorLight,
                                  onTap: () {
                                    context
                                        .read<AccBloc>()
                                        .add(DeleteAccountEvent());
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const Spacer(),
                      Center(
                          child: MyText(
                        text: 'V ${accBloc.appVersion}',
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Theme.of(context).dividerColor),
                      )),
                      SizedBox(height: size.width * 0.05),
                    ],
                  ),
                ),
              ));
        }),
      ),
    );
  }
}
