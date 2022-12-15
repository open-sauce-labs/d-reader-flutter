import 'package:d_reader_flutter/config/config.dart';
import 'package:d_reader_flutter/core/providers/auth_provider.dart';
import 'package:d_reader_flutter/core/providers/global_provider.dart';
import 'package:d_reader_flutter/core/providers/solana_client_provider.dart';
import 'package:d_reader_flutter/core/services/d_reader_wallet_service.dart';
import 'package:d_reader_flutter/ui/views/splash.dart';
import 'package:d_reader_flutter/ui/widgets/common/buttons/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana/solana.dart';

class WelcomeView extends HookConsumerWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalHook = useGlobalState();
    return globalHook.value.showSplash
        ? const SplashView()
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(Config.logoTextPath),
                const SizedBox(
                  height: 24,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RoundedButton(
                    text: 'Connect',
                    size: const Size(double.infinity, 52),
                    isLoading: globalHook.value.isLoading,
                    fontSize: 24,
                    onPressed: () async {
                      globalHook.value =
                          globalHook.value.copyWith(isLoading: true);
                      await ref.read(solanaProvider.notifier).authorize();
                      final Ed25519HDPublicKey publicKey = Ed25519HDPublicKey(
                        ref.read(solanaProvider).authorizationResult!.publicKey,
                      );
                      DReaderWalletService walletService =
                          DReaderWalletService.instance;
                      final oneTimePassword =
                          await walletService.getOneTimePassword(publicKey);
                      final result = await ref
                          .read(solanaProvider.notifier)
                          .signMessage(oneTimePassword);
                      final String token = await walletService.connectWallet(
                        publicKey,
                        result.first.sublist(
                          result.first.length - 64,
                          result.first.length,
                        ),
                      );

                      globalHook.value = globalHook.value
                          .copyWith(isLoading: false, showSplash: true);
                      Future.delayed(
                          const Duration(
                            milliseconds: 2000,
                          ), () async {
                        globalHook.value = globalHook.value
                            .copyWith(isLoading: false, showSplash: false);
                        await ref.read(authProvider.notifier).storeToken(token);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
