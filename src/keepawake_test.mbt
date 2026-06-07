///|
test "scope names stay stable" {
  debug_inspect(
    [
      @keepawake.PreventSystemSleep.to_string(),
      @keepawake.PreventDisplaySleep.to_string(),
      @keepawake.PreventSystemAndDisplaySleep.to_string(),
    ],
    content=(
      #|[
      #|  "PreventSystemSleep",
      #|  "PreventDisplaySleep",
      #|  "PreventSystemAndDisplaySleep",
      #|]
    ),
  )
}

///|
test "acquire and release smoke test" {
  let result = try? @keepawake.acquire(
    reason="blackbox smoke test",
    scope=PreventSystemSleep,
  )
  match result {
    Ok(handle) => {
      assert_true(handle.active())
      assert_eq(handle.scope(), PreventSystemSleep)
      handle.release()
      assert_true(handle.active() == false)
      handle.release()
      assert_true(handle.active() == false)
    }
    Err(BackendUnavailable(detail~)) =>
      assert_true(
        detail.contains("systemd-inhibit") ||
        detail.contains("unsupported") ||
        detail.contains("framework") ||
        detail.contains("inhibit"),
        msg=detail,
      )
    Err(err) => fail("\{err}")
  }
}

///|
test "with_keepawake returns the action result" {
  let result : Result[String, Error] = try? @keepawake.with_keepawake(
    fn() { "kept awake" },
    reason="scoped smoke test",
    scope=PreventSystemSleep,
  )
  match result {
    Ok(value) => assert_eq(value, "kept awake")
    Err(@keepawake.BackendUnavailable(detail~)) =>
      assert_true(
        detail.contains("systemd-inhibit") ||
        detail.contains("unsupported") ||
        detail.contains("framework") ||
        detail.contains("inhibit"),
        msg=detail,
      )
    Err(err) => fail("\{err}")
  }
}
