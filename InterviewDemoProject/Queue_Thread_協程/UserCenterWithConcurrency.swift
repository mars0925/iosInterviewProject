//
//  UserCenterWithConcurrency.swift
//  InterviewDemoProject
//
//  Created by 張宮豪 on 2025/12/17.
//

import Foundation

// MARK: - UserCenterWithConcurrency
/// A thread-safe user data center implemented using Swift Concurrency (Actor).
///
/// Actor provides automatic data isolation and thread safety:
/// - All access to actor's internal state is serialized
/// - No data races can occur because Swift compiler enforces actor isolation
/// - Simpler and safer than manual GCD synchronization
///
/// Key differences from GCD approach:
/// - Actor uses cooperative scheduling instead of preemptive scheduling
/// - No need for explicit locks, barriers, or queues
/// - Compiler enforces thread safety at compile time
/// - Uses async/await syntax for cleaner code
actor UserCenterWithConcurrency {
    
    // MARK: - Properties
    
    /// Internal storage using Dictionary (Map structure)
    /// Key: User ID (String)
    /// Value: User data dictionary containing user information
    ///
    /// Actor isolation ensures this dictionary is only accessed safely
    private var userDataMap: [String: [String: Any]] = [:]
    
    // MARK: - Initialization
    
    /// Public initializer - Actor doesn't need singleton pattern
    /// because actor isolation already provides thread safety
    init() {}
    
    // MARK: - Read Operations
    
    /// Retrieves user data for a specific user ID
    /// - Parameter userId: The unique identifier of the user
    /// - Returns: User data dictionary if found, nil otherwise
    ///
    /// This is an actor-isolated method, meaning:
    /// - Callers must use `await` to access it
    /// - Swift runtime ensures no data races
    func getUserData(userId: String) -> [String: Any]? {
        return userDataMap[userId]
    }
    
    /// Retrieves all user data from the data center
    /// - Returns: A copy of the entire user data map
    func getAllUserData() -> [String: [String: Any]] {
        return userDataMap
    }
    
    /// Checks if a user exists in the data center
    /// - Parameter userId: The unique identifier of the user
    /// - Returns: True if user exists, false otherwise
    func userExists(userId: String) -> Bool {
        return userDataMap[userId] != nil
    }
    
    /// Gets the total count of users in the data center
    /// - Returns: Number of users stored
    var userCount: Int {
        return userDataMap.count
    }
    
    // MARK: - Write Operations
    
    /// Sets or updates user data for a specific user ID
    /// - Parameters:
    ///   - userId: The unique identifier of the user
    ///   - data: The user data dictionary to store
    ///
    /// Actor isolation ensures this write operation is atomic
    /// and won't conflict with any concurrent reads or writes
    func setUserData(userId: String, data: [String: Any]) {
        userDataMap[userId] = data
    }
    
    /// Updates specific fields in existing user data
    /// - Parameters:
    ///   - userId: The unique identifier of the user
    ///   - updates: Dictionary containing fields to update
    ///
    /// Only updates the specified fields, preserving other existing data
    func updateUserData(userId: String, updates: [String: Any]) {
        if var existingData = userDataMap[userId] {
            // Merge updates into existing data
            for (key, value) in updates {
                existingData[key] = value
            }
            userDataMap[userId] = existingData
        } else {
            // If user doesn't exist, create new entry with updates
            userDataMap[userId] = updates
        }
    }
    
    /// Removes user data for a specific user ID
    /// - Parameter userId: The unique identifier of the user to remove
    func removeUserData(userId: String) {
        userDataMap.removeValue(forKey: userId)
    }
    
    /// Clears all user data from the data center
    func clearAllUserData() {
        userDataMap.removeAll()
    }
    
    /// Removes and returns user data for a specific user ID
    /// - Parameter userId: The unique identifier of the user to remove
    /// - Returns: The removed user data if it existed, nil otherwise
    @discardableResult
    func removeAndReturnUserData(userId: String) -> [String: Any]? {
        return userDataMap.removeValue(forKey: userId)
    }
}

// MARK: - Shared Instance Extension
extension UserCenterWithConcurrency {
    
    /// Global shared instance for convenient access
    /// Note: Unlike GCD version, we use a global actor instance
    /// which is lazily initialized and thread-safe
    static let shared = UserCenterWithConcurrency()
}

// MARK: - nonisolated Methods
extension UserCenterWithConcurrency {
    
    /// A nonisolated method that can be called synchronously
    /// This is useful for getting static information that doesn't depend on actor state
    nonisolated var description: String {
        return "UserCenterWithConcurrency - A thread-safe user data center using Swift Actor"
    }
}

// MARK: - Usage Example Extension
extension UserCenterWithConcurrency {
    
    /// Demonstrates how to use Swift Concurrency for multiple reads and writes
    /// This method shows the modern async/await approach
    func demonstrateConcurrency() async {
        print("=== Swift Concurrency 多讀單寫示範開始 ===\n")
        
        // Write initial data
        print("📝 寫入初始數據...")
        setUserData(userId: "user1", data: ["name": "Alice", "age": 25])
        setUserData(userId: "user2", data: ["name": "Bob", "age": 30])
        setUserData(userId: "user3", data: ["name": "Charlie", "age": 35])
        print("✅ 初始數據寫入完成\n")
        
        // Demonstrate concurrent reads using TaskGroup
        print("📖 開始併發讀取測試 (使用 TaskGroup)...")
        await withTaskGroup(of: String.self) { group in
            // Add multiple concurrent read tasks
            for i in 1...5 {
                group.addTask { [self] in
                    let userId = "user\((i % 3) + 1)"
                    if let data = await self.getUserData(userId: userId) {
                        return "讀取 #\(i): 獲取 \(userId) 的數據 - \(data)"
                    }
                    return "讀取 #\(i): 用戶不存在"
                }
            }
            
            // Collect and print results
            for await result in group {
                print(result)
            }
        }
        
        // Demonstrate write operation
        print("\n📝 寫入新數據...")
        setUserData(userId: "user4", data: ["name": "David", "age": 40])
        
        // More reads after write
        print("\n📖 寫入後的讀取...")
        let count = userCount
        print("當前用戶總數: \(count)")
        
        if let user4 = getUserData(userId: "user4") {
            print("新用戶 user4: \(user4)")
        }
        
        print("\n=== Swift Concurrency 多讀單寫示範結束 ===")
    }
}

// MARK: - Comparison Helper
/// A helper class to demonstrate calling the actor from non-async context
class UserCenterConcurrencyHelper {
    
    private let userCenter = UserCenterWithConcurrency.shared
    
    /// Demonstrates how to call actor methods from synchronous context
    /// Uses Task to bridge between sync and async worlds
    func performOperations() {
        // Use Task to create an async context from sync code
        Task {
            // Now we can use await to call actor methods
            await userCenter.setUserData(userId: "test", data: ["key": "value"])
            
            if let data = await userCenter.getUserData(userId: "test") {
                print("Retrieved data: \(data)")
            }
            
            let count = await userCenter.userCount
            print("Total users: \(count)")
        }
    }
    
    /// Demonstrates detached task usage
    /// Detached tasks don't inherit the current actor context
    func performDetachedOperations() {
        Task.detached {
            // Access the shared instance from detached task
            let center = UserCenterWithConcurrency.shared
            
            await center.setUserData(userId: "detached", data: ["source": "detached task"])
            print("Data set from detached task")
        }
    }
}

// MARK: - GCD vs Concurrency Comparison
/*
 ┌─────────────────────────────────────────────────────────────────────────────┐
 │                    GCD vs Swift Concurrency 比較                            │
 ├─────────────────┬───────────────────────────┬───────────────────────────────┤
 │     特性        │          GCD              │      Swift Concurrency        │
 ├─────────────────┼───────────────────────────┼───────────────────────────────┤
 │ 線程安全        │ 手動使用 barrier          │ Actor 自動保證                │
 │ 語法            │ 閉包 (closure)            │ async/await                   │
 │ 編譯時檢查      │ ❌ 無                     │ ✅ 有                         │
 │ 調度方式        │ 搶佔式 (Preemptive)       │ 協作式 (Cooperative)          │
 │ 死鎖風險        │ ⚠️ 需要小心               │ ✅ 編譯器幫助避免             │
 │ 性能優化        │ 手動優化                  │ 運行時自動優化                │
 │ 取消支持        │ 手動實現                  │ Task.isCancelled 內建支持     │
 │ 結構化併發      │ ❌ 無                     │ ✅ TaskGroup                  │
 │ 代碼可讀性      │ 回調地獄風險              │ 線性、易讀                    │
 │ iOS 最低版本    │ iOS 4+                    │ iOS 13+ (完整功能 iOS 15+)    │
 └─────────────────┴───────────────────────────┴───────────────────────────────┘
 
 多讀單寫實現差異：
 
 GCD 方式：
 - 讀：concurrentQueue.sync { ... }
 - 寫：concurrentQueue.async(flags: .barrier) { ... }
 - 允許真正的併發讀取
 
 Actor 方式：
 - 所有操作都是串行化的（但這是由 Swift 運行時優化的）
 - 編譯器保證數據安全
 - 更簡潔的代碼
 
 選擇建議：
 - 新項目：優先使用 Swift Concurrency (Actor)
 - 舊項目維護：可以繼續使用 GCD
 - 需要精確控制併發：使用 GCD
 - 需要編譯時安全保證：使用 Actor
 */

