///|
fn wait_for(duration_ms : UInt64) -> Unit {
  let deadline = @env.now() + duration_ms
  while @env.now() < deadline {
  }
}

///|
fn run_example() -> Unit raise @keepawake.KeepAwakeError {
  let hold_duration_ms : UInt64 = 5000
  let handle = @keepawake.acquire(
    reason="Running the basic keepawake example",
    scope=@keepawake.Scope::PreventSystemAndDisplaySleep,
  )
  println("Keep-awake guard acquired for roughly \{hold_duration_ms} ms.")
  wait_for(hold_duration_ms)
  handle.release()
  println("Keep-awake guard released.")
}

///|
fn main {
  try run_example() catch {
    err => println("Example failed: \{err}")
  } noraise {
    _ => ()
  }
}
