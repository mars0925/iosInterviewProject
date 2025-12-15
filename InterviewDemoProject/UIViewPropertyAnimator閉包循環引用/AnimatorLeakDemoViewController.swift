//
//  AnimatorLeakDemoViewController.swift
//  InterviewDemoProject
//
//  Demonstrates memory leak issues with UIViewPropertyAnimator closures
//  演示 UIViewPropertyAnimator 閉包循環引用問題
//

import UIKit

class AnimatorLeakDemoViewController: UIViewController {
    
    // MARK: - Properties
    
    // Storage for animator - this is what causes the retain cycle
    // 儲存 animator 的屬性 - 這是造成循環引用的關鍵
    private var closureStorage: UIViewPropertyAnimator?
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    
    // Demo view for animations
    // 用於動畫演示的視圖
    private let demoView = UIView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStatus("Ready to test")
    }
    
    // This deinit will help us verify if memory leak happens
    // 這個 deinit 方法會幫助我們驗證是否發生記憶體洩漏
    deinit {
        print("✅ AnimatorLeakDemoViewController is being deallocated - NO LEAK!")
        print("✅ AnimatorLeakDemoViewController 正在被釋放 - 沒有洩漏！")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Animator Leak Demo"
        
        // Setup scroll view
        // 設置滾動視圖
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Setup content view
        // 設置內容視圖
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Setup stack view
        // 設置堆疊視圖
        contentView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // Title label
        // 標題標籤
        titleLabel.text = "UIViewPropertyAnimator 閉包循環引用測試"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        stackView.addArrangedSubview(titleLabel)
        
        // Status label
        // 狀態標籤
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.numberOfLines = 0
        statusLabel.textColor = .systemGray
        statusLabel.textAlignment = .center
        stackView.addArrangedSubview(statusLabel)
        
        // Demo view for animation
        // 演示動畫的視圖
        demoView.backgroundColor = .systemBlue
        demoView.layer.cornerRadius = 8
        demoView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(demoView)
        NSLayoutConstraint.activate([
            demoView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Section 1: Memory Leak Examples
        // 第一部分：記憶體洩漏範例
        let leakSection = createSectionLabel(title: "❌ 記憶體洩漏範例")
        stackView.addArrangedSubview(leakSection)
        
        stackView.addArrangedSubview(createButton(
            title: "測試 1: 直接捕獲 self (testLeakOne)",
            action: #selector(testLeakOne),
            color: .systemRed
        ))
        
        stackView.addArrangedSubview(createButton(
            title: "測試 2: 使用局部變數 (testLeakTwo)",
            action: #selector(testLeakTwo),
            color: .systemOrange
        ))
        
        // Section 2: Correct Solutions
        // 第二部分：正確的解決方案
        let correctSection = createSectionLabel(title: "✅ 正確的解決方案")
        stackView.addArrangedSubview(correctSection)
        
        stackView.addArrangedSubview(createButton(
            title: "方案 1: 使用 [weak self]",
            action: #selector(testNoLeakWeak),
            color: .systemGreen
        ))
        
        stackView.addArrangedSubview(createButton(
            title: "方案 2: 使用 [unowned self]",
            action: #selector(testNoLeakUnowned),
            color: .systemGreen
        ))
        
        stackView.addArrangedSubview(createButton(
            title: "方案 3: 動畫後清理引用",
            action: #selector(testNoLeakWithCleanup),
            color: .systemGreen
        ))
        
        // Section 3: Testing
        // 第三部分：測試
        let testSection = createSectionLabel(title: "🔍 測試記憶體洩漏")
        stackView.addArrangedSubview(testSection)
        
        stackView.addArrangedSubview(createButton(
            title: "清除 Animator 引用",
            action: #selector(clearAnimator),
            color: .systemPurple
        ))
        
        stackView.addArrangedSubview(createButton(
            title: "返回並檢查 deinit",
            action: #selector(goBack),
            color: .systemBlue
        ))
        
        // Info label
        // 資訊標籤
        let infoLabel = UILabel()
        infoLabel.text = """
        💡 測試方法：
        1. 點擊任一測試按鈕執行動畫
        2. 點擊「返回並檢查 deinit」
        3. 在 Console 中觀察：
           - 如果看到 deinit 訊息 → 沒有洩漏 ✅
           - 如果沒有 deinit 訊息 → 有記憶體洩漏 ❌
        
        提示：洩漏範例需要先「清除 Animator 引用」
        或等待動畫完成才會釋放。
        """
        infoLabel.font = .systemFont(ofSize: 13)
        infoLabel.numberOfLines = 0
        infoLabel.textColor = .systemGray2
        infoLabel.backgroundColor = .systemGray6
        infoLabel.layer.cornerRadius = 8
        infoLabel.clipsToBounds = true
        infoLabel.textAlignment = .left
        
        // Add padding to info label
        // 為資訊標籤添加內邊距
        let infoContainer = UIView()
        infoContainer.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: infoContainer.topAnchor, constant: 12),
            infoLabel.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 12),
            infoLabel.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: -12),
            infoLabel.bottomAnchor.constraint(equalTo: infoContainer.bottomAnchor, constant: -12)
        ])
        stackView.addArrangedSubview(infoContainer)
    }
    
    // Helper method to create section labels
    // 輔助方法：創建分區標籤
    private func createSectionLabel(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        return label
    }
    
    // Helper method to create buttons
    // 輔助方法：創建按鈕
    private func createButton(title: String, action: Selector, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    // Helper method to update status label
    // 輔助方法：更新狀態標籤
    private func updateStatus(_ message: String) {
        statusLabel.text = "狀態: \(message)"
        print("📱 \(message)")
    }
    
    // MARK: - Memory Leak Examples
    // 記憶體洩漏範例
    
    /// ❌ Test Leak One - Direct self capture in closures
    /// ❌ 測試洩漏一 - 在閉包中直接捕獲 self
    ///
    /// Problem: Both closures capture self strongly
    /// 問題：兩個閉包都強引用 self
    /// Retain cycle: self → closureStorage → anim → closures → self
    /// 循環引用：self → closureStorage → anim → closures → self
    @objc private func testLeakOne() {
        updateStatus("執行 testLeakOne - 會造成循環引用 ❌")
        
        // Create animator with closures that capture self
        // 創建 animator，其閉包捕獲了 self
        let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) {
            // ⚠️ This closure captures self strongly
            // ⚠️ 這個閉包強引用了 self
            self.demoView.backgroundColor = .systemRed
        }
        
        anim.addCompletion { _ in
            // ⚠️ This closure also captures self strongly
            // ⚠️ 這個閉包也強引用了 self
            self.demoView.backgroundColor = .systemBlue
            self.updateStatus("testLeakOne 動畫完成 - 但仍有循環引用！")
        }
        
        // Store the animator - this creates the retain cycle
        // 儲存 animator - 這會創建循環引用
        self.closureStorage = anim
        
        anim.startAnimation()
        
        print("⚠️ Retain Cycle Created: self → closureStorage → anim → closures → self")
        print("⚠️ 循環引用已創建: self → closureStorage → anim → closures → self")
    }
    
    /// ❌ Test Leak Two - Using local variable (doesn't solve the problem)
    /// ❌ 測試洩漏二 - 使用局部變數（無法解決問題）
    ///
    /// Common misconception: Storing self.view in a local variable avoids retain cycle
    /// 常見誤解：將 self.view 儲存在局部變數中可以避免循環引用
    /// Reality: The retain cycle still exists through the stored animator
    /// 現實：通過儲存的 animator，循環引用仍然存在
    @objc private func testLeakTwo() {
        updateStatus("執行 testLeakTwo - 局部變數也無法避免洩漏 ❌")
        
        // Common misconception: this avoids capturing self
        // 常見誤解：這樣可以避免捕獲 self
        let view = self.demoView
        
        let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) {
            // ⚠️ Still problematic - the closure captures view, but the cycle exists
            // ⚠️ 仍有問題 - 閉包捕獲了 view，但循環引用依然存在
            view.backgroundColor = .systemOrange
        }
        
        anim.addCompletion { _ in
            view.backgroundColor = .systemBlue
            // We need self here to update status, which reveals the real problem
            // 這裡需要 self 來更新狀態，這揭示了真正的問題
            self.updateStatus("testLeakTwo 動畫完成 - 局部變數並未解決問題！")
        }
        
        // The retain cycle is created here
        // 循環引用在這裡創建
        self.closureStorage = anim
        
        anim.startAnimation()
        
        print("⚠️ Retain Cycle Still Exists: self → closureStorage → anim")
        print("⚠️ 循環引用仍然存在: self → closureStorage → anim")
        print("💡 Local variable doesn't break the cycle when animator is stored!")
        print("💡 當 animator 被儲存時，局部變數無法打破循環！")
    }
    
    // MARK: - Correct Solutions
    // 正確的解決方案
    
    /// ✅ Solution 1: Use [weak self]
    /// ✅ 方案一：使用 [weak self]
    ///
    /// Best practice: Use weak self to break the retain cycle
    /// 最佳實踐：使用 weak self 打破循環引用
    /// The closure no longer holds a strong reference to self
    /// 閉包不再強引用 self
    @objc private func testNoLeakWeak() {
        updateStatus("執行 testNoLeakWeak - 使用 [weak self] ✅")
        
        // Use [weak self] to break retain cycle
        // 使用 [weak self] 打破循環引用
        let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) { [weak self] in
            // ✅ self is now optional and weakly captured
            // ✅ self 現在是可選的且為弱引用
            self?.demoView.backgroundColor = .systemGreen
        }
        
        anim.addCompletion { [weak self] _ in
            // ✅ Weak reference here too
            // ✅ 這裡也是弱引用
            self?.demoView.backgroundColor = .systemBlue
            self?.updateStatus("testNoLeakWeak 動畫完成 - 沒有循環引用！✅")
        }
        
        // Safe to store - no retain cycle
        // 安全儲存 - 沒有循環引用
        self.closureStorage = anim
        
        anim.startAnimation()
        
        print("✅ No Retain Cycle: self →(weak) closureStorage → anim →(weak) self")
        print("✅ 沒有循環引用: self →(弱) closureStorage → anim →(弱) self")
    }
    
    /// ✅ Solution 2: Use [unowned self]
    /// ✅ 方案二：使用 [unowned self]
    ///
    /// Alternative: Use unowned self when you're certain self will outlive the closure
    /// 替代方案：當確定 self 的生命週期比閉包長時使用 unowned self
    /// Warning: unowned will crash if self is deallocated
    /// 警告：如果 self 被釋放，unowned 會崩潰
    @objc private func testNoLeakUnowned() {
        updateStatus("執行 testNoLeakUnowned - 使用 [unowned self] ✅")
        
        // Use [unowned self] - similar to weak but not optional
        // 使用 [unowned self] - 類似 weak 但不是可選的
        let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) { [unowned self] in
            // ✅ self is not optional with unowned
            // ✅ 使用 unowned 時 self 不是可選的
            self.demoView.backgroundColor = .systemTeal
        }
        
        anim.addCompletion { [unowned self] _ in
            self.demoView.backgroundColor = .systemBlue
            self.updateStatus("testNoLeakUnowned 動畫完成 - 沒有循環引用！✅")
        }
        
        self.closureStorage = anim
        
        anim.startAnimation()
        
        print("✅ No Retain Cycle with unowned self")
        print("✅ 使用 unowned self 沒有循環引用")
        print("⚠️  Note: unowned crashes if self is deallocated, use weak for safety")
        print("⚠️  注意：如果 self 被釋放，unowned 會崩潰，使用 weak 更安全")
    }
    
    /// ✅ Solution 3: Cleanup after animation
    /// ✅ 方案三：動畫後清理引用
    ///
    /// Alternative approach: Use weak self and clear the storage after completion
    /// 替代方法：使用 weak self 並在完成後清理儲存
    @objc private func testNoLeakWithCleanup() {
        updateStatus("執行 testNoLeakWithCleanup - 動畫後清理 ✅")
        
        let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) { [weak self] in
            self?.demoView.backgroundColor = .systemIndigo
        }
        
        anim.addCompletion { [weak self] _ in
            self?.demoView.backgroundColor = .systemBlue
            self?.updateStatus("testNoLeakWithCleanup 動畫完成並已清理！✅")
            
            // ✅ Clear the storage after animation completes
            // ✅ 動畫完成後清理儲存
            self?.closureStorage = nil
            print("✅ Animator cleared from storage after completion")
            print("✅ 完成後已從儲存中清除 animator")
        }
        
        self.closureStorage = anim
        anim.startAnimation()
        
        print("✅ Will cleanup after animation completes")
        print("✅ 動畫完成後將進行清理")
    }
    
    // MARK: - Testing Utilities
    // 測試工具
    
    /// Clear the stored animator reference
    /// 清除儲存的 animator 引用
    @objc private func clearAnimator() {
        closureStorage = nil
        updateStatus("已清除 Animator 引用")
        print("🗑️ Animator reference cleared")
        print("🗑️ Animator 引用已清除")
    }
    
    /// Go back to test memory leak
    /// 返回以測試記憶體洩漏
    @objc private func goBack() {
        print("⬅️ Navigating back...")
        print("⬅️ 正在返回...")
        print("👀 Watch for deinit message in console:")
        print("👀 觀察 console 中的 deinit 訊息：")
        print("   ✅ If deinit is called → No leak")
        print("   ✅ 如果 deinit 被調用 → 沒有洩漏")
        print("   ❌ If deinit is NOT called → Memory leak!")
        print("   ❌ 如果 deinit 沒有被調用 → 記憶體洩漏！")
        
        navigationController?.popViewController(animated: true)
    }
}

