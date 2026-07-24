public struct CaptureDeviceDescriptor: Sendable, Hashable {
    public let deviceID: CaptureDeviceID
    public let deviceTypeID: CaptureDeviceTypeID
    public let localizedName: String
    public let manufacturer: String
    public let modelID: String
    public let position: CaptureDevicePosition
    public let mediaTypes: [CaptureMediaTypeID]
    public let capabilityRevision: UInt64
    public let isConnected: Bool
    public let isSuspended: Bool

    public init(
        deviceID: CaptureDeviceID,
        deviceTypeID: CaptureDeviceTypeID,
        localizedName: String,
        manufacturer: String,
        modelID: String,
        position: CaptureDevicePosition,
        mediaTypes: [CaptureMediaTypeID],
        capabilityRevision: UInt64,
        isConnected: Bool = true,
        isSuspended: Bool = false
    ) throws(CaptureContractError) {
        guard !localizedName.isEmpty else {
            throw .emptyLocalizedName
        }
        guard !mediaTypes.isEmpty else {
            throw .missingMediaTypes
        }

        var observedMediaTypes: Set<CaptureMediaTypeID> = []
        for mediaType in mediaTypes {
            guard observedMediaTypes.insert(mediaType).inserted else {
                throw .duplicateMediaType(mediaType)
            }
        }

        self.deviceID = deviceID
        self.deviceTypeID = deviceTypeID
        self.localizedName = localizedName
        self.manufacturer = manufacturer
        self.modelID = modelID
        self.position = position
        self.mediaTypes = mediaTypes
        self.capabilityRevision = capabilityRevision
        self.isConnected = isConnected
        self.isSuspended = isSuspended
    }
}
