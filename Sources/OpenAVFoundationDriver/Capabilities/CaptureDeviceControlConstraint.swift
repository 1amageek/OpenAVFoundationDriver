public enum CaptureDeviceControlConstraint: Sendable, Hashable {
    case boolean
    case integer(minimum: Int64, maximum: Int64)
    case scalar(CaptureScalarRange)
    case options([String])

    public static func validatedOptions(
        _ options: [String],
        controlID: CaptureDeviceControlID
    ) throws(CaptureContractError) -> Self {
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
        return .options(options)
    }

    public func accepts(_ value: CaptureDeviceControlValue) -> Bool {
        switch (self, value) {
        case (.boolean, .boolean):
            true
        case let (.integer(minimum, maximum), .integer(value)):
            minimum <= value && value <= maximum
        case let (.scalar(range), .scalar(value)):
            range.contains(value)
        case let (.options(options), .option(value)):
            options.contains(value)
        default:
            false
        }
    }
}
