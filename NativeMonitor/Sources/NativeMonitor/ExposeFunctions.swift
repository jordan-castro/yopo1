import Foundation

@_cdecl("NativeMonitor_StartTracking")
public func NativeMonitor_StartTracking() {
    print(NativeMonitor.StartTracking())
}

@_cdecl("NativeMonitor_StopTracking")
public func NativeMonitor_StopTracking() {
    NativeMonitor.StopTracking()
}
