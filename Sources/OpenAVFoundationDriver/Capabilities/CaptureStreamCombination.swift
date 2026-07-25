public struct CaptureStreamCombination: Sendable, Hashable {
    public let streamIDs: [CaptureStreamID]

    public init(
        streamIDs: [CaptureStreamID]
    ) throws(CaptureContractError) {
        guard !streamIDs.isEmpty else {
            throw .missingConcurrentStreamRequests
        }

        var observedStreamIDs: Set<CaptureStreamID> = []
        for streamID in streamIDs {
            guard observedStreamIDs.insert(streamID).inserted else {
                throw .duplicateStreamID(streamID)
            }
        }
        self.streamIDs = streamIDs
    }

    public func matches(_ streamIDs: [CaptureStreamID]) -> Bool {
        self.streamIDs.count == streamIDs.count
            && Set(self.streamIDs) == Set(streamIDs)
    }
}
