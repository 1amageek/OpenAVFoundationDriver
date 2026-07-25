public struct CaptureFocusConfiguration: Sendable, Hashable {
    public let mode: CaptureFocusMode
    public let lensPosition: Double?
    public let pointOfInterest: CaptureNormalizedPoint?

    public init(
        mode: CaptureFocusMode,
        lensPosition: Double? = nil,
        pointOfInterest: CaptureNormalizedPoint? = nil
    ) throws(CaptureContractError) {
        if let lensPosition {
            guard mode == .locked,
                  lensPosition.isFinite else {
                throw .invalidControlConfiguration(.focus)
            }
        }

        self.mode = mode
        self.lensPosition = lensPosition
        self.pointOfInterest = pointOfInterest
    }
}
