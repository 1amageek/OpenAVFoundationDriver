public struct CaptureStreamRequest: Sendable, Hashable {
    public let streamID: CaptureStreamID?
    public let configuration: CaptureDeviceConfiguration

    public init(
        streamID: CaptureStreamID? = nil,
        configuration: CaptureDeviceConfiguration
    ) {
        self.streamID = streamID
        self.configuration = configuration
    }
}
