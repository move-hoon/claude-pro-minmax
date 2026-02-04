#!/bin/bash
# jvm.sh - JVM Adapter (Gradle/Maven)
# Supports Java, Kotlin, Spring Boot
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

_detect_tool() {
  [[ -f "$PROJECT_DIR/gradlew" ]] && echo "gradle" && return
  [[ -f "$PROJECT_DIR/mvnw" ]] && echo "maven" && return
  [[ -f "$PROJECT_DIR/build.gradle.kts" ]] && echo "gradle" && return
  [[ -f "$PROJECT_DIR/build.gradle" ]] && echo "gradle" && return
  [[ -f "$PROJECT_DIR/pom.xml" ]] && echo "maven" && return
  echo "gradle"  # default
}

_gradle() {
  if [[ -f "$PROJECT_DIR/gradlew" ]]; then
    "$PROJECT_DIR/gradlew" "$@"
  else
    gradle "$@"
  fi
}

_maven() {
  if [[ -f "$PROJECT_DIR/mvnw" ]]; then
    "$PROJECT_DIR/mvnw" "$@"
  else
    mvn "$@"
  fi
}

adapter_info() {
  echo '{"runtime":"jvm","tools":["gradle","maven"],"languages":["java","kotlin"]}'
}

adapter_verify() {
  case $(_detect_tool) in
    gradle) _gradle check --no-daemon ;;
    maven) _maven verify -q ;;
  esac
}

adapter_build() {
  case $(_detect_tool) in
    gradle) _gradle build --no-daemon -x test ;;
    maven) _maven package -q -DskipTests ;;
  esac
}

adapter_test() {
  case $(_detect_tool) in
    gradle) _gradle test --no-daemon ;;
    maven) _maven test -q ;;
  esac
}

adapter_lint() {
  case $(_detect_tool) in
    gradle)
      # Try ktlint for Kotlin, then checkstyle for Java
      _gradle ktlintCheck --no-daemon 2>/dev/null || \
      _gradle checkstyleMain --no-daemon 2>/dev/null || \
      true
      ;;
    maven)
      _maven checkstyle:check -q 2>/dev/null || true
      ;;
  esac
}

adapter_format() {
  case $(_detect_tool) in
    gradle)
      _gradle ktlintFormat --no-daemon 2>/dev/null || \
      _gradle spotlessApply --no-daemon 2>/dev/null || \
      true
      ;;
    maven)
      _maven spotless:apply -q 2>/dev/null || true
      ;;
  esac
}

adapter_run() {
  case $(_detect_tool) in
    gradle) _gradle bootRun --no-daemon 2>/dev/null || _gradle run --no-daemon ;;
    maven) _maven spring-boot:run -q 2>/dev/null || _maven exec:java -q ;;
  esac
}

adapter_clean() {
  case $(_detect_tool) in
    gradle) _gradle clean --no-daemon ;;
    maven) _maven clean -q ;;
  esac
}
