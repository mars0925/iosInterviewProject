//
//  UserCenter.swift
//  InterviewDemoProject
//
//  Created by 張宮豪 on 2025/12/17.
//

import Foundation

// MARK: - UserCenter
/// A thread-safe user data center implementing the Multiple Readers, Single Writer (MRSW) pattern using GCD.
///
/// This class demonstrates how to use a concurrent queue with barrier flags to achieve:
/// - Multiple simultaneous read operations (for better performance)
/// - Exclusive write operations (for data consistency)
///
/// The key concept:
/// - Read operations use `sync` on concurrent queue, allowing multiple reads to happen simultaneously
/// - Write operations use `async(flags: .barrier)`, which waits for all pending reads to complete,
///   then executes exclusively, blocking any new reads until the write is done
class UserCenter {
    
    // MARK: - Singleton
    /// Shared instance for global access to user data center
    static let shared = UserCenter()
    
    // MARK: - Properties
    
    /// Concurrent dispatch queue for managing read/write access
    /// Using a concurrent queue allows multiple reads to happen simultaneously
    /// while barrier writes ensure exclusive access during modifications
    private let concurrentQueue = DispatchQueue(
        label: "com.interview.userCenter.concurrentQueue",
        attributes: .concurrent
    )
    
    /// Internal storage using Dictionary (Map structure)
    /// Key: User ID (String)
    /// Value: User data dictionary containing user information
    private var userDataMap: [String: [String: Any]] = [:]
    
    // MARK: - Initialization
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    // MARK: - Read Operations (Multiple Readers Allowed)
    
    /// Retrieves user data for a specific user ID
    /// - Parameter userId: The unique identifier of the user
    /// - Returns: User data dictionary if found, nil otherwise
    ///
    /// This method uses `sync` on the concurrent queue, which means:
    /// - Multiple read operations can execute simultaneously
    /// - The calling thread will wait until the read completes
    /// - Safe to call from any thread
    func getUserData(userId: String) -> [String: Any]? {
        // Use sync to read data - allows concurrent reads
        // sync ensures we wait for the result before returning
        return concurrentQueue.sync {
            return userDataMap[userId]
        }
    }
    
    /// Retrieves all user data from the data center
    /// - Returns: A copy of the entire user data map
    ///
    /// Returns a copy to prevent external modifications to internal state
    func getAllUserData() -> [String: [String: Any]] {
        return concurrentQueue.sync {
            // Return a copy of the dictionary to maintain thread safety
            return userDataMap
        }
    }
    
    /// Checks if a user exists in the data center
    /// - Parameter userId: The unique identifier of the user
    /// - Returns: True if user exists, false otherwise
    func userExists(userId: String) -> Bool {
        return concurrentQueue.sync {
            return userDataMap[userId] != nil
        }
    }
    
    /// Gets the total count of users in the data center
    /// - Returns: Number of users stored
    var userCount: Int {
        return concurrentQueue.sync {
            return userDataMap.count
        }
    }
    
    // MARK: - Write Operations (Single Writer with Barrier)
    
    /// Sets or updates user data for a specific user ID
    /// - Parameters:
    ///   - userId: The unique identifier of the user
    ///   - data: The user data dictionary to store
    ///
    /// This method uses `async(flags: .barrier)` which means:
    /// - The write operation waits for all pending reads to complete
    /// - During the write, no other reads or writes can execute
    /// - The operation is asynchronous, so the calling thread doesn't block
    func setUserData(userId: String, data: [String: Any]) {
        // Use barrier flag for exclusive write access
        // async means we don't block the calling thread
        // barrier ensures this task waits for pending tasks and blocks new tasks until complete
        concurrentQueue.async(flags: .barrier) { [weak self] in
            self?.userDataMap[userId] = data
        }
    }
    
    /// Updates specific fields in existing user data
    /// - Parameters:
    ///   - userId: The unique identifier of the user
    ///   - updates: Dictionary containing fields to update
    ///
    /// Only updates the specified fields, preserving other existing data
    func updateUserData(userId: String, updates: [String: Any]) {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            guard var existingData = self?.userDataMap[userId] else {
                // If user doesn't exist, create new entry with updates
                self?.userDataMap[userId] = updates
                return
            }
            
            // Merge updates into existing data
            for (key, value) in updates {
                existingData[key] = value
            }
            self?.userDataMap[userId] = existingData
        }
    }
    
    /// Removes user data for a specific user ID
    /// - Parameter userId: The unique identifier of the user to remove
    func removeUserData(userId: String) {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            self?.userDataMap.removeValue(forKey: userId)
        }
    }
    
    /// Clears all user data from the data center
    func clearAllUserData() {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            self?.userDataMap.removeAll()
        }
    }
    
    // MARK: - Synchronous Write Operations
    
    /// Synchronously sets user data and waits for completion
    /// - Parameters:
    ///   - userId: The unique identifier of the user
    ///   - data: The user data dictionary to store
    ///
    /// Use this when you need to ensure the write completes before continuing
    /// Note: Be careful of deadlocks if called from the same queue
    func setUserDataSync(userId: String, data: [String: Any]) {
        concurrentQueue.sync(flags: .barrier) {
            userDataMap[userId] = data
        }
    }
    
    /// Synchronously removes user data and waits for completion
    /// - Parameter userId: The unique identifier of the user to remove
    /// - Returns: The removed user data if it existed, nil otherwise
    @discardableResult
    func removeUserDataSync(userId: String) -> [String: Any]? {
        return concurrentQueue.sync(flags: .barrier) {
            return userDataMap.removeValue(forKey: userId)
        }
    }
}

// MARK: - Usage Example Extension
extension UserCenter {
    
    /// Demonstrates the multiple readers, single writer pattern
    /// This method shows how concurrent reads and barrier writes work together
    func demonstrateMRSW() {
        print("=== 多讀單寫示範開始 ===\n")
        
        // Create a group to track all operations
        let group = DispatchGroup()
        
        // First, add some initial data
        print("📝 寫入初始數據...")
        setUserDataSync(userId: "user1", data: ["name": "Alice", "age": 25])
        setUserDataSync(userId: "user2", data: ["name": "Bob", "age": 30])
        setUserDataSync(userId: "user3", data: ["name": "Charlie", "age": 35])
        print("✅ 初始數據寫入完成\n")
        
        // Simulate multiple concurrent reads
        print("📖 開始併發讀取測試...")
        for i in 1...5 {
            group.enter()
            DispatchQueue.global().async { [weak self] in
                let userId = "user\((i % 3) + 1)"
                if let data = self?.getUserData(userId: userId) {
                    print("讀取 #\(i): 獲取 \(userId) 的數據 - \(data)")
                }
                group.leave()
            }
        }
        
        // Simulate a write operation in the middle
        print("📝 在併發讀取中插入寫入操作...")
        group.enter()
        setUserData(userId: "user4", data: ["name": "David", "age": 40])
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            group.leave()
        }
        
        // More concurrent reads after write
        for i in 6...8 {
            group.enter()
            DispatchQueue.global().async { [weak self] in
                let count = self?.userCount ?? 0
                print("讀取 #\(i): 當前用戶總數 = \(count)")
                group.leave()
            }
        }
        
        // Wait for all operations to complete
        group.notify(queue: .main) {
            print("\n=== 多讀單寫示範結束 ===")
        }
    }
}
