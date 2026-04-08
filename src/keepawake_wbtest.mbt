///|
test "normalize_reason trims surrounding whitespace" {
  assert_eq(normalize_reason("  writing backups  "), "writing backups")
  assert_eq(normalize_reason("   "), default_reason)
}

///|
test "normalized reasons convert to null-terminated c strings" {
  let c_reason = @ffi.to_cstr(normalize_reason("  writing backups  "))
  assert_eq(@ffi.from_cstr(c_reason), "writing backups")
  assert_eq(c_reason[c_reason.length() - 1], 0)
}

///|
test "scope codes round-trip" {
  let scopes : Array[Scope] = [
    Scope::PreventSystemSleep,
    Scope::PreventDisplaySleep,
    Scope::PreventSystemAndDisplaySleep,
  ]
  for scope in scopes {
    assert_eq(scope_from_native_code(scope.native_code()), scope)
  }
}

///|
test "classify_native_error keeps backend-unavailable distinct" {
  guard classify_native_error(
      status=native_status_backend_unavailable,
      operation="acquire",
      detail="systemd-inhibit was not found",
    )
    is BackendUnavailable(detail="systemd-inhibit was not found") else {
    fail("expected a backend-unavailable error")
  }
}

///|
test "classify_native_error maps operational failures" {
  guard classify_native_error(
      status=native_status_operation_failed,
      operation="release",
      detail="release failed",
    )
    is OperationFailed(operation="release", detail="release failed") else {
    fail("expected an operation-failed error")
  }
}
