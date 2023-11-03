import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/authentication_switcher.dart';
import 'services/authentication_service.dart';
import 'services/bill_data_repository.dart';
import 'services/user_data_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //runApp(const MockUpPage());
  runApp(const SplitItApp());
}

class SplitItApp extends StatelessWidget {
  const SplitItApp({super.key});

  @override
  Widget build(BuildContext context) => Provider.value(
        value: AuthenticationService(),
        builder: (context, child) => StreamProvider.value(
          value: context.read<AuthenticationService>().userAuthState,
          initialData: null,
          builder: (context, child) => MultiProvider(
            providers: [
              Provider.value(value: UserDataRepository(read: context.read)),
              Provider.value(value: BillDataRepository(read: context.read)),
            ],
            child: MaterialApp(
              title: 'SplitIt',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorSchemeSeed: const Color(0xFF26B645),
                useMaterial3: true,
              ),
              home: const AuthenticationSwitcher(),
            ),
          ),
        ),
      );
}
