//
//  ViewController.swift
//  InterviewDemoProject
//
//  Created by MarsChang on 2025/12/5.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // ⚠️ 取消下面這行的註解來觸發死鎖演示
        //         demonstrateDeadlock()
        //        demonstrateSerialQueueDeadlock()
        
        // Demo: Nested sync on concurrent queue (global queue)
//        demonstrateConcurrentQueueNestedSync()
//        downloadAndPrintAll()
        
        // 使用 async let 版本（需要在 Task 中調用）
//        Task {
//            await downloadAndPrintAllWithAsyncLet()
//        }
        
        blockOperationDemo()
    }
    
    // MARK: - Demo 1: BlockOperation 基本用法
    
    /// 演示最簡單的 BlockOperation 使用方式
    /// BlockOperation 允許以閉包形式定義任務，無需繼承 Operation
    private func blockOperationDemo() {
        /// 操作佇列，用於管理和執行 Operation
        let operationQueue = OperationQueue()
        print("=== BlockOperation 基本用法 ===\n\n")
        
        // 創建一個 BlockOperation
        // BlockOperation 是 Operation 的子類，提供簡便的閉包式任務創建
        let operation = BlockOperation {
            print("📍 主任務正在執行...\n")
            Thread.sleep(forTimeInterval: 0.5)
            print("📍 主任務完成\n")
        }
        
        // BlockOperation 可以添加多個執行塊
        // 這些執行塊可能會並行執行
        operation.addExecutionBlock {
            print("📍 附加任務 1 執行中...\n")
            Thread.sleep(forTimeInterval: 0.3)
            print("📍 附加任務 1 完成\n")
        }
        
        operation.addExecutionBlock {
            print("📍 附加任務 2 執行中...\n")
            Thread.sleep(forTimeInterval: 0.4)
            print("📍 附加任務 2 完成\n")
        }
        
        // 設置完成回調
        // completionBlock 會在所有執行塊完成後調用
        operation.completionBlock = { [weak self] in
            print("\n✅ 所有任務已完成（completionBlock）\n")
        }
        
        print("➡️ 開始執行 BlockOperation...\n\n")
        
        // 將操作添加到佇列中執行
        operationQueue.addOperation(operation)
    }
    
    // MARK: - DispathchGroup 並行下載任務後 全都完成之後再執行任務
    
    func downloadAndPrintAll() {
        let queue = DispatchQueue(label: "myQueue",attributes: .concurrent)
        let group = DispatchGroup()
        
        for index in 1...3 {
            group.enter()
            
            queue.async {
                print("\(Date().description)")
                Thread.sleep(forTimeInterval: 3.0)
                print("Downloaded data for item \(index)")
                group.leave()
            }
        }
        
        group.notify(queue: queue) {
            print("all finished!!!")
        }
    }
    
    // MARK: - Async Let Concurrent Download Demo（Swift Concurrency 版本）
    
    /// 使用 Swift Concurrency 的 async let 實現並行下載
    ///
    /// async let 原理：
    /// 1. async let 會立即開始執行異步任務，不會阻塞當前執行緒
    /// 2. 多個 async let 宣告會「並行」執行，而非依序執行
    /// 3. 使用 await 時才會等待該任務的結果
    ///
    /// 執行流程：
    /// ```
    /// async let result1 = downloadData(for: 1)  ─┐
    /// async let result2 = downloadData(for: 2)  ─┼─→ 三個任務同時開始執行
    /// async let result3 = downloadData(for: 3)  ─┘
    ///
    /// await [result1, result2, result3]  ─→ 等待所有任務完成
    /// ```
    ///
    /// 相比 DispatchGroup 的優點：
    /// - 語法更簡潔、可讀性更高
    /// - 結構化並發（Structured Concurrency），自動管理任務生命週期
    /// - 更好的錯誤處理機制（可以使用 try/catch）
    /// - 編譯器會檢查並發安全性
    func downloadAndPrintAllWithAsyncLet() async {
        print("=== Async Let Concurrent Download Demo ===")
        print("開始時間：\(Date().description)")
        
        // 使用 async let 並行啟動三個下載任務
        // 這三個任務會同時開始執行，不會互相等待
        // 注意：async let 宣告後，任務立即開始執行
        async let result1 = downloadData(for: 1)
        async let result2 = downloadData(for: 2)
        async let result3 = downloadData(for: 3)
        
        // await 會等待所有任務完成
        // 由於三個任務是並行執行的，總時間約為 3 秒（而非 9 秒）
        let results = await [result1, result2, result3]
        
        print("所有結果：\(results)")
        print("all finished!!!")
        print("結束時間：\(Date().description)")
    }
    
    /// 模擬下載數據的異步函數
    ///
    /// - Parameter index: 項目索引
    /// - Returns: 下載完成的訊息
    ///
    /// 注意：使用 Task.sleep 替代 Thread.sleep
    /// - Task.sleep 是非阻塞的，不會佔用線程資源
    /// - Thread.sleep 會阻塞整個線程，浪費系統資源
    private func downloadData(for index: Int) async -> String {
        print("\(Date().description) - 開始下載項目 \(index)")
        
        // 使用 Task.sleep 實現異步等待（3 秒）
        // nanoseconds: 3_000_000_000 = 3 秒
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        
        let message = "Downloaded data for item \(index)"
        print(message)
        return message
    }

    // MARK: - Deadlock Demo

    /// 展示主隊列死鎖的經典案例
    ///
    /// 死鎖原理：
    /// 1. 此方法在主線程上被調用（viewDidLoad 在主線程執行）
    /// 2. 當調用 DispatchQueue.main.sync 時：
    ///    - sync 會將 block 提交到主隊列
    ///    - sync 會「阻塞」當前線程，等待 block 執行完成
    /// 3. 但主隊列是串行隊列（Serial Queue）：
    ///    - 串行隊列一次只能執行一個任務
    ///    - 新任務必須等待當前任務完成才能開始
    /// 4. 形成死鎖：
    ///    - 當前方法等待 sync block 完成
    ///    - sync block 等待當前方法完成才能開始執行
    ///    - 兩者互相等待，程式永遠卡住
    ///
    /// 簡單示意圖：
    /// ```
    /// 主線程 → 等待 sync block 完成
    /// sync block → 等待主線程空閒才能執行
    /// = 互相等待 = 死鎖 💀
    /// ```
    ///
    /// - Warning: 調用此方法會導致 App 凍結！僅供學習演示用途。
    func demonstrateDeadlock() {
        print("========== 主隊列死鎖演示開始 ==========")
        print("Step 1: 目前在主線程上執行")
        print("Step 2: 準備調用 DispatchQueue.main.sync...")
        print("⚠️ 警告：下一行會造成死鎖，App 將會凍結！")

        // 這行會造成死鎖 - App 會直接卡住
        // 原因：sync 會阻塞當前線程等待 block 完成
        //      但 block 被提交到主隊列，需要等當前任務結束才能執行
        DispatchQueue.main.sync {
            // 這行永遠不會被執行到
            print("Step 3: 這行永遠不會印出來")
        }

        // 這行也永遠不會被執行到
        print("Step 4: 這行也永遠不會印出來")
        print("========== 主隊列死鎖演示結束 ==========")
    }

    // MARK: - Serial Queue Deadlock Demo

    /// 展示串行隊列死鎖的經典案例
    ///
    /// 死鎖原理：
    /// 1. 建立一個自定義的串行隊列（Serial Queue）
    /// 2. 使用 async 在該串行隊列上執行任務 A
    /// 3. 在任務 A 內部，對「同一個」串行隊列使用 sync 提交任務 B
    /// 4. 形成死鎖：
    ///    - 任務 A 等待任務 B 完成（sync 會阻塞）
    ///    - 任務 B 等待任務 A 完成才能開始（串行隊列特性）
    ///    - 兩者互相等待，程式永遠卡住
    ///
    /// 簡單示意圖：
    /// ```
    /// Serial Queue: [任務 A 執行中] → [任務 B 等待中]
    ///                    │                  ↑
    ///                    │   sync 阻塞等待   │
    ///                    └──────────────────┘
    ///               = 互相等待 = 死鎖 💀
    /// ```
    ///
    /// - Warning: 調用此方法會導致該串行隊列凍結！僅供學習演示用途。
    func demonstrateSerialQueueDeadlock() {
        print("========== 串行隊列死鎖演示開始 ==========")

        // 建立一個自定義的串行隊列
        let serialQueue = DispatchQueue(label: "com.demo.serialQueue")

        print("Step 1: 建立串行隊列 serialQueue")
        print("Step 2: 使用 async 在 serialQueue 上執行任務 A")

        // 在串行隊列上執行任務 A
        serialQueue.async {
            print("Step 3: 任務 A 開始執行")
            print("Step 4: 任務 A 內部準備對同一個 serialQueue 調用 sync...")
            print("⚠️ 警告：下一行會造成死鎖！")

            // 這行會造成死鎖
            // 原因：sync 會阻塞當前任務（任務 A），等待任務 B 完成
            //      但串行隊列需要任務 A 完成後，才能執行任務 B
            serialQueue.sync {
                // 這行永遠不會被執行到
                print("Step 5: 任務 B - 這行永遠不會印出來")
            }

            // 這行也永遠不會被執行到
            print("Step 6: 任務 A 結束 - 這行永遠不會印出來")
        }

        print("Step 7: async 調用後立即返回（主線程繼續執行）")
        print("========== 串行隊列死鎖演示結束（但 serialQueue 已死鎖）==========")
    }

    // MARK: - Concurrent Queue Nested Sync Demo
    
    /// Demonstrates nested sync calls on a concurrent queue (global queue).
    ///
    /// Key Concept:
    /// - `DispatchQueue.global()` is a CONCURRENT queue, NOT a serial queue.
    /// - Concurrent queues allow multiple tasks to execute simultaneously on different threads.
    /// - Therefore, nested sync calls on a concurrent queue do NOT cause deadlock.
    ///
    /// Execution Flow:
    /// 1. Print "=1=" on main thread
    /// 2. Outer sync: blocks main thread, waits for block to complete
    /// 3. Print "=2=" on a thread from the global queue's thread pool
    /// 4. Inner sync: blocks current thread, but since it's a CONCURRENT queue,
    ///    the system can use another thread from the pool to execute the inner block
    /// 5. Print "=3=" on (possibly) another thread
    /// 6. Inner sync returns
    /// 7. Print "=4=" continues on the outer block's thread
    /// 8. Outer sync returns
    /// 9. Print "=5=" on main thread
    ///
    /// Why NO Deadlock?
    /// - Serial Queue: Only ONE task can execute at a time.
    ///   If task A (running) syncs to the same serial queue, task B must wait for A to finish,
    ///   but A is waiting for B → DEADLOCK!
    /// - Concurrent Queue: Multiple tasks can run simultaneously.
    ///   Even if task A syncs to the same concurrent queue, the system can spawn/use
    ///   another thread to execute task B immediately → NO DEADLOCK.
    ///
    /// Output: =1= → =2= → =3= → =4= → =5= (in order)
    func demonstrateConcurrentQueueNestedSync() {
        print("========== Concurrent Queue Nested Sync Demo ==========")
        print("Key: DispatchQueue.global() is a CONCURRENT queue!")
        print("")
        
        print("=1=")
        
        // Outer sync call to global (concurrent) queue
        // This blocks the main thread until the block completes
        DispatchQueue.global().sync {
            print("=2=")
            
            // Inner sync call to the SAME global (concurrent) queue
            // This blocks the current thread, but because it's a concurrent queue,
            // the system can execute this block on another thread from the pool
            // → NO DEADLOCK (unlike serial queue)
            DispatchQueue.global().sync {
                print("=3=")
            }
            
            // After inner sync returns, continue execution
            print("=4=")
        }
        
        // After outer sync returns, main thread continues
        print("=5=")
        
        print("")
        print("========== Demo Complete ==========")
        print("Notice: All prints executed in order without deadlock!")
        print("This is because global queue is CONCURRENT, not serial.")
    }

}
