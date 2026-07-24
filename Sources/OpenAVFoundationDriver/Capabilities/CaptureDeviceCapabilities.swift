public struct CaptureDeviceCapabilities: Sendable, Hashable {
    public let deviceID: CaptureDeviceID
    public let revision: UInt64
    public let formats: [CaptureDeviceFormatDescriptor]
    public let preferredFormatID: CaptureDeviceFormatID
    public let supportsConcurrentStreams: Bool

    public init(
        deviceID: CaptureDeviceID,
        revision: UInt64,
        formats: [CaptureDeviceFormatDescriptor],
        preferredFormatID: CaptureDeviceFormatID,
        supportsConcurrentStreams: Bool
    ) throws(CaptureContractError) {
        guard !formats.isEmpty else {
            throw .missingFormats(deviceID: deviceID)
        }

        var observedFormatIDs: Set<CaptureDeviceFormatID> = []
        for format in formats {
            guard observedFormatIDs.insert(format.formatID).inserted else {
                throw .duplicateFormatID(format.formatID)
            }
        }
        guard observedFormatIDs.contains(preferredFormatID) else {
            throw .preferredFormatNotFound(
                deviceID: deviceID,
                formatID: preferredFormatID
            )
        }

        self.deviceID = deviceID
        self.revision = revision
        self.formats = formats
        self.preferredFormatID = preferredFormatID
        self.supportsConcurrentStreams = supportsConcurrentStreams
    }

    public func preferredConfiguration()
        throws(CaptureContractError) -> CaptureDeviceConfiguration
    {
        try CaptureDeviceConfiguration(
            deviceID: deviceID,
            capabilityRevision: revision,
            formatID: preferredFormatID
        )
    }
}
