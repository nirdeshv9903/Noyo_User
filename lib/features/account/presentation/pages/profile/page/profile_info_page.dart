import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_tagxi/core/network/extensions.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_appbar.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../widgets/edit_options.dart';
import 'update_details.dart';

class ProfileInfoPage extends StatelessWidget {
  static const String routeName = '/profileInfoPage';
  final ProfileInfoPageArguments arg;
  const ProfileInfoPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(UserDataInitEvent(userDetails: arg.userData)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is UserProfileDetailsLoadingState) {
            CustomLoader.loader(context);
          } else if (state is UpdateUserDetailsFailureState) {
            context.showSnackBar(
                message: AppLocalizations.of(context)!.failedUpdateDetails);
          } else if (state is UserDetailsUpdatedState) {
            context.read<AccBloc>().userData!.name = state.name;
            context.read<AccBloc>().userData!.email = state.email;
            context.read<AccBloc>().userData!.gender = state.gender;
            context.read<AccBloc>().userData!.profilePicture =
                state.profileImage;
          } else if (state is UserDetailEditState) {
            Navigator.pushNamed(
              context,
              UpdateDetails.routeName,
              arguments: UpdateDetailsArguments(
                  header: state.header,
                  text: state.text,
                  userData: context.read<AccBloc>().userData!),
            ).then(
              (value) {
                if (!context.mounted) return;
                if (value != null) {
                  final data = value as UserDetailsUpdatedState;
                  context.read<AccBloc>().userData!.name = data.name;
                  context.read<AccBloc>().userData!.email = data.email;
                  context.read<AccBloc>().userData!.gender = data.gender;
                  context.read<AccBloc>().userData!.profilePicture =
                      data.profileImage;
                  context.read<AccBloc>().add(AccUpdateEvent());
                }
              },
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            return (context.read<AccBloc>().userData != null)
                ? Directionality(
                    textDirection:
                        context.read<AccBloc>().textDirection == 'rtl'
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                    child: Scaffold(
                      appBar: CustomAppBar(
                        title:
                            AppLocalizations.of(context)!.personalInformation,
                        automaticallyImplyLeading: true,
                        onBackTap: () {
                          Navigator.pop(
                              context, context.read<AccBloc>().userData);
                        },
                      ),
                      body: SizedBox(
                        height: size.height * 0.7,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.width * 0.05),
                                Column(
                                  children: [
                                    Center(
                                      child: CircleAvatar(
                                        radius: size.width * 0.1,
                                        backgroundColor:
                                            Theme.of(context).dividerColor,
                                        backgroundImage: context
                                                .read<AccBloc>()
                                                .userData!
                                                .profilePicture
                                                .isNotEmpty
                                            ? NetworkImage(context
                                                .read<AccBloc>()
                                                .userData!
                                                .profilePicture)
                                            : null,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                  onTap: () =>
                                                      _showImageSourceSheet(
                                                          context),
                                                  child: Container(
                                                    height: 25,
                                                    width: 25,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.edit,
                                                        size: 15,
                                                        color: AppColors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: MyText(
                                        text: context
                                            .read<AccBloc>()
                                            .userData!
                                            .name,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                                color: AppColors.white,
                                                fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                EditOptions(
                                  text: context.read<AccBloc>().userData!.name,
                                  header: AppLocalizations.of(context)!.name,
                                  onTap: () {
                                    context.read<AccBloc>().add(
                                        UserDetailEditEvent(
                                            header:
                                                AppLocalizations.of(context)!
                                                    .name,
                                            text: context
                                                .read<AccBloc>()
                                                .userData!
                                                .name));
                                  },
                                ),
                                EditOptions(
                                  text:
                                      context.read<AccBloc>().userData!.mobile,
                                  header: AppLocalizations.of(context)!
                                      .mobileNumber,
                                  onTap: () {},
                                ),
                                EditOptions(
                                  text: context.read<AccBloc>().userData!.email,
                                  header: AppLocalizations.of(context)!
                                      .emailAddress,
                                  onTap: () {
                                    context.read<AccBloc>().add(
                                        UserDetailEditEvent(
                                            header:
                                                AppLocalizations.of(context)!
                                                    .emailAddress,
                                            text: context
                                                .read<AccBloc>()
                                                .userData!
                                                .email));
                                  },
                                ),
                                EditOptions(
                                  text:
                                      context.read<AccBloc>().userData!.gender,
                                  header: AppLocalizations.of(context)!.gender,
                                  onTap: () {
                                    context.read<AccBloc>().add(
                                          UserDetailEditEvent(
                                            header:
                                                AppLocalizations.of(context)!
                                                    .gender,
                                            text: context
                                                .read<AccBloc>()
                                                .userData!
                                                .gender,
                                          ),
                                        );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const Scaffold(
                    body: Loader(),
                  );
          },
        ),
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).splashColor,
      builder: (_) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 1,
                    spreadRadius: 1)
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Theme.of(context).primaryColorDark,
                ),
                title: MyText(
                  text: AppLocalizations.of(context)!.cameraText,
                  textStyle: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).primaryColorDark),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _updateProfileImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  size: 20,
                  color: Theme.of(context).primaryColorDark,
                ),
                title: MyText(
                  text: AppLocalizations.of(context)!.galleryText,
                  textStyle: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).primaryColorDark),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _updateProfileImage(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfileImage(
      BuildContext context, ImageSource source) async {
    final AccBloc accBloc = context.read<AccBloc>();

    accBloc.add(UpdateImageEvent(
      name: accBloc.userData!.name,
      email: accBloc.userData!.email,
      gender: accBloc.userData!.gender,
      source: source,
    ));
    accBloc.add(AccUpdateEvent());
  }
}
