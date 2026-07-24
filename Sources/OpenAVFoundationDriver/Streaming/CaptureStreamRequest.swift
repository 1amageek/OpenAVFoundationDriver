public struct CaptureStreamRequest: Sendable, Hashable {
    public let configuration: CaptureDeviceConfiguration

    public init(configuration: CaptureDeviceConfiguration) {
        self.configuration = configuration
    }
}
