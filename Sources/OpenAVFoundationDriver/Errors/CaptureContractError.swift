public enum CaptureContractError: Error, Sendable, Equatable {
    case emptyIdentifier(CaptureIdentifierKind)
    case emptyLocalizedName
    case missingDeviceTypes
    case duplicateDeviceType(CaptureDeviceTypeID)
    case missingMediaTypes
    case duplicateMediaType(CaptureMediaTypeID)
    case invalidDimensions(width: Int, height: Int)
    case invalidFrameRate(Double)
    case invalidFrameRateRange(minimum: Double, maximum: Double)
    case missingFormats(deviceID: CaptureDeviceID)
    case duplicateFormatID(CaptureDeviceFormatID)
    case preferredFormatNotFound(
        deviceID: CaptureDeviceID,
        formatID: CaptureDeviceFormatID
    )
    case capabilityDeviceMismatch(
        descriptorDeviceID: CaptureDeviceID,
        capabilitiesDeviceID: CaptureDeviceID
    )
    case capabilityRevisionMismatch(
        deviceID: CaptureDeviceID,
        descriptorRevision: UInt64,
        capabilitiesRevision: UInt64
    )
    case invalidScalarRange(
        minimum: Double,
        maximum: Double
    )
    case invalidNormalizedPoint(x: Double, y: Double)
    case missingControlModes(CaptureDeviceControlID)
    case duplicateControlMode(CaptureDeviceControlID)
    case invalidControlConfiguration(CaptureDeviceControlID)
    case duplicateDeviceControlID(CaptureDeviceControlID)
    case missingDeviceControlOptions(CaptureDeviceControlID)
    case duplicateDeviceControlOption(
        controlID: CaptureDeviceControlID,
        option: String
    )
    case duplicateDeviceControlSetting(CaptureDeviceControlID)
    case missingStreamFormatIDs(CaptureStreamID)
    case duplicateStreamFormatID(
        streamID: CaptureStreamID,
        formatID: CaptureDeviceFormatID
    )
    case duplicateStreamID(CaptureStreamID)
    case missingStreamCombinations(CaptureDeviceID)
    case duplicateStreamCombination
    case concurrentStreamSupportMismatch(CaptureDeviceID)
    case streamFormatNotFound(
        streamID: CaptureStreamID,
        formatID: CaptureDeviceFormatID
    )
    case streamNotFound(
        deviceID: CaptureDeviceID,
        streamID: CaptureStreamID
    )
    case missingConcurrentStreamRequests
    case streamRequestDeviceMismatch(
        expected: CaptureDeviceID,
        actual: CaptureDeviceID
    )
    case streamRequestRevisionMismatch(
        expected: UInt64,
        actual: UInt64
    )
    case streamRequestControlMismatch(CaptureDeviceID)
}
