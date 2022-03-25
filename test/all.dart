import 'package:app/repos/auth/auth_repo.dart';
import 'package:app/repos/urls/urls_repo.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  AuthRepo,
  UrlsRepo,
  FirebaseAuth,
  UserCredential,
  FirebaseFunctions,
  HttpsCallable,
])
const mocks = null;
