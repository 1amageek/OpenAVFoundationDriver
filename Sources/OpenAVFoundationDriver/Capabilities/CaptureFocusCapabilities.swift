public struct CaptureFocusCapabilities: Sendable, Hashable {
    public let supportedModes: [CaptureFocusMode]
    public let lensPositionRange: CaptureScalarRange?
    public let supportsPointOfInterest: Bool

    public init(
        supportedModes: [CaptureFocusMode],
        lensPositionRange: CaptureScalarRange? = nil,
        supportsPointOfInterest: Bool = false
    ) throws(CaptureContractError) {
        guard !supportedModes.isEmpty else {
            throw .missingControlModes(.focus)
        }

        var observedModes: [CaptureFocusMode] = []
        observedModes.reserveCapacity(supportedModes.count)
        for mode in supportedModes {
            guard !observedModes.contains(mode) else {
                throw .duplicateControlMode(.focus)
            }
            observedModes.append(mode)
        }
        if let lensPositionRange {
            guard lensPositionRange.minimum >= 0,
                  lensPositionRange.maximum <= 1 else {
                throw .invalidScalarRange(
                    minimum: lensPositionRange.minimum,
                    maximum: lensPositionRange.maximum
                )
            }
        }

        self.supportedModes = supportedModes
        self.lensPositionRange = lensPositionRange
        self.supportsPointOfInterest = supportsPointOfInterest
    }
}
