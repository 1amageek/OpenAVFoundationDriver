public struct CaptureDeviceCapabilities: Sendable, Hashable {
    public let deviceID: CaptureDeviceID
    public let revision: UInt64
    public let formats: [CaptureDeviceFormatDescriptor]
    public let preferredFormatID: CaptureDeviceFormatID
    public let controls: CaptureDeviceControlCapabilities
    public let streams: [CaptureStreamDescriptor]
    public let supportedStreamCombinations: [CaptureStreamCombination]

    @available(
        *,
        deprecated,
        message: "Use supportedStreamCombinations as the authoritative contract."
    )
    public var supportsConcurrentStreams: Bool {
        supportedStreamCombinations.contains {
            $0.streamIDs.count > 1
        }
    }

    public init(
        deviceID: CaptureDeviceID,
        revision: UInt64,
        formats: [CaptureDeviceFormatDescriptor],
        preferredFormatID: CaptureDeviceFormatID,
        supportsConcurrentStreams: Bool,
        controls: CaptureDeviceControlCapabilities = .none,
        streams: [CaptureStreamDescriptor] = [],
        supportedStreamCombinations: [CaptureStreamCombination] = []
    ) throws(CaptureContractError) {
        guard !formats.isEmpty else {
            throw .missingFormats(deviceID: deviceID)
        }

        var observedFormatIDs: Set<CaptureDeviceFormatID> = []
        for format in formats {
            guard observedFormatIDs.insert(format.formatID).inserted else {
                throw .duplicateFormatID(format.formatID)
            }
        }
        guard observedFormatIDs.contains(preferredFormatID) else {
            throw .preferredFormatNotFound(
                deviceID: deviceID,
                formatID: preferredFormatID
            )
        }

        var observedStreamIDs: Set<CaptureStreamID> = []
        for stream in streams {
            guard observedStreamIDs.insert(stream.streamID).inserted else {
                throw .duplicateStreamID(stream.streamID)
            }
            for formatID in stream.formatIDs {
                guard observedFormatIDs.contains(formatID) else {
                    throw .streamFormatNotFound(
                        streamID: stream.streamID,
                        formatID: formatID
                    )
                }
            }
        }

        if !streams.isEmpty, supportedStreamCombinations.isEmpty {
            throw .missingStreamCombinations(deviceID)
        }

        var observedCombinationSets: Set<Set<CaptureStreamID>> = []
        var hasConcurrentCombination = false
        for combination in supportedStreamCombinations {
            for streamID in combination.streamIDs {
                guard observedStreamIDs.contains(streamID) else {
                    throw .streamNotFound(
                        deviceID: deviceID,
                        streamID: streamID
                    )
                }
            }
            let streamIDSet = Set(combination.streamIDs)
            guard observedCombinationSets.insert(streamIDSet).inserted else {
                throw .duplicateStreamCombination
            }
            hasConcurrentCombination = hasConcurrentCombination
                || combination.streamIDs.count > 1
        }
        guard supportsConcurrentStreams == hasConcurrentCombination else {
            throw .concurrentStreamSupportMismatch(deviceID)
        }

        self.deviceID = deviceID
        self.revision = revision
        self.formats = formats
        self.preferredFormatID = preferredFormatID
        self.controls = controls
        self.streams = streams
        self.supportedStreamCombinations = supportedStreamCombinations
    }

    public func preferredConfiguration()
        throws(CaptureContractError) -> CaptureDeviceConfiguration
    {
        try CaptureDeviceConfiguration(
            deviceID: deviceID,
            capabilityRevision: revision,
            formatID: preferredFormatID
        )
    }
}
