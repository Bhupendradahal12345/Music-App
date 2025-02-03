/*
 *     Copyright (C) 2024 Valeri Gokadze
 *
 *     shrayesh_patro is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     shrayesh_patro is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about shrayesh_patro, including how to contribute,
 *     please visit: https://github.com/bhupendra/shrayesh_patro
 */

import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shrayesh_patro/services/audio_service.dart';
import 'package:shrayesh_patro/services/logger_service.dart';
import 'package:shrayesh_patro/services/mini-player_support.dart';
import 'package:shrayesh_patro/services/router_service.dart';
import 'package:shrayesh_patro/services/settings_manager.dart';
import 'package:shrayesh_patro/style/app_themes.dart';
import 'package:shrayesh_patro/News/utils_news/service_locator.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import 'API/languagecodes.dart';
import 'Backup/config.dart';
import 'News/Source_News/list2_locator.dart';
import 'News/Source_News/list3_locator.dart';
import 'News/Source_News/list4_locator.dart';
import 'News/Source_News/list5_locator.dart';
import 'News/Source_News/list6_locator.dart';
import 'News/Source_News/list7_locator.dart';
import 'News/Source_News/list_locator.dart';


late MyAudioHandler audioHandler;

final logger = Logger();

bool isFdroidBuild = false;
bool isUpdateChecked = true;



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override

  _MyAppState createState() => _MyAppState();

  // ignore: unreachable_from_main
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', '');
  late StreamSubscription _intentDataStreamSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final String systemLangCode = Platform.localeName.substring(0, 2);
    final String? lang = Hive.box('settings').get('lang') as String?;
    if (lang == null &&
        LanguageCodes.languageCodes.values.contains(systemLangCode)) {
      _locale = Locale(systemLangCode);
    } else {
      _locale = Locale(LanguageCodes.languageCodes[lang ?? 'English'] ?? 'en');
    }

    AppTheme.currentTheme.addListener(() {
      setState(() {});
    });
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });


    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    try {
      LicenseRegistry.addLicense(() async* {
        final license =
        await rootBundle.loadString('assets/licenses/paytone.txt');
        yield LicenseEntryWithLineBreaks(['paytoneOne'], license);
      });
    } catch (e, stackTrace) {
      logger.log('License Registration Error', e, stackTrace);
    }

    if (!isFdroidBuild &&
        !isUpdateChecked &&
        !offlineMode.value &&
        kReleaseMode) {
      Future.delayed(Duration.zero, () {
        isUpdateChecked = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: AppTheme.themeMode == ThemeMode.system
              ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
              ? Brightness.light
              : Brightness.dark
              : AppTheme.themeMode == ThemeMode.dark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarIconBrightness:
          AppTheme.themeMode == ThemeMode.system
              ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
              ? Brightness.light
              : Brightness.dark
              : AppTheme.themeMode == ThemeMode.dark
              ? Brightness.light
              : Brightness.dark,
        ),
        child: LayoutBuilder(
            builder: (context, constraints) {
              return OrientationBuilder(
                builder: (context, orientation) {
                  SizerUtil.setScreenSize(constraints, orientation);
                  return MaterialApp.router(
                    themeMode: AppTheme.themeMode,
                    theme: AppTheme.lightTheme(
                      context: context,
                    ),
                    darkTheme: AppTheme.darkTheme(
                      context: context,
                    ),
                    locale: _locale,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: LanguageCodes.languageCodes.entries
                        .map((languageCode) => Locale(languageCode.value, ''))
                        .toList(),
                    routerConfig: NavigationManager.router,
                  );
                },
              );
            }
        )
    );
  }
}

void main() async {
  NepaliUtils(Language.nepali);
  WidgetsFlutterBinding.ensureInitialized();
  await initialisation();
  setupServiceLocator();
  listServiceLocator();
  list2ServiceLocator();
  list3ServiceLocator();
  list4ServiceLocator();
  list5ServiceLocator();
  list6ServiceLocator();
  list7ServiceLocator();
  runApp(MyApp());
}
Future<void> initialisation() async {
  try {
    await Hive.initFlutter();

    final boxNames = ['settings', 'user', 'userNoBackup', 'cache', 'downloads'];

    for (final boxName in boxNames) {
      await Hive.openBox(boxName);
    }
    GetIt.I.registerSingleton<MyTheme>(MyTheme());
    audioHandler = await AudioService.init(
      builder: MyAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.shrayesh_dahal.patro',
        androidNotificationChannelName: 'shrayesh_patro',
        androidNotificationIcon: 'drawable/ic_launcher_foreground',
        androidShowNotificationBadge: true,
        androidStopForegroundOnPause: false,
      ),
    );
    NavigationManager.instance;
  } catch (e, stackTrace) {
    logger.log('Initialization Error', e, stackTrace);
  }
}
abstract class AudioPlayerHandler implements AudioHandler {
  Stream<QueueState> get queueState;
  Future<void> moveQueueItem(int currentIndex, int newIndex);
  ValueStream<double> get volume;
  Future<void> setVolume(double volume);
  ValueStream<double> get speed;
}
