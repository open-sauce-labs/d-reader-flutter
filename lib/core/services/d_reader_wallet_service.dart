import 'package:d_reader_flutter/core/repositories/auth/auth_repository_impl.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';

class DReaderWalletService {
  DReaderWalletService._(this._authRepo);

  static DReaderWalletService? _instance;
  static DReaderWalletService get instance =>
      _instance ?? DReaderWalletService._(AuthRepositoryImpl());
  final AuthRepositoryImpl _authRepo;

  Future<String> getOneTimePassword(Ed25519HDPublicKey publicKey) async {
    return await _authRepo.getOneTimePassword(publicKey.toBase58());
  }

  Future<String> connectWallet(
      Ed25519HDPublicKey publicKey, List<int> signedData) async {
    try {
      final connectWalletResponse = await _authRepo.connectWallet(
        publicKey.toBase58(),
        base58encode(signedData),
      );
      return connectWalletResponse?.accessToken ?? 'no-token';
    } catch (e) {
      print(e);
      return 'An error occured.';
    }
  }
}
