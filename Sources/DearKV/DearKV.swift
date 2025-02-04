// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// DearKV.swift
// Part of the dear suite <https://github.com/ivanmoskalev/xn>.
// This code is released into the public domain under The Unlicense.
// For details, see <https://unlicense.org/>.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

import Foundation
import liblmdb

public final actor DearKV {
    private let env: LMDBEnvironment
    private let dbi: MDB_dbi

    public init(path: String, maxDBs: UInt32 = 1) throws {
        self.env = try LMDBEnvironment(path: path)
        var txn: OpaquePointer?
        guard mdb_txn_begin(env.env, nil, 0, &txn) == 0 else { throw DearKVError.txnCreationFailed }
        var dbi: MDB_dbi = 0
        guard mdb_dbi_open(txn, nil, 0, &dbi) == 0 else { throw DearKVError.dbiOpenFailed }
        mdb_txn_commit(txn)
        self.dbi = dbi
    }

    public func put(_ key: String, _ value: Data) async throws {
        var txn: OpaquePointer?
        mdb_txn_begin(self.env.env, nil, 0, &txn)
        var keyVal = MDB_val(mv_size: key.count, mv_data: UnsafeMutableRawPointer(mutating: (key as NSString).utf8String))
        var dataVal = MDB_val(mv_size: value.count, mv_data: UnsafeMutableRawPointer(mutating: (value as NSData).bytes))
        mdb_put(txn, self.dbi, &keyVal, &dataVal, 0)
        mdb_txn_commit(txn)
    }

    public func get(_ key: String) async throws -> Data? {
        var txn: OpaquePointer?
        mdb_txn_begin(self.env.env, nil, UInt32(MDB_RDONLY), &txn)
        var keyVal = MDB_val(mv_size: key.count, mv_data: UnsafeMutableRawPointer(mutating: (key as NSString).utf8String))
        var dataVal = MDB_val()
        let result = mdb_get(txn, self.dbi, &keyVal, &dataVal)
        mdb_txn_abort(txn)
        
        guard result == 0, let dataPointer = dataVal.mv_data else { return nil }
        return Data(bytes: dataPointer, count: dataVal.mv_size)
    }

    public func delete(_ key: String) async throws {
        var txn: OpaquePointer?
        mdb_txn_begin(self.env.env, nil, 0, &txn)
        var keyVal = MDB_val(mv_size: key.count, mv_data: UnsafeMutableRawPointer(mutating: (key as NSString).utf8String))
        mdb_del(txn, self.dbi, &keyVal, nil)
        mdb_txn_commit(txn)
    }
}

final class LMDBEnvironment {
    let env: OpaquePointer?
    
    init(path: String) throws {
        var env: OpaquePointer?
        guard mdb_env_create(&env) == 0 else { throw DearKVError.envCreationFailed }
        guard mdb_env_open(env, path, UInt32(MDB_NOLOCK), S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH | S_IRWXU) == 0 else { throw DearKVError.envOpenFailed }
        self.env = env
    }
    
    deinit {
        if let env = env {
            mdb_env_close(env)
        }
    }
}

public enum DearKVError: Error {
    case envCreationFailed
    case configFailed
    case envOpenFailed
    case txnCreationFailed
    case dbiOpenFailed
    case putFailed
    case getFailed
    case deleteFailed
    case unknownError(Int32)
    
    public var localizedDescription: String {
        switch self {
        case .envCreationFailed:
            return "Failed to create LMDB environment."
        case .configFailed:
            return "Failed to configure LMDB environment."
        case .envOpenFailed:
            return "Failed to open LMDB environment."
        case .txnCreationFailed:
            return "Failed to create transaction."
        case .dbiOpenFailed:
            return "Failed to open database."
        case .putFailed:
            return "Failed to store key-value pair."
        case .getFailed:
            return "Failed to retrieve value for the given key."
        case .deleteFailed:
            return "Failed to delete the key-value pair."
        case .unknownError(let code):
            return "Unknown LMDB error: \(code)."
        }
    }
}
