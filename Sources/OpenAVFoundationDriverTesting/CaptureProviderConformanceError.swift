public enum CaptureProviderConformanceError: Error, Sendable, Equatable {
    case driver(CaptureDriverError)
    case duplicateDeviceID(CaptureDeviceID)
    case unexpectedDriver(
        expected: CaptureDriverID,
        actual: CaptureDriverID
    )
    case descriptorDoesNotMatchRequest(CaptureDeviceID)
    case openedDeviceMismatch(
        expected: CaptureDeviceID,
        actual: CaptureDeviceID
    )
    case resultingSnapshotMismatch(CaptureDeviceID)
    case handleRemainedOpen(CaptureDeviceID)
    case missingInitialDeviceSnapshot(CaptureDriverID)
    case streamGroupMismatch(CaptureDeviceID)
    case undeclaredStreamEvent(CaptureStreamEvent)
}
