public enum CaptureStreamInterruption: Sendable, Equatable {
    case deviceInUseByAnotherClient
    case deviceUnavailableInBackground
    case deviceUnavailableDueToSystemPressure
    case platform(code: Int64)
}
