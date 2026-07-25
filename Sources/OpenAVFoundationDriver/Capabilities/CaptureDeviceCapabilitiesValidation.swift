extension CaptureDeviceCapabilities {
    /// Returns the request after validating it against this exact revision.
    public func validatedConfiguration(
        _ configuration: CaptureDeviceConfiguration
    ) throws(CaptureDriverError) -> CaptureDeviceConfiguration {
        guard configuration.deviceID == deviceID else {
            throw .deviceNotFound(configuration.deviceID)
        }
        guard configuration.capabilityRevision == revision else {
            throw .staleCapabilities(
                deviceID: deviceID,
                expectedRevision: configuration.capabilityRevision,
                actualRevision: revision
            )
        }
        guard let format = formats.first(
            where: { $0.formatID == configuration.formatID }
        ) else {
            throw .unsupportedFormat(
                deviceID: deviceID,
                formatID: configuration.formatID
            )
        }
        if let frameRate = configuration.frameRate,
           !format.frameRateRanges.contains(
               where: { $0.minimum <= frameRate && frameRate <= $0.maximum }
           ) {
            throw .unsupportedFrameRate(
                deviceID: deviceID,
                formatID: format.formatID,
                frameRate: frameRate
            )
        }

        try validate(configuration.controls)
        return configuration
    }

    /// Returns a group after validating configuration, stream, and sink identity.
    public func validatedStreamGroupRequest(
        _ request: CaptureStreamGroupRequest,
        sinks: [CaptureStreamSinkBinding]
    ) throws(CaptureDriverError) -> CaptureStreamGroupRequest {
        guard request.deviceID == deviceID else {
            throw .deviceNotFound(request.deviceID)
        }

        for streamRequest in request.requests {
            _ = try validatedConfiguration(streamRequest.configuration)
            guard let streamID = streamRequest.streamID,
                  let descriptor = streams.first(
                      where: { $0.streamID == streamID }
                  ),
                  descriptor.formatIDs.contains(
                      streamRequest.configuration.formatID
                  ) else {
                throw .unsupportedStreamCombination(
                    deviceID: deviceID,
                    streamIDs: request.streamIDs
                )
            }
            try validate(
                streamRequest.videoConnectionConfiguration,
                for: descriptor
            )
        }

        guard supportedStreamCombinations.contains(
            where: { $0.matches(request.streamIDs) }
        ) else {
            throw .unsupportedStreamCombination(
                deviceID: deviceID,
                streamIDs: request.streamIDs
            )
        }

        var sinkIDs: [CaptureStreamID] = []
        sinkIDs.reserveCapacity(sinks.count)
        for sink in sinks {
            sinkIDs.append(sink.streamID)
        }
        let sinkIDsAreUnique = sinkIDs.indices.allSatisfy { index in
            !sinkIDs[..<index].contains(sinkIDs[index])
        }
        guard sinkIDs.count == request.streamIDs.count,
              sinkIDsAreUnique,
              sinkIDs.allSatisfy(request.streamIDs.contains) else {
            throw .unsupportedStreamCombination(
                deviceID: deviceID,
                streamIDs: request.streamIDs
            )
        }

        return request
    }

    /// Returns the request after validating its stream and connection policy.
    public func validatedStreamRequest(
        _ request: CaptureStreamRequest
    ) throws(CaptureDriverError) -> CaptureStreamRequest {
        _ = try validatedConfiguration(request.configuration)

        let descriptor: CaptureStreamDescriptor
        if let streamID = request.streamID {
            guard let requested = streams.first(where: {
                $0.streamID == streamID
            }),
            requested.formatIDs.contains(request.configuration.formatID) else {
                throw .unsupportedStreamCombination(
                    deviceID: deviceID,
                    streamIDs: [streamID]
                )
            }
            descriptor = requested
        } else {
            guard let preferred = streams.first(where: {
                $0.formatIDs.contains(request.configuration.formatID)
            }) else {
                throw .unsupportedStreamCombination(
                    deviceID: deviceID,
                    streamIDs: []
                )
            }
            descriptor = preferred
        }

        try validate(
            request.videoConnectionConfiguration,
            for: descriptor
        )
        return request
    }

    private func validate(
        _ requested: CaptureDeviceControls
    ) throws(CaptureDriverError) {
        if let focus = requested.focus {
            guard let capability = controls.focus else {
                throw unsupported(.focus)
            }
            let lensPositionIsSupported = focus.lensPosition.map {
                capability.lensPositionRange?.contains($0) == true
            } ?? true
            guard capability.supportedModes.contains(focus.mode),
                  lensPositionIsSupported,
                  focus.pointOfInterest == nil
                    || capability.supportsPointOfInterest else {
                throw unsupportedValue(.focus)
            }
        }

        if let exposure = requested.exposure {
            guard let capability = controls.exposure else {
                throw unsupported(.exposure)
            }
            let durationIsSupported = exposure.duration.map {
                capability.durationRange?.contains($0) == true
            } ?? true
            let isoIsSupported = exposure.iso.map {
                capability.isoRange?.contains($0) == true
            } ?? true
            guard capability.supportedModes.contains(exposure.mode),
                  durationIsSupported,
                  isoIsSupported,
                  exposure.pointOfInterest == nil
                    || capability.supportsPointOfInterest else {
                throw unsupportedValue(.exposure)
            }
        }

        if let whiteBalance = requested.whiteBalance {
            guard let capability = controls.whiteBalance else {
                throw unsupported(.whiteBalance)
            }
            let gainsAreSupported = whiteBalance.gains.map { gains in
                guard let range = capability.gainRange else {
                    return false
                }
                return range.contains(gains.red)
                    && range.contains(gains.green)
                    && range.contains(gains.blue)
            } ?? true
            guard capability.supportedModes.contains(whiteBalance.mode),
                  gainsAreSupported else {
                throw unsupportedValue(.whiteBalance)
            }
        }

        if let zoom = requested.zoom {
            guard let capability = controls.zoom else {
                throw unsupported(.zoom)
            }
            guard capability.factorRange.contains(zoom.factor) else {
                throw unsupportedValue(.zoom)
            }
        }

        for setting in requested.deviceSpecific {
            guard let descriptor = controls.deviceSpecific.first(
                where: { $0.controlID == setting.controlID }
            ) else {
                throw unsupported(setting.controlID)
            }
            guard descriptor.constraint.accepts(setting.value) else {
                throw unsupportedValue(setting.controlID)
            }
        }
    }

    private func unsupported(
        _ controlID: CaptureDeviceControlID
    ) -> CaptureDriverError {
        .unsupportedControl(deviceID: deviceID, controlID: controlID)
    }

    private func unsupportedValue(
        _ controlID: CaptureDeviceControlID
    ) -> CaptureDriverError {
        .unsupportedControlValue(deviceID: deviceID, controlID: controlID)
    }

    private func validate(
        _ configuration: CaptureVideoConnectionConfiguration,
        for stream: CaptureStreamDescriptor
    ) throws(CaptureDriverError) {
        guard let capabilities = stream.videoConnectionCapabilities else {
            if let orientation = configuration.orientation {
                throw .unsupportedVideoOrientation(
                    deviceID: deviceID,
                    streamID: stream.streamID,
                    orientation: orientation
                )
            }
            if let mode = configuration.stabilizationMode {
                throw .unsupportedVideoStabilizationMode(
                    deviceID: deviceID,
                    streamID: stream.streamID,
                    mode: mode
                )
            }
            if let mode = configuration.mirroringMode {
                throw .unsupportedVideoMirroringMode(
                    deviceID: deviceID,
                    streamID: stream.streamID,
                    mode: mode
                )
            }
            return
        }

        if let orientation = configuration.orientation,
           !capabilities.supportedOrientations.contains(orientation) {
            throw .unsupportedVideoOrientation(
                deviceID: deviceID,
                streamID: stream.streamID,
                orientation: orientation
            )
        }
        if let mode = configuration.stabilizationMode,
           !capabilities.supportedStabilizationModes.contains(mode) {
            throw .unsupportedVideoStabilizationMode(
                deviceID: deviceID,
                streamID: stream.streamID,
                mode: mode
            )
        }
        if let mode = configuration.mirroringMode,
           !capabilities.supportedMirroringModes.contains(mode) {
            throw .unsupportedVideoMirroringMode(
                deviceID: deviceID,
                streamID: stream.streamID,
                mode: mode
            )
        }
    }
}
