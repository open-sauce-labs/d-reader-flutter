import 'dart:convert';
import 'dart:typed_data';

import 'package:d_reader_flutter/core/services/d_reader_wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana/solana.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';

final solanaProvider =
    StateNotifierProvider<SolanaClientNotifier, SolanaClientState>(
        (ref) => SolanaClientNotifier(DReaderWalletService.instance));

@immutable // preferred to use immutable states
class SolanaClientState {
  const SolanaClientState({
    this.authorizationResult,
  });
  final AuthorizationResult? authorizationResult;

  SolanaClientState copyWith({
    AuthorizationResult? authorizationResult,
  }) {
    return SolanaClientState(
      authorizationResult: authorizationResult,
    );
  }
}

class SolanaClientNotifier extends StateNotifier<SolanaClientState> {
  SolanaClientNotifier(this._walletService)
      : super(const SolanaClientState(authorizationResult: null));
  final DReaderWalletService _walletService;

  Future<Uint8List?> authorizeAndSignMessage() async {
    final session = await LocalAssociationScenario.create();
    session.startActivityForResult(null).ignore();

    final client = await session.start();
    final result = await client.authorize(
      identityUri: Uri.parse('https://dreader.io/'),
      identityName: 'dReader',
      cluster: 'devnet',
    );

    state = state.copyWith(authorizationResult: result);

    final oneTimePassword = await _walletService
        .getOneTimePassword(Ed25519HDPublicKey(result?.publicKey ?? []));

    final signMessageResult = await _signMessage(client, oneTimePassword);

    await session.close();
    return signMessageResult.isNotEmpty ? signMessageResult.first : null;
  }

  Future<String> getTokenAfterSigning(Uint8List signedMessage) async {
    return _walletService.connectWallet(
      Ed25519HDPublicKey(state.authorizationResult?.publicKey ?? []),
      signedMessage.sublist(
        signedMessage.length - 64,
        signedMessage.length,
      ),
    );
  }

  Future<void> deauthorize() async {
    final authToken = state.authorizationResult?.authToken;
    if (authToken == null) return;

    final session = await LocalAssociationScenario.create();
    session.startActivityForResult(null).ignore();

    final client = await session.start();
    await client.deauthorize(authToken: authToken);
    state = state.copyWith(authorizationResult: null);
    await session.close();
  }

  Future<List<Uint8List>> _signMessage(
      MobileWalletAdapterClient client, String message) async {
    if (await _doReauthorize(client)) {
      final signer = Ed25519HDPublicKey(state.authorizationResult!.publicKey);
      final addresses = Uint8List.fromList(signer.bytes);

      final messageToBeSigned = Uint8List.fromList(utf8.encode(message));
      try {
        final result = await client.signMessages(
            messages: [messageToBeSigned], addresses: [addresses]);
        return result.signedPayloads;
      } catch (e) {
        print('Error $e');
      }
    }
    return [];
  }

  Future<bool> _doReauthorize(MobileWalletAdapterClient client) async {
    final authToken = state.authorizationResult?.authToken;
    if (authToken == null) return false;
    final result = await client.reauthorize(
      identityUri: Uri.parse('https://dreader.io/'),
      identityName: 'dReader',
      authToken: authToken,
    );
    state = state.copyWith(authorizationResult: result);
    return result != null;
  }
}
