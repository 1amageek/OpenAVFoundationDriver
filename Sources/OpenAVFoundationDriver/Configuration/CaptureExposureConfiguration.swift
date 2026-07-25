public struct CaptureExposureConfiguration: Sendable, Hashable {
    public let mode: CaptureExposureMode
    public let duration: CMTime?
    public let iso: Double?
    public let pointOfInterest: CaptureNormalizedPoint?

    public init(
        mode: CaptureExposureMode,
        duration: CMTime? = nil,
        iso: Double? = nil,
        pointOfInterest: CaptureNormalizedPoint? = nil
    ) throws(CaptureContractError) {
        if duration != nil || iso != nil {
            guard mode == .custom else {
                throw .invalidControlConfiguration(.exposure)
            }
        }
        if let duration {
            guard duration.isNumeric, duration > .zero else {
                throw .invalidControlConfiguration(.exposure)
            }
        }
        if let iso {
            guard iso.isFinite, iso > 0 else {
                throw .invalidControlConfiguration(.exposure)
            }
        }

        self.mode = mode
        self.duration = duration
        self.iso = iso
        self.pointOfInterest = pointOfInterest
    }
}
