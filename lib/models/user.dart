import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth show User;

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String uid,
    required String email,
  }) = _User;

  factory User.fromFirebaseUser(auth.User user) {
    return User(
      uid: user.uid,
      email: user.email!,
    );
  }

  static const visitor = User(
    uid: '',
    email: '',
  );
}
