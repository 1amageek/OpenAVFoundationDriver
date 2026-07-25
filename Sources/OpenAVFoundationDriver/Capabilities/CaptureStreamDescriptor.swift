public struct CaptureStreamDescriptor: Sendable, Hashable {
    public let streamID: CaptureStreamID
    public let mediaType: CaptureMediaTypeID
    public let formatIDs: [CaptureDeviceFormatID]

    public init(
        streamID: CaptureStreamID,
        mediaType: CaptureMediaTypeID,
        formatIDs: [CaptureDeviceFormatID]
    ) throws(CaptureContractError) {
        guard !formatIDs.isEmpty else {
            throw .missingStreamFormatIDs(streamID)
        }

        var observedFormatIDs: [CaptureDeviceFormatID] = []
        observedFormatIDs.reserveCapacity(formatIDs.count)
        for formatID in formatIDs {
            guard !observedFormatIDs.contains(formatID) else {
                throw .duplicateStreamFormatID(
                    streamID: streamID,
                    formatID: formatID
                )
            }
            observedFormatIDs.append(formatID)
        }

        self.streamID = streamID
        self.mediaType = mediaType
        self.formatIDs = formatIDs
    }
}
