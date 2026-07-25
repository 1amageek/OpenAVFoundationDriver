public struct CaptureWhiteBalanceCapabilities: Sendable, Hashable {
    public let supportedModes: [CaptureWhiteBalanceMode]
    public let gainRange: CaptureScalarRange?

    public init(
        supportedModes: [CaptureWhiteBalanceMode],
        gainRange: CaptureScalarRange? = nil
    ) throws(CaptureContractError) {
        guard !supportedModes.isEmpty else {
            throw .missingControlModes(.whiteBalance)
        }

        var observedModes: [CaptureWhiteBalanceMode] = []
        observedModes.reserveCapacity(supportedModes.count)
        for mode in supportedModes {
            guard !observedModes.contains(mode) else {
                throw .duplicateControlMode(.whiteBalance)
            }
            observedModes.append(mode)
        }

        self.supportedModes = supportedModes
        self.gainRange = gainRange
    }
}
