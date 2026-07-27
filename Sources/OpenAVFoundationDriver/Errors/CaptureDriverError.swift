public enum CaptureDriverError: Error, Sendable, Equatable {
    case providerUnavailable(driverID: CaptureDriverID)
    case authorizationDenied(
        driverID: CaptureDriverID,
        mediaType: CaptureMediaTypeID
    )
    case authorizationRestricted(
        driverID: CaptureDriverID,
        mediaType: CaptureMediaTypeID
    )
    case deviceNotFound(CaptureDeviceID)
    case deviceDisconnected(CaptureDeviceID)
    case deviceSuspended(CaptureDeviceID)
    case deviceBusy(CaptureDeviceID)
    case staleCapabilities(
        deviceID: CaptureDeviceID,
        expectedRevision: UInt64,
        actualRevision: UInt64
    )
    case unsupportedFormat(
        deviceID: CaptureDeviceID,
        formatID: CaptureDeviceFormatID
    )
    case unsupportedFrameRate(
        deviceID: CaptureDeviceID,
        formatID: CaptureDeviceFormatID,
        frameRate: Double
    )
    case unsupportedConfiguration(CaptureDeviceID)
    case unsupportedControl(
        deviceID: CaptureDeviceID,
        controlID: CaptureDeviceControlID
    )
    case unsupportedControlValue(
        deviceID: CaptureDeviceID,
        controlID: CaptureDeviceControlID
    )
    case unsupportedStreamCombination(
        deviceID: CaptureDeviceID,
        streamIDs: [CaptureStreamID]
    )
    case unsupportedVideoRotationAngle(
        deviceID: CaptureDeviceID,
        streamID: CaptureStreamID,
        angle: CaptureVideoRotationAngle
    )
    case unsupportedVideoStabilizationMode(
        deviceID: CaptureDeviceID,
        streamID: CaptureStreamID,
        mode: CaptureVideoStabilizationMode
    )
    case unsupportedVideoMirroringMode(
        deviceID: CaptureDeviceID,
        streamID: CaptureStreamID,
        mode: CaptureVideoMirroringMode
    )
    case unsupportedStreamEvents(CaptureDeviceID)
    case bufferExhausted(CaptureDeviceID)
    case backendFailure(
        driverID: CaptureDriverID,
        deviceID: CaptureDeviceID?,
        operation: CaptureDriverOperation,
        code: Int64
    )
    case contractViolation(
        driverID: CaptureDriverID,
        error: CaptureContractError
    )
}
