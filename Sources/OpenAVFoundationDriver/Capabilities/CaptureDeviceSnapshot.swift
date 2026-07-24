/// An identity- and revision-consistent device descriptor and capability pair.
public struct CaptureDeviceSnapshot: Sendable, Hashable {
    public let descriptor: CaptureDeviceDescriptor
    public let capabilities: CaptureDeviceCapabilities

    public init(
        descriptor: CaptureDeviceDescriptor,
        capabilities: CaptureDeviceCapabilities
    ) throws(CaptureContractError) {
        guard descriptor.deviceID == capabilities.deviceID else {
            throw .capabilityDeviceMismatch(
                descriptorDeviceID: descriptor.deviceID,
                capabilitiesDeviceID: capabilities.deviceID
            )
        }
        guard descriptor.capabilityRevision == capabilities.revision else {
            throw .capabilityRevisionMismatch(
                deviceID: descriptor.deviceID,
                descriptorRevision: descriptor.capabilityRevision,
                capabilitiesRevision: capabilities.revision
            )
        }

        self.descriptor = descriptor
        self.capabilities = capabilities
    }
}
