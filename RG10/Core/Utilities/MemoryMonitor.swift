//
//  MemoryMonitor.swift
//  RG10
//
//  Memory monitoring utility to help diagnose memory leaks
//

import Foundation
import os.log

/// Utility class for monitoring memory usage and identifying leaks
final class MemoryMonitor {
    static let shared = MemoryMonitor()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "RG10", category: "Memory")
    private var instanceCounts: [String: Int] = [:]
    private let lock = NSLock()
    private var monitoringTimer: Timer?
    private var lastMemoryUsage: UInt64 = 0
    private var peakMemoryUsage: UInt64 = 0
    
    private init() {}
    
    // MARK: - Memory Usage
    
    /// Get current memory usage in MB
    var currentMemoryUsageMB: Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return 0 }
        return Double(info.resident_size) / (1024 * 1024)
    }
    
    /// Get current memory usage in bytes
    var currentMemoryUsageBytes: UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return 0 }
        return UInt64(info.resident_size)
    }
    
    // MARK: - Logging
    
    /// Log current memory usage with a label
    func logMemory(_ label: String, file: String = #file, function: String = #function) {
        let memory = currentMemoryUsageMB
        let fileName = (file as NSString).lastPathComponent
        
        // Track if memory increased significantly
        let currentBytes = currentMemoryUsageBytes
        let delta = Int64(currentBytes) - Int64(lastMemoryUsage)
        let deltaStr = delta >= 0 ? "+\(formatBytes(UInt64(delta)))" : "-\(formatBytes(UInt64(-delta)))"
        
        if currentBytes > peakMemoryUsage {
            peakMemoryUsage = currentBytes
        }
        
        print("📊 MEMORY [\(label)] \(String(format: "%.1f", memory)) MB (\(deltaStr)) | Peak: \(String(format: "%.1f", Double(peakMemoryUsage) / (1024 * 1024))) MB | \(fileName):\(function)")
        
        lastMemoryUsage = currentBytes
        
        // Warn if memory is getting high
        if memory > 200 {
            print("⚠️ WARNING: Memory usage exceeds 200 MB!")
        }
        if memory > 400 {
            print("🚨 CRITICAL: Memory usage exceeds 400 MB! App may crash soon!")
        }
    }
    
    /// Log when a view appears
    func viewAppeared(_ viewName: String) {
        incrementCount(for: "View:\(viewName)")
        logMemory("VIEW APPEAR: \(viewName)")
    }
    
    /// Log when a view disappears
    func viewDisappeared(_ viewName: String) {
        decrementCount(for: "View:\(viewName)")
        logMemory("VIEW DISAPPEAR: \(viewName)")
    }
    
    /// Log when an object is initialized
    func objectInitialized(_ typeName: String) {
        incrementCount(for: typeName)
        let count = getCount(for: typeName)
        print("📦 INIT [\(typeName)] - Active instances: \(count) | Memory: \(String(format: "%.1f", currentMemoryUsageMB)) MB")
    }
    
    /// Log when an object is deinitialized
    func objectDeinitialized(_ typeName: String) {
        decrementCount(for: typeName)
        let count = getCount(for: typeName)
        print("🗑️ DEINIT [\(typeName)] - Active instances: \(count) | Memory: \(String(format: "%.1f", currentMemoryUsageMB)) MB")
    }
    
    // MARK: - Instance Counting
    
    private func incrementCount(for key: String) {
        lock.lock()
        defer { lock.unlock() }
        instanceCounts[key, default: 0] += 1
    }
    
    private func decrementCount(for key: String) {
        lock.lock()
        defer { lock.unlock() }
        if let count = instanceCounts[key], count > 0 {
            instanceCounts[key] = count - 1
        }
    }
    
    private func getCount(for key: String) -> Int {
        lock.lock()
        defer { lock.unlock() }
        return instanceCounts[key] ?? 0
    }
    
    /// Print all active instance counts
    func printInstanceCounts() {
        lock.lock()
        let counts = instanceCounts.filter { $0.value > 0 }
        lock.unlock()
        
        print("\n📈 ACTIVE INSTANCE COUNTS:")
        print("==========================")
        for (key, count) in counts.sorted(by: { $0.key < $1.key }) {
            let warning = count > 10 ? " ⚠️" : ""
            print("  \(key): \(count)\(warning)")
        }
        print("==========================\n")
    }
    
    // MARK: - Periodic Monitoring
    
    /// Start periodic memory monitoring
    func startMonitoring(interval: TimeInterval = 10.0) {
        stopMonitoring()
        
        print("🔍 Starting memory monitoring (interval: \(interval)s)")
        lastMemoryUsage = currentMemoryUsageBytes
        peakMemoryUsage = lastMemoryUsage
        
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.periodicCheck()
        }
    }
    
    /// Stop periodic memory monitoring
    func stopMonitoring() {
        monitoringTimer?.invalidate()
        monitoringTimer = nil
    }
    
    private func periodicCheck() {
        let currentBytes = currentMemoryUsageBytes
        let delta = Int64(currentBytes) - Int64(lastMemoryUsage)
        let memory = Double(currentBytes) / (1024 * 1024)
        
        if currentBytes > peakMemoryUsage {
            peakMemoryUsage = currentBytes
        }
        
        // Only log if there's significant change (> 1MB)
        if abs(delta) > 1024 * 1024 {
            let deltaStr = delta >= 0 ? "+\(formatBytes(UInt64(delta)))" : "-\(formatBytes(UInt64(-delta)))"
            print("📊 PERIODIC CHECK: \(String(format: "%.1f", memory)) MB (\(deltaStr)) | Peak: \(String(format: "%.1f", Double(peakMemoryUsage) / (1024 * 1024))) MB")
            
            if delta > 5 * 1024 * 1024 { // More than 5MB increase
                print("⚠️ Significant memory increase detected!")
                printInstanceCounts()
            }
        }
        
        lastMemoryUsage = currentBytes
    }
    
    // MARK: - Helpers
    
    private func formatBytes(_ bytes: UInt64) -> String {
        if bytes < 1024 {
            return "\(bytes) B"
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024)
        } else {
            return String(format: "%.1f MB", Double(bytes) / (1024 * 1024))
        }
    }
}

// MARK: - View Extension for Easy Tracking

import SwiftUI

extension View {
    /// Add memory tracking to a view
    func trackMemory(_ viewName: String) -> some View {
        self
            .onAppear {
                MemoryMonitor.shared.viewAppeared(viewName)
            }
            .onDisappear {
                MemoryMonitor.shared.viewDisappeared(viewName)
            }
    }
}
