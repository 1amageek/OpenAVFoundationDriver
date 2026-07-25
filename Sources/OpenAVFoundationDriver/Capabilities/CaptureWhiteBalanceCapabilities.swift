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

        var observedModes: Set<CaptureWhiteBalanceMode> = []
        for mode in supportedModes {
            guard observedModes.insert(mode).inserted else {
                throw .duplicateControlMode(.whiteBalance)
            }
        }

        self.supportedModes = supportedModes
        self.gainRange = gainRange
    }
}
