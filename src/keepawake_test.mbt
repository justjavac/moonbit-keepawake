///|
fn[T, E : Error] try_result_keepawake_test(f : () -> T raise E) -> Result[T, E] {
  try f() catch {
    e => Err(e)
  } noraise {
    value => Ok(value)
  }
}

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
  let result = try_result_keepawake_test(() => {
    @keepawake.acquire(reason="blackbox smoke test", scope=PreventSystemSleep)
  })
  match result {
    Ok(handle) => {
      assert_true(handle.active())
      assert_true(handle.scope() == PreventSystemSleep)
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
  let result : Result[String, Error] = try_result_keepawake_test(() => {
    @keepawake.with_keepawake(
      fn() { "kept awake" },
      reason="scoped smoke test",
      scope=PreventSystemSleep,
    )
  })
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
