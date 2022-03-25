import 'package:cloud_functions/cloud_functions.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FakeFirebaseUser extends Fake implements User {
  FakeFirebaseUser({
    required this.uid,
    required this.email,
  });

  @override
  final String uid;

  @override
  final String? email;
}

class FakeHttpsCallableResult<T> extends Fake
    implements HttpsCallableResult<T> {
  FakeHttpsCallableResult(this.data);

  @override
  final T data;
}
