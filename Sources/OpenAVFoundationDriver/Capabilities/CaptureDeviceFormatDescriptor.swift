public struct CaptureDeviceFormatDescriptor: Sendable, Hashable {
    public let formatID: CaptureDeviceFormatID
    public let mediaType: CaptureMediaTypeID
    public let mediaSubtype: CaptureMediaSubtype
    public let dimensions: CaptureDimensions?
    public let frameRateRanges: [CaptureFrameRateRange]

    public init(
        formatID: CaptureDeviceFormatID,
        mediaType: CaptureMediaTypeID,
        mediaSubtype: CaptureMediaSubtype,
        dimensions: CaptureDimensions? = nil,
        frameRateRanges: [CaptureFrameRateRange] = []
    ) {
        self.formatID = formatID
        self.mediaType = mediaType
        self.mediaSubtype = mediaSubtype
        self.dimensions = dimensions
        self.frameRateRanges = frameRateRanges
    }
}
