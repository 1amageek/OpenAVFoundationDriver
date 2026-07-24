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
}
