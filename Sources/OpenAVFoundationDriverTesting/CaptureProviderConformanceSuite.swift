public enum CaptureProviderConformanceSuite {
#if hasFeature(Embedded)
    public static func discoveredDevices(
        from provider: any CaptureDeviceProvider,
        matching request: CaptureDiscoveryRequest
    ) throws(CaptureProviderConformanceError)
        -> [CaptureDeviceDescriptor]
    {
        let descriptors: [CaptureDeviceDescriptor]
        do {
            descriptors = try provider.devices(matching: request)
        } catch {
            throw .driver(error)
        }
        try validate(
            descriptors,
            driverID: provider.driverID,
            request: request
        )
        return descriptors
    }

    public static func openedDevice(
        from provider: any CaptureDeviceProvider,
        descriptor: CaptureDeviceDescriptor
    ) throws(CaptureProviderConformanceError) -> CaptureProviderOpenResult {
        let handle: any CaptureDeviceHandle
        let snapshot: CaptureDeviceSnapshot
        do {
            handle = try provider.deviceHandle(for: descriptor.deviceID)
            snapshot = try handle.snapshot()
        } catch {
            throw .driver(error)
        }
        try validateOpenedSnapshot(
            snapshot,
            expectedDeviceID: descriptor.deviceID
        )
        return CaptureProviderOpenResult(handle: handle, snapshot: snapshot)
    }

    public static func configuredSnapshot(
        from handle: any CaptureDeviceHandle,
        configuration: CaptureDeviceConfiguration
    ) throws(CaptureProviderConformanceError) -> CaptureDeviceSnapshot {
        let initialSnapshot: CaptureDeviceSnapshot
        let resultingSnapshot: CaptureDeviceSnapshot
        do {
            initialSnapshot = try handle.snapshot()
            _ = try initialSnapshot.capabilities.validatedConfiguration(
                configuration
            )
            resultingSnapshot = try handle.configure(configuration)
        } catch {
            throw .driver(error)
        }
        try validateOpenedSnapshot(
            resultingSnapshot,
            expectedDeviceID: configuration.deviceID
        )
        return resultingSnapshot
    }

    public static func exerciseStreamLifecycle(
        on handle: any CaptureDeviceHandle,
        request: CaptureStreamRequest,
        sink: any CaptureSampleSink
    ) throws(CaptureProviderConformanceError) {
        do {
            let stream = try handle.stream(for: request, sink: sink)
            try stream.start()
            try stream.shutdown()
            try stream.shutdown()
        } catch {
            throw .driver(error)
        }
    }

    public static func exerciseHandleShutdown(
        _ handle: any CaptureDeviceHandle,
        deviceID: CaptureDeviceID
    ) throws(CaptureProviderConformanceError) {
        do {
            try handle.shutdown()
            try handle.shutdown()
        } catch {
            throw .driver(error)
        }

        do {
            _ = try handle.snapshot()
        } catch {
            return
        }
        throw .handleRemainedOpen(deviceID)
    }

    public static func exerciseDeviceEventLifecycle(
        from provider: any CaptureDeviceEventProvider,
        matching request: CaptureDiscoveryRequest,
        sink: any CaptureDeviceEventSink
    ) throws(CaptureProviderConformanceError) {
        let subscription: any CaptureDeviceEventSubscription
        do {
            subscription = try provider.deviceEventSubscription(
                matching: request,
                sink: sink
            )
        } catch {
            throw .driver(error)
        }
        guard subscription.driverID == provider.driverID else {
            throw .unexpectedDriver(
                expected: provider.driverID,
                actual: subscription.driverID
            )
        }
        do {
            try subscription.start()
            try subscription.shutdown()
            try subscription.shutdown()
        } catch {
            throw .driver(error)
        }
    }

    public static func exerciseStreamGroupLifecycle(
        on handle: any CaptureMultiStreamDeviceHandle,
        request: CaptureStreamGroupRequest,
        sinks: [CaptureStreamSinkBinding]
    ) throws(CaptureProviderConformanceError) {
        let snapshot: CaptureDeviceSnapshot
        let group: any CaptureStreamGroup
        do {
            snapshot = try handle.snapshot()
            _ = try snapshot.capabilities.validatedStreamGroupRequest(
                request,
                sinks: sinks
            )
            group = try handle.streamGroup(for: request, sinks: sinks)
        } catch {
            throw .driver(error)
        }
        guard group.deviceID == request.deviceID,
              haveSameUniqueMembers(
                  group.streamIDs,
                  request.streamIDs
              ) else {
            throw .streamGroupMismatch(request.deviceID)
        }
        do {
            try group.start()
            try group.shutdown()
            try group.shutdown()
        } catch {
            throw .driver(error)
        }
    }
#else
    public static func discoveredDevices(
        from provider: any CaptureDeviceProvider,
        matching request: CaptureDiscoveryRequest
    ) async throws(CaptureProviderConformanceError)
        -> [CaptureDeviceDescriptor]
    {
        let descriptors: [CaptureDeviceDescriptor]
        do {
            descriptors = try await provider.devices(matching: request)
        } catch {
            throw .driver(error)
        }
        try validate(
            descriptors,
            driverID: provider.driverID,
            request: request
        )
        return descriptors
    }

    public static func openedDevice(
        from provider: any CaptureDeviceProvider,
        descriptor: CaptureDeviceDescriptor
    ) async throws(CaptureProviderConformanceError)
        -> CaptureProviderOpenResult
    {
        let handle: any CaptureDeviceHandle
        let snapshot: CaptureDeviceSnapshot
        do {
            handle = try await provider.deviceHandle(
                for: descriptor.deviceID
            )
            snapshot = try await handle.snapshot()
        } catch {
            throw .driver(error)
        }
        try validateOpenedSnapshot(
            snapshot,
            expectedDeviceID: descriptor.deviceID
        )
        return CaptureProviderOpenResult(handle: handle, snapshot: snapshot)
    }

    public static func configuredSnapshot(
        from handle: any CaptureDeviceHandle,
        configuration: CaptureDeviceConfiguration
    ) async throws(CaptureProviderConformanceError)
        -> CaptureDeviceSnapshot
    {
        let initialSnapshot: CaptureDeviceSnapshot
        let resultingSnapshot: CaptureDeviceSnapshot
        do {
            initialSnapshot = try await handle.snapshot()
            _ = try initialSnapshot.capabilities.validatedConfiguration(
                configuration
            )
            resultingSnapshot = try await handle.configure(configuration)
        } catch {
            throw .driver(error)
        }
        try validateOpenedSnapshot(
            resultingSnapshot,
            expectedDeviceID: configuration.deviceID
        )
        return resultingSnapshot
    }

    public static func exerciseStreamLifecycle(
        on handle: any CaptureDeviceHandle,
        request: CaptureStreamRequest,
        sink: any CaptureSampleSink
    ) async throws(CaptureProviderConformanceError) {
        do {
            let stream = try await handle.stream(for: request, sink: sink)
            try await stream.start()
            try await stream.shutdown()
            try await stream.shutdown()
        } catch {
            throw .driver(error)
        }
    }

    public static func exerciseHandleShutdown(
        _ handle: any CaptureDeviceHandle,
        deviceID: CaptureDeviceID
    ) async throws(CaptureProviderConformanceError) {
        do {
            try await handle.shutdown()
            try await handle.shutdown()
        } catch {
            throw .driver(error)
        }

        do {
            _ = try await handle.snapshot()
        } catch {
            return
        }
        throw .handleRemainedOpen(deviceID)
    }

    public static func exerciseDeviceEventLifecycle(
        from provider: any CaptureDeviceEventProvider,
        matching request: CaptureDiscoveryRequest,
        sink: any CaptureDeviceEventSink
    ) async throws(CaptureProviderConformanceError) {
        let subscription: any CaptureDeviceEventSubscription
        do {
            subscription = try await provider.deviceEventSubscription(
                matching: request,
                sink: sink
            )
        } catch {
            throw .driver(error)
        }
        guard subscription.driverID == provider.driverID else {
            throw .unexpectedDriver(
                expected: provider.driverID,
                actual: subscription.driverID
            )
        }
        do {
            try await subscription.start()
            try await subscription.shutdown()
            try await subscription.shutdown()
        } catch {
            throw .driver(error)
        }
    }

    public static func exerciseStreamGroupLifecycle(
        on handle: any CaptureMultiStreamDeviceHandle,
        request: CaptureStreamGroupRequest,
        sinks: [CaptureStreamSinkBinding]
    ) async throws(CaptureProviderConformanceError) {
        let snapshot: CaptureDeviceSnapshot
        let group: any CaptureStreamGroup
        do {
            snapshot = try await handle.snapshot()
            _ = try snapshot.capabilities.validatedStreamGroupRequest(
                request,
                sinks: sinks
            )
            group = try await handle.streamGroup(
                for: request,
                sinks: sinks
            )
        } catch {
            throw .driver(error)
        }
        guard group.deviceID == request.deviceID,
              haveSameUniqueMembers(
                  group.streamIDs,
                  request.streamIDs
              ) else {
            throw .streamGroupMismatch(request.deviceID)
        }
        do {
            try await group.start()
            try await group.shutdown()
            try await group.shutdown()
        } catch {
            throw .driver(error)
        }
    }
#endif

    public static func validate(
        _ descriptors: [CaptureDeviceDescriptor],
        driverID: CaptureDriverID,
        request: CaptureDiscoveryRequest
    ) throws(CaptureProviderConformanceError) {
        var observedDeviceIDs: [CaptureDeviceID] = []
        for descriptor in descriptors {
            guard descriptor.deviceID.driverID == driverID else {
                throw .unexpectedDriver(
                    expected: driverID,
                    actual: descriptor.deviceID.driverID
                )
            }
            guard !observedDeviceIDs.contains(descriptor.deviceID) else {
                throw .duplicateDeviceID(descriptor.deviceID)
            }
            observedDeviceIDs.append(descriptor.deviceID)
            let mediaTypeMatches = request.mediaType.map {
                descriptor.mediaTypes.contains($0)
            } ?? true
            guard request.deviceTypeSelection.includes(
                      descriptor.deviceTypeID
                  ),
                  mediaTypeMatches,
                  request.position == .unspecified
                    || request.position == descriptor.position else {
                throw .descriptorDoesNotMatchRequest(descriptor.deviceID)
            }
        }
    }

    public static func validate(
        _ event: CaptureDeviceEvent,
        driverID: CaptureDriverID,
        request: CaptureDiscoveryRequest
    ) throws(CaptureProviderConformanceError) {
        switch event {
        case let .snapshot(descriptors):
            try validate(
                descriptors,
                driverID: driverID,
                request: request
            )
        case let .connected(descriptor), let .updated(descriptor):
            try validate(
                [descriptor],
                driverID: driverID,
                request: request
            )
        case let .disconnected(deviceID):
            guard deviceID.driverID == driverID else {
                throw .unexpectedDriver(
                    expected: driverID,
                    actual: deviceID.driverID
                )
            }
        }
    }

    public static func validate(
        _ event: CaptureStreamEvent,
        capabilities: CaptureStreamEventCapabilities
    ) throws(CaptureProviderConformanceError) {
        let requiredCapability: CaptureStreamEventCapabilities
        switch event {
        case .interrupted, .resumed:
            requiredCapability = .interruptions
        case .pressure:
            requiredCapability = .systemPressure
        case .dropped:
            requiredCapability = .sourceDrops
        case .failed:
            requiredCapability = .terminalFailures
        }
        guard capabilities.contains(requiredCapability) else {
            throw .undeclaredStreamEvent(event)
        }
    }

    public static func validateInitialSnapshot(
        in recorder: CaptureDeviceEventRecorder,
        driverID: CaptureDriverID
    ) throws(CaptureProviderConformanceError) {
        guard recorder.receivedInitialSnapshot else {
            throw .missingInitialDeviceSnapshot(driverID)
        }
    }

    private static func validateOpenedSnapshot(
        _ snapshot: CaptureDeviceSnapshot,
        expectedDeviceID: CaptureDeviceID
    ) throws(CaptureProviderConformanceError) {
        guard snapshot.descriptor.deviceID == expectedDeviceID else {
            throw .openedDeviceMismatch(
                expected: expectedDeviceID,
                actual: snapshot.descriptor.deviceID
            )
        }
        guard snapshot.capabilities.deviceID == expectedDeviceID,
              snapshot.descriptor.capabilityRevision
                == snapshot.capabilities.revision else {
            throw .resultingSnapshotMismatch(expectedDeviceID)
        }
    }

    private static func haveSameUniqueMembers<Element: Equatable>(
        _ lhs: [Element],
        _ rhs: [Element]
    ) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }
        for (index, element) in lhs.enumerated() {
            guard !lhs[..<index].contains(element),
                  rhs.contains(element) else {
                return false
            }
        }
        return true
    }
}
