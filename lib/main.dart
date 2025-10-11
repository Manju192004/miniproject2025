import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/Bloc/observer/observer.dart';
import 'package:project/Bloc/theme_cubit.dart';
import 'package:project/Reusable/color.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:project/UI/SplashScreen/splash_screen.dart';
import 'firebase_options.dart'; // ✅ Required for FirebaseOptions

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    ]
  );

  Bloc.observer = AppBlocObserver();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: const MyApp(),
    );
  }
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(builder: (_, theme) {
      return OverlaySupport.global(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mini Project',
          theme: ThemeData(
            primaryColor: Colors.green,
            unselectedWidgetColor: Colors.green,
            fontFamily: "Poppins",
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.green, // 👈 Blinking cursor color
              selectionColor: Colors.green, // optional: text selection color
              selectionHandleColor: Colors.green, // optional: handle color
            ),
          ),


          darkTheme: ThemeData.dark(),
          themeMode: theme.brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light, // ✅ Dynamically switch
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: ScrollConfiguration(
                behavior: MyBehavior(),
                child: child!,
              ),
            );
          },
          home: const SplashScreen(),
        ),
      );
    });
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
