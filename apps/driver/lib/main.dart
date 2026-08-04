import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taxigo_core/taxigo_core.dart';

import 'app/app.dart';
import 'di/locator.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseService.initialize();
  await di.setupLocator();
  runApp(const TaxiGoDriverApp());
}
