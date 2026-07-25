public struct CaptureWhiteBalanceConfiguration: Sendable, Hashable {
    public let mode: CaptureWhiteBalanceMode
    public let gains: CaptureWhiteBalanceGains?

    public init(
        mode: CaptureWhiteBalanceMode,
        gains: CaptureWhiteBalanceGains? = nil
    ) throws(CaptureContractError) {
        if gains != nil, mode != .locked {
            throw .invalidControlConfiguration(.whiteBalance)
        }

        self.mode = mode
        self.gains = gains
    }
}
