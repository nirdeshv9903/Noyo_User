import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_appbar.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../auth/application/auth_bloc.dart';
import '../../../../application/acc_bloc.dart';
import '../widget/add_money_wallet_widget.dart';
import '../widget/card_list_widget.dart';
import '../widget/wallet_history_list_widget.dart';
import '../widget/wallet_history_shimmer.dart';
import '../widget/wallet_payment_gateway_list_widget.dart';
import '../widget/wallet_transfer_money_widget.dart';
import '../widget/web_view_page.dart';

class WalletHistoryPage extends StatelessWidget {
  static const String routeName = '/walletHistory';
  final WalletPageArguments arg;

  const WalletHistoryPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => AccBloc()..add(WalletPageInitEvent(arg: arg)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          final accBloc = context.read<AccBloc>();
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          } else if (state is MoneyTransferedSuccessState) {
            Navigator.pop(context);
          } else if (state is AddMoneyWebViewUrlState) {
            Navigator.pushNamed(
              context,
              WebViewPage.routeName,
            );
          } else if (state is WalletPageReUpdateState) {
            accBloc.showRefresh = true;
            accBloc.add(AddMoneyWebViewUrlEvent(
                currencySymbol: state.currencySymbol.toString(),
                from: '',
                money: state.money,
                url: state.url,
                userId: state.userId,
                requestId: state.requestId,
                context: context,
              ),
            );
          } else if (state is ShowPaymentGatewayState) {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                enableDrag: true,
                isDismissible: true,
                builder: (_) {
                  return WalletPaymentGatewayListWidget(
                      cont: context,
                      walletPaymentGatways:
                          accBloc.walletPaymentGatways);
                });
          } else if (state is PaymentUpdateState) {
            if (state.status) {
              showDialog(
                context: context,
                barrierDismissible:
                    false, // Prevents closing the dialog by tapping outside
                builder: (_) {
                  return AlertDialog(
                    content: SizedBox(
                      height: size.height * 0.4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppImages.paymentSuccess,
                            fit: BoxFit.contain,
                            width: size.width * 0.5,
                          ),
                          SizedBox(height: size.width * 0.02),
                          Text(
                            AppLocalizations.of(context)!.paymentSuccess,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.width * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              accBloc.add(
                                    GetWalletHistoryListEvent(pageIndex: 1),
                                  );
                            },
                            child: Text(AppLocalizations.of(context)!.okText),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              showDialog(
                context: context,
                barrierDismissible:
                    false, // Prevents closing the dialog by tapping outside
                builder: (_) {
                  return AlertDialog(
                    content: SizedBox(
                      height: size.height * 0.45,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppImages.paymentFail,
                            fit: BoxFit.contain,
                            width: size.width * 0.4,
                          ),
                          SizedBox(height: size.width * 0.02),
                          Text(
                            AppLocalizations.of(context)!.paymentFailed,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.width * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(AppLocalizations.of(context)!.okText),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          return Scaffold(
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.wallet,
              automaticallyImplyLeading: true,
            ),
            body: RefreshIndicator(
              onRefresh: () {
                Future<void> onrefresh() async{
                  accBloc.add(GetWalletHistoryListEvent(pageIndex: 1));                     
                }
                return onrefresh();
              },
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(height: size.width * 0.03),
                      if(accBloc.showRefresh)...[
                        InkWell(
                          onTap: () {
                            accBloc.showRefresh = false;
                            accBloc.add(GetWalletHistoryListEvent(pageIndex: 1));
                          },
                          child: Column(
                            children: [
                              const Icon(Icons.refresh_outlined),
                              SizedBox(height: size.width * 0.01),
                              MyText(text: AppLocalizations.of(context)!.refresh,
                              textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!),
                              SizedBox(height: size.width * 0.02),
                            ],
                          ),
                        )
                      ],
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: size.width * 0.05),
                            MyText(
                                text: AppLocalizations.of(context)!.walletBalance,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: Colors.white, fontSize: 18)),
                            if (accBloc.isLoading &&
                                !accBloc.loadMore)
                              SizedBox(
                                height: size.width * 0.06,
                                width: size.width * 0.06,
                                child: const Loader(
                                  color: AppColors.white,
                                ),
                              ),
                            if (accBloc.walletResponse != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MyText(
                                      text:
                                          '${accBloc.walletResponse!.walletBalance.toString()} ${accBloc.walletResponse!.currencySymbol.toString()}',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(color: Colors.white)),
                                ],
                              ),
                            SizedBox(height: size.width * 0.03),
                            Container(
                              width: size.width,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(5),
                                    bottomRight: Radius.circular(5),
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        context
                                            .read<AccBloc>()
                                            .walletAmountController
                                            .clear();
                                        accBloc.addMoney = null;
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            enableDrag: false,
                                            isDismissible: true,
                                            backgroundColor:
                                                Theme.of(context).shadowColor,
                                            builder: (_) {
                                              return AddMoneyWalletWidget(
                                                  cont: context,
                                                  minWalletAmount: context
                                                      .read<AccBloc>()
                                                      .walletResponse!
                                                      .minimumAmountAddedToWallet);
                                            });
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          MyText(
                                              text: AppLocalizations.of(context)!
                                                  .addMoney,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      color: AppColors.white,
                                                      fontSize: 16)),
                                          SizedBox(width: size.width * 0.02),
                                          Container(
                                            height: size.width * 0.04,
                                            width: size.width * 0.04,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.white,
                                                )),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.add,
                                              size: size.width * 0.03,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (accBloc.userData !=
                                            null &&
                                        context
                                                .read<AccBloc>()
                                                .userData!
                                                .showWalletMoneyTransferFeatureOnMobileApp ==
                                            '1')
                                      InkWell(
                                        onTap: () {
                                          context
                                              .read<AccBloc>()
                                              .transferAmount
                                              .clear();
                                          context
                                              .read<AccBloc>()
                                              .transferPhonenumber
                                              .clear();
                                          accBloc.dropdownValue =
                                              'user';
                                          showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              enableDrag: false,
                                              isDismissible: true,
                                              backgroundColor:
                                                  Theme.of(context).shadowColor,
                                              builder: (_) {
                                                return WalletTransferMoneyWidget(
                                                    cont: context, arg: arg);
                                              });
                                        },
                                        child: Row(
                                          children: [
                                            MyText(
                                                text:
                                                    AppLocalizations.of(context)!
                                                        .transferMoney,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        color: AppColors.white,
                                                        fontSize: 16)),
                                            SizedBox(width: size.width * 0.02),
                                            Container(
                                              height: size.width * 0.04,
                                              width: size.width * 0.04,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColors.white,
                                                  )),
                                              alignment: Alignment.center,
                                              child: Icon(Icons.arrow_downward,
                                                  size: size.width * 0.03,
                                                  color: AppColors.white),
                                            ),
                                          ],
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: size.width,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: size.width * 0.02),
                              if (accBloc.walletResponse !=
                                      null &&
                                  context
                                      .read<AccBloc>()
                                      .walletResponse!
                                      .enableSaveCard) ...[
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, CardListWidget.routeName,
                                        arguments: PaymentMethodArguments(
                                            userData: context
                                                .read<AccBloc>()
                                                .userData!)).then(
                                    (value) {
                                      if (!context.mounted) return;
                                      context.read<AccBloc>().add(
                                          GetWalletHistoryListEvent(
                                              pageIndex: 1));
                                    },
                                  );
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(8),
                                      width: size.width,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .savedCards,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.white,
                                                ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 18,
                                            color: AppColors.white,
                                          )
                                        ],
                                      )),
                                ),
                                SizedBox(height: size.width * 0.02),
                              ],
                              Row(
                                children: [
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .recentTransactions,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.width * 0.025),
                              if (accBloc.isLoading &&
                                  accBloc.firstLoad)
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: 8,
                                    itemBuilder: (context, index) {
                                      return ShimmerWalletHistory(size: size);
                                    },
                                  ),
                                ),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller:
                                      accBloc.scrollController,
                                  child: Column(
                                    children: [
                                      WalletHistoryListWidget(
                                        walletHistoryList: context
                                            .read<AccBloc>()
                                            .walletHistoryList,
                                        cont: context,
                                      ),
                                      if (context
                                              .read<AccBloc>()
                                              .walletHistoryList
                                              .isNotEmpty &&
                                          accBloc.loadMore)
                                        Center(
                                          child: SizedBox(
                                              height: size.width * 0.08,
                                              width: size.width * 0.08,
                                              child:
                                                  const CircularProgressIndicator()),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
