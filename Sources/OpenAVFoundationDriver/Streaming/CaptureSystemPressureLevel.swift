public enum CaptureSystemPressureLevel: Sendable, Equatable {
    case nominal
    case fair
    case serious
    case critical
    case shutdown
    case platform(code: Int64)
}
