public struct CaptureDeviceID: Sendable, Hashable {
    public let driverID: CaptureDriverID
    public let localID: String

    public init(
        driverID: CaptureDriverID,
        localID: String
    ) throws(CaptureContractError) {
        guard !localID.isEmpty else {
            throw .emptyIdentifier(.device)
        }
        self.driverID = driverID
        self.localID = localID
    }
}
