// ignore_for_file: prefer_const_constructors

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void savePrivateKey(String privateKey) async {
  final storage = FlutterSecureStorage();
  await storage.write(key: 'privateKey', value: privateKey);
}

Future<String?> getPrivateKey() async {
  final storage = FlutterSecureStorage();
  return await storage.read(key: 'privateKey');
}
