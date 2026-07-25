/// A small, copyable control value. Media payloads never use this type.
public enum CaptureDeviceControlValue: Sendable, Hashable {
    case boolean(Bool)
    case integer(Int64)
    case scalar(Double)
    case option(String)
}
