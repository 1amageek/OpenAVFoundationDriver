public struct CaptureDeviceControlDescriptor: Sendable, Hashable {
    public let controlID: CaptureDeviceControlID
    public let constraint: CaptureDeviceControlConstraint

    public init(
        controlID: CaptureDeviceControlID,
        constraint: CaptureDeviceControlConstraint
    ) throws(CaptureContractError) {
        switch constraint {
        case .boolean, .scalar:
            break
        case let .integer(minimum, maximum):
            guard maximum >= minimum else {
                throw .invalidControlConfiguration(controlID)
            }
        case let .options(options):
            guard !options.isEmpty else {
                throw .missingDeviceControlOptions(controlID)
            }
            var observedOptions: [String] = []
            observedOptions.reserveCapacity(options.count)
            for option in options {
                guard !option.isEmpty else {
                    throw .invalidControlConfiguration(controlID)
                }
                guard !observedOptions.contains(option) else {
                    throw .duplicateDeviceControlOption(
                        controlID: controlID,
                        option: option
                    )
                }
                observedOptions.append(option)
            }
        }

        self.controlID = controlID
        self.constraint = constraint
    }
}
