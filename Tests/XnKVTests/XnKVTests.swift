import Testing
import Foundation
@testable import DearKV

@Test
func testPutAndGet() async throws {
    let kvStore = try create()
    
    let key = "testKey"
    let value = "testValue".data(using: .utf8)!
    try await kvStore.put(key, value)
    
    let retrievedValue = try await kvStore.get(key)
    #expect(retrievedValue == value)
}

@Test
func testGetNonexistentKey() async throws {
    let kvStore = try create()
    
    let retrievedValue = try await kvStore.get("nonexistentKey")
    #expect(retrievedValue == nil)
}

@Test
func testDeleteKey() async throws {
    let kvStore = try create()
    
    let key = "toBeDeleted"
    let value = "deleteMe".data(using: .utf8)!
    try await kvStore.put(key, value)
    
    try await kvStore.delete(key)
    let retrievedValue = try await kvStore.get(key)
    #expect(retrievedValue == nil)
}

@Test
func testConcurrentWrites() async throws {
    let kvStore = try create()
    
    try await withThrowingTaskGroup(of: Void.self) { tasks in
        for i in 0..<10 {
            tasks.addTask {
                let key = "key_\(i)"
                let value = "value_\(i)".data(using: .utf8)!
                try await kvStore.put(key, value)
            }
        }
    }
    
    for i in 0..<10 {
        let key = "key_\(i)"
        let expectedValue = "value_\(i)".data(using: .utf8)!
        let retrievedValue = try await kvStore.get(key)
        #expect(retrievedValue == expectedValue)
    }
}

func create() throws -> DearKV {
    let dbPath = FileManager.default.temporaryDirectory.appendingPathComponent("dearkv_\(UUID().uuidString)").path
    try FileManager.default.createDirectory(atPath: dbPath, withIntermediateDirectories: true)
    return try DearKV(path: dbPath)
}
