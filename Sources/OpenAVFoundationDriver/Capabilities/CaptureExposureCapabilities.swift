public struct CaptureExposureCapabilities: Sendable, Hashable {
    public let supportedModes: [CaptureExposureMode]
    public let durationRange: CaptureExposureDurationRange?
    public let isoRange: CaptureScalarRange?
    public let supportsPointOfInterest: Bool

    public init(
        supportedModes: [CaptureExposureMode],
        durationRange: CaptureExposureDurationRange? = nil,
        isoRange: CaptureScalarRange? = nil,
        supportsPointOfInterest: Bool = false
    ) throws(CaptureContractError) {
        guard !supportedModes.isEmpty else {
            throw .missingControlModes(.exposure)
        }

        var observedModes: [CaptureExposureMode] = []
        observedModes.reserveCapacity(supportedModes.count)
        for mode in supportedModes {
            guard !observedModes.contains(mode) else {
                throw .duplicateControlMode(.exposure)
            }
            observedModes.append(mode)
        }

        self.supportedModes = supportedModes
        self.durationRange = durationRange
        self.isoRange = isoRange
        self.supportsPointOfInterest = supportsPointOfInterest
    }
}
