public struct CaptureStreamCombination: Sendable, Hashable {
    public let streamIDs: [CaptureStreamID]

    public init(
        streamIDs: [CaptureStreamID]
    ) throws(CaptureContractError) {
        guard !streamIDs.isEmpty else {
            throw .missingConcurrentStreamRequests
        }

        var observedStreamIDs: [CaptureStreamID] = []
        observedStreamIDs.reserveCapacity(streamIDs.count)
        for streamID in streamIDs {
            guard !observedStreamIDs.contains(streamID) else {
                throw .duplicateStreamID(streamID)
            }
            observedStreamIDs.append(streamID)
        }
        self.streamIDs = streamIDs
    }

    public func matches(_ streamIDs: [CaptureStreamID]) -> Bool {
        self.streamIDs.count == streamIDs.count
            && self.streamIDs.allSatisfy(streamIDs.contains)
    }
}
