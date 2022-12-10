import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';

final solanaProvider = StateNotifierProvider<SolanaClient, SolanaClientState>(
    (ref) => SolanaClient());

@immutable // preferred to use immutable states
class SolanaClientState {
  const SolanaClientState({
    this.capabilities,
    this.authorizationResult,
  });
  final GetCapabilitiesResult? capabilities;
  final AuthorizationResult? authorizationResult;

  SolanaClientState copyWith({
    GetCapabilitiesResult? capabilities,
    AuthorizationResult? authorizationResult,
  }) {
    return SolanaClientState(
      capabilities: capabilities,
      authorizationResult: authorizationResult,
    );
  }
}

class SolanaClient extends StateNotifier<SolanaClientState> {
  SolanaClient()
      : super(const SolanaClientState(
            capabilities: null, authorizationResult: null));

  Future<void> requestCapabilities() async {
    final session = await LocalAssociationScenario.create();
    session.startActivityForResult(null).ignore();

    final client = await session.start();
    final result = await client.getCapabilities();
    state = state.copyWith(capabilities: result);
    await session.close();
  }

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
    await session.close();
    state = state.copyWith(authorizationResult: null);
  }

  Future<List<Uint8List>> signMessages(List<String> messagesArg) async {
    final session = await LocalAssociationScenario.create();
    session.startActivityForResult(null).ignore();

    final client = await session.start();

    if (await _doReauthorize(client)) {
      final signer =
          Ed25519HDPublicKey(state.authorizationResult!.publicKey.toList());
      final addresses = [signer.bytes].map(Uint8List.fromList).toList();
      final messages = _generateMessages(signer: signer, messages: messagesArg)
          .map((e) => e.compile(recentBlockhash: '').data.toList())
          .map(Uint8List.fromList)
          .toList();
      try {
        final result =
            await client.signMessages(messages: messages, addresses: addresses);
        await session.close();
        return result.signedPayloads;
      } catch (e) {
        print('Error $e');
      }
    }
    return [];
  }

  List<Message> _generateMessages({
    required Ed25519HDPublicKey signer,
    required List<String> messages,
  }) =>
      List.generate(
        messages.length,
        (index) => MemoInstruction(signers: [signer], memo: messages[index]),
      ).map(Message.only).toList();

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
