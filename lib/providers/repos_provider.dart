import 'package:app/firebase_config.dart';
import 'package:app/repos/auth/auth_repo.dart';
import 'package:app/repos/urls/urls_repo.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Repos {
  Repos({
    required this.auth,
    required this.urls,
  });

  final AuthRepo auth;
  final UrlsRepo urls;
}

final reposProvider = Provider<Repos>(
  (ref) {
    final authRepo = AuthRepo(FirebaseAuth.instance);
    final urlsRepo =
        UrlsRepo(ref.watch(functionsInstanceProvider('europe-west2')));

    ref.onDispose(() {
      authRepo.dispose();
    });

    return Repos(
      auth: authRepo,
      urls: urlsRepo,
    );
  },
);

final functionsInstanceProvider =
    Provider.family<FirebaseFunctions, String>(((ref, region) {
  final instance = FirebaseFunctions.instanceFor(region: region);

  if (kEmulatorsIp.isNotEmpty) {
    instance.useFunctionsEmulator(kEmulatorsIp, 5001);
  }

  return instance;
}));
