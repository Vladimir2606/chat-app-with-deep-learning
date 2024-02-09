import 'dart:convert';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/export.dart';
import 'package:encrypt/encrypt.dart' as encryptor;
// ignore: implementation_imports
import 'package:pointycastle/src/platform_check/platform_check.dart';

// hash data (passwords or pins)
String hashData(String data) {
  final hash = SHA256Digest().process(utf8.encode(data));

  return hash.toString();
}

List<int> _pad(List<int> data, int blockSize) {
  final padLength = blockSize - (data.length % blockSize);
  final paddedData = List<int>.from(data)
    ..addAll(List<int>.filled(padLength, 0));
  return paddedData;
}

// encrypt a message
String encrypt(String plainText, RSAPublicKey publicKey) {
  final aesKey = generateRandomBytes(32);
  final encryptedAesKey = encryptAesKey(aesKey, publicKey);

  final cipher = BlockCipher('AES/CTR')
    ..init(
        true,
        ParametersWithIV(
            KeyParameter(aesKey),
            Uint8List.fromList(
                [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])));

  final plainTextBytes = Uint8List.fromList(utf8.encode(plainText));
  final paddedPlainTextBytes = _pad(plainTextBytes, cipher.blockSize);
  final encryptedBytes =
      cipher.process(Uint8List.fromList(paddedPlainTextBytes));

  final result = {
    'encryptedAesKey': base64Encode(encryptedAesKey),
    'encryptedData': base64Encode(encryptedBytes),
  };

  return jsonEncode(result);
}

// decrypt a message
String decrypt(String encryptedData, RSAPrivateKey privateKey) {
  try {
    final result = jsonDecode(encryptedData);

    final encryptedAesKey = base64Decode(result['encryptedAesKey']);
    final encryptedBytes = base64Decode(result['encryptedData']);

    final aesKey = decryptAesKey(encryptedAesKey, privateKey);

    final cipher = BlockCipher('AES/CTR')
      ..init(
          true,
          ParametersWithIV(
              KeyParameter(aesKey),
              Uint8List.fromList(
                  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])));

    final decryptedBytes = cipher.process(Uint8List.fromList(encryptedBytes));

    return utf8.decode(decryptedBytes);
  } catch (e) {
    return "Decryption failed. $e";
  }
}

// generate a random aes key
Uint8List generateRandomBytes(int length) {
  final secureRandom = SecureRandom('Fortuna')
    ..seed(
        KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));

  final keyBytes = Uint8List(length);

  for (int i = 0; i < length; i++) {
    keyBytes[i] = secureRandom.nextUint8();
  }

  return keyBytes;
}

// encrypt the aes key with the receivers public key
Uint8List encryptAesKey(Uint8List aesKey, RSAPublicKey publicKey) {
  final encrypter = encryptor.Encrypter(encryptor.RSA(publicKey: publicKey));
  final encrypted = encrypter.encryptBytes(aesKey);
  return encrypted.bytes;
}

// decrypt the aes key with the receivers private key
Uint8List decryptAesKey(Uint8List encryptedAesKey, RSAPrivateKey privateKey) {
  final encrypter = encryptor.Encrypter(encryptor.RSA(privateKey: privateKey));
  final decrypted =
      encrypter.decryptBytes(encryptor.Encrypted(encryptedAesKey));
  return Uint8List.fromList(decrypted);
}

Uint8List? getEncodedBytes(ASN1Object asn1Object) {
  try {
    return asn1Object.encodedBytes;
  } catch (e) {
    return null;
  }
}

// convert public key to storable string
String encodePublicKeyToPemPKCS1(RSAPublicKey publicKey) {
  var topLevel = ASN1Sequence();

  topLevel.add(ASN1Integer(publicKey.modulus!));
  topLevel.add(ASN1Integer(publicKey.exponent!));

  var dataBase64 = base64.encode(topLevel.encodedBytes);
  return """-----BEGIN RSA PUBLIC KEY-----\n$dataBase64\n-----END RSA PUBLIC KEY-----""";
}

// convert private key to storable string
String encodePrivateKeyToPemPKCS1(RSAPrivateKey privateKey) {
  var topLevel = ASN1Sequence();

  var version = ASN1Integer(BigInt.from(0));
  var modulus = ASN1Integer(privateKey.n!);
  var publicExponent = ASN1Integer(privateKey.exponent!);
  // ignore: deprecated_member_use
  var privateExponent = ASN1Integer(privateKey.d!);
  var p = ASN1Integer(privateKey.p!);
  var q = ASN1Integer(privateKey.q!);
  // ignore: deprecated_member_use
  var dP = privateKey.d! % (privateKey.p! - BigInt.from(1));
  var exp1 = ASN1Integer(dP);
  // ignore: deprecated_member_use
  var dQ = privateKey.d! % (privateKey.q! - BigInt.from(1));
  var exp2 = ASN1Integer(dQ);
  var iQ = privateKey.q?.modInverse(privateKey.p!);
  var co = ASN1Integer(iQ!);

  topLevel.add(version);
  topLevel.add(modulus);
  topLevel.add(publicExponent);
  topLevel.add(privateExponent);
  topLevel.add(p);
  topLevel.add(q);
  topLevel.add(exp1);
  topLevel.add(exp2);
  topLevel.add(co);

  var dataBase64 = base64.encode(topLevel.encodedBytes);

  return """-----BEGIN RSA PRIVATE KEY-----\r\n$dataBase64\r\n-----END RSA PRIVATE KEY-----""";
}

// convert public key from String to RSAPublicKey
RSAPublicKey? parsePublicKey(String key) {
  final rows = key.split('\n');
  final header = rows.first;

  if (header == '-----BEGIN RSA PUBLIC KEY-----') {
    return _parsePublic(_parseSequence(rows)!);
  }
  return null;
}

// convert private key from String to RSAPrivateKey
RSAPrivateKey? parsePrivateKey(String key) {
  try {
    final rows = key.split('\n');

    if (rows.first.contains('RSA PRIVATE KEY')) {
      final sequence = _parseSequence(rows);
      if (sequence != null) {
        return _parsePrivate(sequence);
      } else {
        return null;
      }
    }
  } catch (e) {
    throw Exception(e);
  }
  return null;
}

RSAPublicKey _parsePublic(ASN1Sequence sequence) {
  final modulus = (sequence.elements[0] as ASN1Integer).valueAsBigInteger;
  final exponent = (sequence.elements[1] as ASN1Integer).valueAsBigInteger;

  return RSAPublicKey(modulus, exponent);
}

RSAPrivateKey _parsePrivate(ASN1Sequence sequence) {
  final modulus = (sequence.elements[1] as ASN1Integer).valueAsBigInteger;
  final exponent = (sequence.elements[3] as ASN1Integer).valueAsBigInteger;
  final p = (sequence.elements[4] as ASN1Integer).valueAsBigInteger;
  final q = (sequence.elements[5] as ASN1Integer).valueAsBigInteger;
  return RSAPrivateKey(modulus, exponent, p, q);
}

ASN1Sequence? _parseSequence(List<String> rows) {
  try {
    final keyText = rows
        .skipWhile((row) => row.startsWith('-----BEGIN'))
        .takeWhile((row) => !row.startsWith('-----END'))
        .map((row) => row.trim())
        .join('');
    final keyBytes = Uint8List.fromList(base64.decode(keyText));
    final asn1Parser = ASN1Parser(keyBytes);
    return asn1Parser.nextObject() as ASN1Sequence?;
  } catch (e) {
    throw Exception(e);
  }
}
