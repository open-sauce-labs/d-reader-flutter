import 'package:d_reader_flutter/core/providers/auth_provider.dart';
import 'package:d_reader_flutter/core/providers/solana_client_provider.dart';
import 'package:d_reader_flutter/core/services/d_reader_wallet_service.dart';
import 'package:d_reader_flutter/ui/widgets/common/buttons/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana/solana.dart';

class WelcomeView extends ConsumerWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoundedButton(
            text: 'Connect',
            size: const Size(150, 45),
            onPressed: () async {
              await ref.read(solanaProvider.notifier).authorize();
              final Ed25519HDPublicKey publicKey = Ed25519HDPublicKey(
                  ref.read(solanaProvider).authorizationResult!.publicKey);
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
              await ref.read(authProvider.notifier).storeToken(token);
            },
          ),
        ],
      ),
    );
  }
}
