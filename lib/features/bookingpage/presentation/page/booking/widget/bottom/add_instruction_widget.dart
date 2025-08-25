import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/booking_bloc.dart';

// Instruction
class AddInstructionWidget extends StatelessWidget {
  const AddInstructionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        return SafeArea(
          child: Container(
            width: size.width,
            padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: size.width * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      text: AppLocalizations.of(context)!.addInstructions,
                      textStyle:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                                color: Theme.of(context).primaryColorDark,
                              ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: MyText(text: AppLocalizations.of(context)!.done),
                    )
                  ],
                ),
                SizedBox(height: size.width * 0.03),
                CustomTextField(
                  controller:
                      context.read<BookingBloc>().instructionsController,
                  filled: true,
                  hintText:
                      '${AppLocalizations.of(context)!.instructions}(${AppLocalizations.of(context)!.optional})',
                  maxLine: 3,
                  keyboardType: TextInputType.text,
                  onChange: (p0) {
                    context.read<BookingBloc>().add(UpdateEvent());
                  },
                ),
                SizedBox(height: size.width * 0.03),
                InkWell(
                  onTap: () {
                    context.read<BookingBloc>().instructionsController.text =
                        '';
                    context.read<BookingBloc>().add(UpdateEvent());
                    Navigator.pop(context);
                  },
                  child: MyText(
                    text: AppLocalizations.of(context)!.clear,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
                SizedBox(height: size.width * 0.1),
              ],
            ),
          ),
        );
      },
    );
  }
}
