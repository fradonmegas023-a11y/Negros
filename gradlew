#!/usr/bin/env sh
# Lightweight Gradle bootstrapper for this project (no wrapper JAR required).
set -eu
VERSION="8.13"
BASE="${GRADLE_USER_HOME:-$HOME/.gradle}/negros-gradle"
DIST="$BASE/gradle-$VERSION"
BIN="$DIST/bin/gradle"
if [ ! -x "$BIN" ]; then
  mkdir -p "$BASE"
  ZIP="$BASE/gradle-$VERSION-bin.zip"
  echo "Downloading Gradle $VERSION (first run only)..."
  curl -fL "https://services.gradle.org/distributions/gradle-$VERSION-bin.zip" -o "$ZIP"
  unzip -q -o "$ZIP" -d "$BASE"
fi
exec "$BIN" "$@"
