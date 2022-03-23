import 'package:app/models/functions_response.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'repo_result.freezed.dart';

@freezed
class RepoResult<T> with _$RepoResult<T> {
  const factory RepoResult.data(T data) = _Data<T>;
  const factory RepoResult.error(FunctionsBaseResponse response) = _Error;
  const factory RepoResult.exception(
    Exception e, {
    StackTrace? stackTrace,
  }) = _Exception;
}
