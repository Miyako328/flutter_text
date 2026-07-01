import 'package:encrypt/encrypt.dart';

class Encrypt {
  static String keySalt = 'MyPasswordEncrypt32NumberKeySalt';

  static String encryptToBase64(String password) {
    final Key key = Key.fromUtf8(keySalt);
    final IV iv = IV.fromLength(16);
    final Encrypter encrypt = Encrypter(AES(key));
    return encrypt.encrypt(password, iv: iv).base64;
  }

  static String decryptWithBase64(String base64) {
    final Key key = Key.fromUtf8(keySalt);
    final IV iv = IV.fromLength(16);
    final Encrypter decrypt = Encrypter(AES(key));
    return decrypt.decrypt64(base64, iv: iv);
  }
}