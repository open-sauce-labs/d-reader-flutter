import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana/solana.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';

final solanaProvider = StateNotifierProvider<SolanaClient, SolanaClientState>(
    (ref) => SolanaClient());

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

class SolanaClient extends StateNotifier<SolanaClientState> {
  SolanaClient() : super(const SolanaClientState(authorizationResult: null));

  Future<void> authorize() async {
    final session = await LocalAssociationScenario.create();
    session.startActivityForResult(null).ignore();

    final client = await session.start();
    final result = await client.authorize(
      identityUri: Uri.parse('https://dreader.io/'),
      identityName: 'dReader',
      cluster: 'devnet',
    );

    state = state.copyWith(authorizationResult: result);

    await session.close();
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

  Future<List<Uint8List>> signMessage(String message) async {
    final session = await LocalAssociationScenario.create();
    session.startActivityForResult(null).ignore();

    final client = await session.start();

    if (await _doReauthorize(client)) {
      final signer =
          Ed25519HDPublicKey(state.authorizationResult!.publicKey.toList());
      final addresses = Uint8List.fromList(signer.bytes);

      final messageToBeSigned = Uint8List.fromList(utf8.encode(message));
      try {
        final result = await client.signMessages(
            messages: [messageToBeSigned], addresses: [addresses]);
        await session.close();
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
