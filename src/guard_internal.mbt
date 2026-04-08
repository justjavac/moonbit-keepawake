///|
/// Normalizes caller-supplied reasons before they cross the FFI boundary.
fn normalize_reason(reason : String) -> String {
  let trimmed = reason.trim().to_string()
  if trimmed is "" {
    default_reason
  } else {
    trimmed
  }
}

///|
/// Decodes a backend error payload into a readable string.
fn decode_native_detail(detail : Bytes) -> String {
  if detail.is_empty() {
    "The native backend did not provide extra details."
  } else {
    @utf8.decode_lossy(detail)
  }
}

///|
/// Maps native backend status codes into public MoonBit errors.
fn classify_native_error(
  status~ : Int,
  operation~ : String,
  detail~ : String,
) -> KeepAwakeError {
  if status == native_status_backend_unavailable {
    BackendUnavailable(detail~)
  } else if status == native_status_operation_failed {
    OperationFailed(operation~, detail~)
  } else {
    OperationFailed(operation~, detail~)
  }
}
