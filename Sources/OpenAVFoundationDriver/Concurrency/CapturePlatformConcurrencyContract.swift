#if hasFeature(Embedded)
public protocol CapturePlatformConcurrencyContract {}
#else
public protocol CapturePlatformConcurrencyContract: Sendable {}
#endif
