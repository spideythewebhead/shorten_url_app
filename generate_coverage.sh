#!/bin/bash

flutter test --coverage

lcov --remove coverage/lcov.info \
  'lib/*/*.freezed.dart' 'lib/*/*.g.dart' -o coverage/lcov.info

genhtml coverage/lcov.info -o coverage

xdg-open coverage/index.html