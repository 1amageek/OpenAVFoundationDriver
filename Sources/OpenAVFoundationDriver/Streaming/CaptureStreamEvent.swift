public enum CaptureStreamEvent: Sendable, Equatable {
    case interrupted(CaptureStreamInterruption)
    case resumed
    case pressure(CaptureSystemPressure)
    case dropped(CaptureStreamDropEvent)
    case failed(CaptureDriverError)
}
