import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Config {
  static final walletPrivateKey =
      dotenv.get('private_key', fallback: 'Key is missing');
  static final API_URL = dotenv.get('API_URL',
      fallback: 'https://d-reader-backend-dev.herokuapp.com');

  static const String logoTextPath = 'assets/images/dReaderLogoText.png';
  static const String logoPath = 'assets/images/dReaderLogo.png';
}
