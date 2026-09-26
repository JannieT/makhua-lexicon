import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../edit/entry_manager.dart';
import '../../export/export_manager.dart';
import '../../index/index_manager.dart';
import '../../settings/settings_manager.dart';
import '../../settings/settings_service.dart';
import '../../users/auth_manager.dart';
import 'analytics_service.dart';
import 'auth_service.dart';
import 'database_service.dart';
import 'store_service.dart';

final get = GetIt.instance;

Future<void> registerServices() async {
  final store = await StoreService.instance();
  get.registerSingleton<StoreService>(store);
  get.registerSingleton<AnalyticsService>(AnalyticsService());
  get.registerSingleton<AuthService>(AuthService(FirebaseAuth.instance));
  get.registerSingleton<DatabaseService>(DatabaseService());
  get.registerSingleton<AuthManager>(AuthManager(get<AuthService>()));
  get.registerSingleton<SettingsManager>(SettingsManager(SettingsService(store)));
  get.registerSingleton<IndexManager>(
    IndexManager(get<AuthService>(), get<DatabaseService>()),
    dispose: (manager) {
      manager.dispose();
    },
  );
  get.registerFactory<ExportManager>(() => ExportManager(get<DatabaseService>()));
  get.registerFactory<EntryManager>(
    () => EntryManager(get<AuthService>(), get<IndexManager>()),
  );
}
