import 'package:d_reader_flutter/core/providers/solana_client_provider.dart';
import 'package:d_reader_flutter/core/services/d_reader_wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana/solana.dart';

class WelcomeView extends ConsumerWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String publicKey =
        ref.watch(solanaProvider).authorizationResult?.publicKey.toString() ??
            '';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () async {
              await ref.read(solanaProvider.notifier).authorize();
            },
            child: const Text('Authorize Wallet'),
          ),
          publicKey.isNotEmpty
              ? TextButton(
                  onPressed: () async {
                    final Ed25519HDPublicKey publicKey = Ed25519HDPublicKey(ref
                        .read(solanaProvider)
                        .authorizationResult!
                        .publicKey);
                    DReaderWalletService walletService =
                        DReaderWalletService.instance;
                    final oneTimePassword =
                        await walletService.getOneTimePassword(publicKey);
                    final result = await ref
                        .read(solanaProvider.notifier)
                        .signMessages([oneTimePassword]);
                    final String token = await walletService.connectWallet(
                      publicKey,
                      result.first,
                    );
                    print('Token: $token');
                  },
                  child: const Text('Connect With Backend'),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
