public struct CaptureDeviceConfiguration: Sendable, Hashable {
    public let deviceID: CaptureDeviceID
    public let capabilityRevision: UInt64
    public let formatID: CaptureDeviceFormatID
    public let frameRate: Double?

    public init(
        deviceID: CaptureDeviceID,
        capabilityRevision: UInt64,
        formatID: CaptureDeviceFormatID,
        frameRate: Double? = nil
    ) throws(CaptureContractError) {
        if let frameRate {
            guard frameRate.isFinite, frameRate > 0 else {
                throw .invalidFrameRate(frameRate)
            }
        }

        self.deviceID = deviceID
        self.capabilityRevision = capabilityRevision
        self.formatID = formatID
        self.frameRate = frameRate
    }
}
