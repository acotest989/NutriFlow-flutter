import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/ai_service.dart';
import '../services/exercise_db_service.dart';
import '../services/food_db_service.dart';
import '../services/local_cache.dart';

/// Overridden in main() with the instance loaded before runApp.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('override in main'));

final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final aiServiceProvider = Provider<AiService>((ref) => AiService());

final foodDbProvider = Provider<FoodDbService>((ref) => FoodDbService(ai: ref.watch(aiServiceProvider)));

final exerciseDbProvider = Provider<ExerciseDbService>((ref) => ExerciseDbService());

final localCacheProvider = Provider<LocalCache>((ref) => LocalCache());

/// True while the device reports some network connection.
final onlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  bool online(List<ConnectivityResult> r) => r.any((c) => c != ConnectivityResult.none);
  yield online(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(online);
});
