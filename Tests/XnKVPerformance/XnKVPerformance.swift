import XCTest
import XnKV

final class PerformanceTests: XCTestCase {
    private var kvStore: XnKV!
    private let dbPath = FileManager.default.temporaryDirectory.appendingPathComponent("xnkv_perf_\(UUID().uuidString)")
    
    override func setUpWithError() throws {
        try FileManager.default.createDirectory(at: dbPath, withIntermediateDirectories: true)
        kvStore = try XnKV(path: dbPath.path)
    }
    
    override func tearDownWithError() throws {
        kvStore = nil
        try FileManager.default.removeItem(atPath: dbPath.path)
    }
    
    func testPutPerformance() throws {
        measure {
            let expectation = XCTestExpectation(description: "Put operations complete")
            Task { [kvStore] in
                for i in 0..<10_000 {
                    let key = "key_\(i)"
                    let value = "value_\(i)".data(using: .utf8)!
                    try await kvStore!.put(key, value)
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    func testGetPerformance() throws {
        let expectation = XCTestExpectation(description: "Preloading data")
        Task { [kvStore] in
            for i in 0..<10_000 {
                let key = "key_\(i)"
                let value = "value_\(i)".data(using: .utf8)!
                try await kvStore!.put(key, value)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        
        measure {
            let expectation = XCTestExpectation(description: "Get operations complete")
            Task { [kvStore] in
                for i in 0..<10_000 {
                    let key = "key_\(i)"
                    _ = try await kvStore!.get(key)
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    func testDeletePerformance() throws {
        let expectation = XCTestExpectation(description: "Preloading data")
        Task { [kvStore] in
            for i in 0..<10_000 {
                let key = "key_\(i)"
                let value = "value_\(i)".data(using: .utf8)!
                try await kvStore!.put(key, value)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        
        measure {
            let expectation = XCTestExpectation(description: "Delete operations complete")
            Task { [kvStore] in
                for i in 0..<10_000 {
                    let key = "key_\(i)"
                    try await kvStore!.delete(key)
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
    }
}
