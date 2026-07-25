public struct CaptureStreamGroupRequest: Sendable, Hashable {
    public let requests: [CaptureStreamRequest]

    public init(
        requests: [CaptureStreamRequest]
    ) throws(CaptureContractError) {
        guard requests.count > 1 else {
            throw .missingConcurrentStreamRequests
        }
        guard let firstRequest = requests.first else {
            throw .missingConcurrentStreamRequests
        }

        var observedStreamIDs: [CaptureStreamID] = []
        observedStreamIDs.reserveCapacity(requests.count)
        for request in requests {
            guard let streamID = request.streamID else {
                throw .missingConcurrentStreamRequests
            }
            guard !observedStreamIDs.contains(streamID) else {
                throw .duplicateStreamID(streamID)
            }
            observedStreamIDs.append(streamID)
            guard request.configuration.deviceID
                    == firstRequest.configuration.deviceID else {
                throw .streamRequestDeviceMismatch(
                    expected: firstRequest.configuration.deviceID,
                    actual: request.configuration.deviceID
                )
            }
            guard request.configuration.capabilityRevision
                    == firstRequest.configuration.capabilityRevision else {
                throw .streamRequestRevisionMismatch(
                    expected: firstRequest.configuration.capabilityRevision,
                    actual: request.configuration.capabilityRevision
                )
            }
            guard request.configuration.controls
                    == firstRequest.configuration.controls else {
                throw .streamRequestControlMismatch(
                    firstRequest.configuration.deviceID
                )
            }
        }

        self.requests = requests
    }

    public var deviceID: CaptureDeviceID {
        requests[0].configuration.deviceID
    }

    public var capabilityRevision: UInt64 {
        requests[0].configuration.capabilityRevision
    }

    public var streamIDs: [CaptureStreamID] {
        var result: [CaptureStreamID] = []
        result.reserveCapacity(requests.count)
        for request in requests {
            if let streamID = request.streamID {
                result.append(streamID)
            }
        }
        return result
    }
}
