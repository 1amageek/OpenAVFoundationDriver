/// Selects either every provider-defined device type or an explicit nonempty set.
public struct CaptureDeviceTypeSelection: Sendable, Hashable {
    private enum Storage: Sendable, Hashable {
        case all
        case matching([CaptureDeviceTypeID])
    }

    private let storage: Storage

    private init(storage: Storage) {
        self.storage = storage
    }

    /// Selects every device type exposed by a provider.
    public static let all = CaptureDeviceTypeSelection(storage: .all)

    /// Creates a selection for one or more unique device types.
    public init(
        matching deviceTypeIDs: [CaptureDeviceTypeID]
    ) throws(CaptureContractError) {
        guard !deviceTypeIDs.isEmpty else {
            throw .missingDeviceTypes
        }

        var observedDeviceTypes: Set<CaptureDeviceTypeID> = []
        for deviceTypeID in deviceTypeIDs {
            guard observedDeviceTypes.insert(deviceTypeID).inserted else {
                throw .duplicateDeviceType(deviceTypeID)
            }
        }

        self.storage = .matching(deviceTypeIDs)
    }

    /// The explicit device types, or `nil` when the selection includes all types.
    public var requestedDeviceTypeIDs: [CaptureDeviceTypeID]? {
        switch storage {
        case .all:
            nil
        case let .matching(deviceTypeIDs):
            deviceTypeIDs
        }
    }

    /// Returns whether the selection contains the supplied device type.
    public func includes(_ deviceTypeID: CaptureDeviceTypeID) -> Bool {
        switch storage {
        case .all:
            true
        case let .matching(deviceTypeIDs):
            deviceTypeIDs.contains(deviceTypeID)
        }
    }
}
