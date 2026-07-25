public struct CaptureStreamRequest: Sendable, Hashable {
    public let streamID: CaptureStreamID?
    public let configuration: CaptureDeviceConfiguration
    public let videoConnectionConfiguration:
        CaptureVideoConnectionConfiguration

    public init(
        streamID: CaptureStreamID? = nil,
        configuration: CaptureDeviceConfiguration,
        videoConnectionConfiguration:
            CaptureVideoConnectionConfiguration = .unchanged
    ) {
        self.streamID = streamID
        self.configuration = configuration
        self.videoConnectionConfiguration = videoConnectionConfiguration
    }
}
