public struct CaptureStreamDropEvent: Sendable, Equatable {
    public let presentationTimeStamp: CMTime
    public let cumulativeCount: UInt64
    public let reason: CaptureStreamDropReason

    public init(
        presentationTimeStamp: CMTime,
        cumulativeCount: UInt64,
        reason: CaptureStreamDropReason
    ) {
        self.presentationTimeStamp = presentationTimeStamp
        self.cumulativeCount = cumulativeCount
        self.reason = reason
    }
}
