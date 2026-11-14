import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/cache/cache_helper.dart';
import 'core/localization/locale_cubit.dart';
import 'core/theme/bio_orbit_colors.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/intro/splash_screen.dart';
import 'features/orbit_hub/cubit/bio_orbit_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit()..loadSavedLocale(),
        ),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        BlocProvider<BioOrbitCubit>(
          create: (_) => BioOrbitCubit()..initializeDashboard(),
        ),
      ],
      child: const BioOrbitApp(),
    ),
  );
}

class BioOrbitApp extends StatelessWidget {
  const BioOrbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp(
              title: 'BioOrbit',
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: const [Locale('ar'), Locale('en')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: BioOrbitTheme.spaceMedicalTheme,
              home: child,
            );
          },
        );
      },
      child: const SplashScreen(),
    );
  }
}
