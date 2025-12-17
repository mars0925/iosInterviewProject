//
//  GroupObject.swift
//  InterviewDemoProject
//
//  Created by 張宮豪 on 2025/12/17.
//

import Foundation
import UIKit

/// 使用 GCD DispatchGroup 實現併發圖片下載
/// 核心概念：
/// 1. DispatchGroup 用於追蹤多個非同步任務的完成狀態
/// 2. enter() - 告訴 group 有一個任務開始
/// 3. leave() - 告訴 group 有一個任務完成
/// 4. notify() - 當所有任務完成後執行回調
class GroupObject {
    
    // MARK: - Properties
    
    /// 併發隊列 - 用於同時執行多個下載任務
    private let concurrentQueue = DispatchQueue(label: "com.demo.imageDownload", attributes: .concurrent)
    
    /// DispatchGroup - 用於追蹤所有下載任務的完成狀態
    private let downloadGroup = DispatchGroup()
    
    /// 儲存下載完成的圖片
    private var downloadedImages: [String: UIImage] = [:]
    
    /// 執行緒安全的鎖，保護 downloadedImages 的讀寫
    private let lock = NSLock()
    
    // MARK: - Public Methods
    
    /// 開始併發下載三張圖片
    /// 當三個下載任務全部完成後，自動執行 finishDown()
    func startDownloadImages() {
        
        // 模擬的圖片 URL 列表
        let imageURLs = [
            "https://example.com/image1.jpg",
            "https://example.com/image2.jpg",
            "https://example.com/image3.jpg"
        ]
        
        print("📥 開始併發下載 \(imageURLs.count) 張圖片...")
        
        // 遍歷 URL 列表，為每個下載任務使用 group
        for (index, url) in imageURLs.enumerated() {
            
            // 進入 group - 表示有一個任務開始
            // 必須在任務開始前呼叫 enter()
            downloadGroup.enter()
            
            // 在併發隊列上非同步執行下載任務
            // 三個任務會同時開始執行
            concurrentQueue.async { [weak self] in
                guard let self = self else {
                    // 如果 self 已被釋放，也要呼叫 leave() 避免 group 永遠等待
                    self?.downloadGroup.leave()
                    return
                }
                
                self.downloadImage(from: url, index: index) { [weak self] image in
                    guard let self = self else { return }
                    
                    // 執行緒安全地儲存下載結果
                    self.lock.lock()
                    if let image = image {
                        self.downloadedImages["image_\(index)"] = image
                    }
                    self.lock.unlock()
                    
                    // 離開 group - 表示這個任務已完成
                    // 必須確保每個 enter() 都有對應的 leave()
                    self.downloadGroup.leave()
                }
            }
        }
        
        // 當所有任務完成後，在主執行緒執行 finishDown()
        // notify 不會阻塞當前執行緒
        downloadGroup.notify(queue: .main) { [weak self] in
            self?.finishDown()
        }
        
        print("🚀 所有下載任務已派發，等待完成...")
    }
    
    // MARK: - Private Methods
    
    /// 模擬圖片下載
    /// - Parameters:
    ///   - url: 圖片 URL
    ///   - index: 圖片索引
    ///   - completion: 完成回調，返回下載的圖片（可能為 nil）
    private func downloadImage(from url: String, index: Int, completion: @escaping (UIImage?) -> Void) {
        
        print("⏳ 開始下載圖片 \(index + 1): \(url)")
        print("   當前執行緒: \(Thread.current)")
        
        // 模擬網路延遲（1-3秒隨機）
        let delay = Double.random(in: 1.0...4.0)
        Thread.sleep(forTimeInterval: delay)
        
        // 模擬下載完成，創建一個假圖片
        let image = UIImage()
        
        print("✅ 圖片 \(index + 1) 下載完成，耗時: \(String(format: "%.2f", delay))秒")
        
        completion(image)
    }
    
    /// 所有圖片下載完成後執行的任務
    private func finishDown() {
        print("🎉 ====== 所有圖片下載完成！======")
        print("📊 成功下載 \(downloadedImages.count) 張圖片")
        print("🧵 finishDown 執行於: \(Thread.current.isMainThread ? "主執行緒" : "背景執行緒")")
        
        // 這裡可以進行後續處理，例如：
        // - 更新 UI
        // - 儲存圖片到本地
        // - 通知其他模組
    }
}

// MARK: - 進階用法示範

extension GroupObject {
    
    /// 使用 wait 阻塞等待（不推薦在主執行緒使用）
    /// 這個方法會阻塞當前執行緒直到所有任務完成
    func downloadWithWait() {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "com.demo.wait", attributes: .concurrent)
        
        for i in 1...3 {
            group.enter()
            queue.async {
                Thread.sleep(forTimeInterval: Double(i))
                print("任務 \(i) 完成")
                group.leave()
            }
        }
        
        // 阻塞當前執行緒，等待所有任務完成
        // 可設定超時時間
        let result = group.wait(timeout: .now() + 10)
        
        switch result {
        case .success:
            print("所有任務在超時前完成")
        case .timedOut:
            print("等待超時，部分任務可能未完成")
        }
    }
    
    /// 使用 async/await 風格的實現（iOS 15+）
    @available(iOS 15.0, *)
    func downloadWithAsyncAwait() async {
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for i in 0..<3 {
                group.addTask {
                    // 模擬下載
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 1_000_000_000...3_000_000_000))
                    return (i, UIImage())
                }
            }
            
            for await (index, image) in group {
                print("圖片 \(index) 下載完成")
            }
        }
        
        finishDown()
    }
}
