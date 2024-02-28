import Foundation
import Metal

public struct NativeMonitor {
    static public func TrackCPU() -> Double {
        var info = task_thread_times_info()

        var trueRes: kern_return_t = KERN_SUCCESS;

        var localInfo = info
        let result: () = withUnsafeMutablePointer(to: &localInfo) {
            $0.withMemoryRebound(to: Int32.self, capacity: 1) {_ in 
                var size: UInt32 = UInt32(MemoryLayout<task_thread_times_info>.stride)

                trueRes = withUnsafeMutablePointer(to: &info) {
                    $0.withMemoryRebound(to: Int32.self, capacity: 1) {
                        task_info(mach_task_self_, task_flavor_t(TASK_THREAD_TIMES_INFO), $0, &size)
                    }
                }
            }
        }

        if trueRes != KERN_SUCCESS {
            print("Error: \(result)")
            return 0.0
        }

        let totalTicks = info.user_time.seconds + info.system_time.seconds
        let totalCPUTime = Double(totalTicks) / Double(NSEC_PER_SEC)

        return totalCPUTime
    }

     @available(macOS 10.15, *)
    static public func TrackGPU() -> Double {
        let device = MTLCreateSystemDefaultDevice()
        guard let commandQueue = device?.makeCommandQueue() else {
            return 0.0
        }

        let commandBuffer = commandQueue.makeCommandBuffer()
        let computeEncoder = commandBuffer?.makeComputeCommandEncoder()

        // This is a basic Metal compute kernel that just adds numbers.
        let kernelFunction = device?.makeDefaultLibrary()?.makeFunction(name: "basic_kernel")
        let computePipelineState = try? device?.makeComputePipelineState(function: kernelFunction!)

        computeEncoder?.setComputePipelineState(computePipelineState!)
        let threadsPerGroup = MTLSize(width: 1, height: 1, depth: 1)
        let numThreadgroups = MTLSize(width: 1, height: 1, depth: 1)

        computeEncoder?.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        computeEncoder?.endEncoding()

        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()

        // This is a basic calculation of GPU usage.
        let start = commandBuffer?.gpuStartTime
        let end = commandBuffer?.gpuEndTime

        let utilization = (end! - start!) / 1000000000.0

        return utilization
    }

    static public func TrackRam() -> Double {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return Double(taskInfo.resident_size)
        } else {
            return 0
        }

    }

    static public func StartTracking() -> [Double] {
        print("StartTracking")
        if #available(macOS 10.15, *) {
            return [TrackCPU(), TrackGPU(), TrackRam()]
        } else {
            return [TrackCPU(), 0.0, TrackRam()]
        }
    }

    static public func StopTracking() {
        print("StopTracking")
    }
}
