public struct CaptureDiscoveryRequest: Sendable, Equatable {
    /// The explicit all-or-matching device-type selection.
    public let deviceTypeSelection: CaptureDeviceTypeSelection
    public let mediaType: CaptureMediaTypeID?
    public let position: CaptureDevicePosition

    public init(
        deviceTypeSelection: CaptureDeviceTypeSelection = .all,
        mediaType: CaptureMediaTypeID? = nil,
        position: CaptureDevicePosition = .unspecified
    ) {
        self.deviceTypeSelection = deviceTypeSelection
        self.mediaType = mediaType
        self.position = position
    }
}
