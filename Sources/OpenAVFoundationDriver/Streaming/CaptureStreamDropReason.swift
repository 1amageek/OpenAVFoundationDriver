public enum CaptureStreamDropReason: Sendable, Equatable {
    case frameWasLate
    case outOfBuffers
    case discontinuity
    case platform(code: Int64)
}
