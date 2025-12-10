//
//  ViewController.swift
//  InterviewDemoProject
//
//  Created by MarsChang on 2025/12/5.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI Components
    
    /// 日誌顯示區域
    private let logTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    /// 清除日誌按鈕
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("清除日誌", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// UI 繪製演示按鈕
    private let drawingDemoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🎨 UI 繪製演示", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// KVO 演示按鈕
    private let kvoDemoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("👀 KVO 演示", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// Delegate 和 Protocol 演示按鈕
    private let delegateProtocolDemoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🎯 Delegate vs Protocol", for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 說明標籤
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "💡 點擊下方彩色視圖查看事件傳遞過程"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 圓形響應按鈕容器
    private let buttonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 按鈕說明標籤
    private let buttonLabel: UILabel = {
        let label = UILabel()
        label.text = "🎯 方形按鈕指定區域響應（只有圓形內可點擊）"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 圓形響應按鈕
    private var circularButton: CircularHitButton!
    
    /// 測試提示標籤
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.text = "提示：嘗試點擊紅色方形的角落區域"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Custom Views (事件演示視圖)
    
    /// 父視圖 (藍色)
    private var parentView: CustomView!
    
    /// 子視圖 1 (綠色)
    private var childView1: CustomView!
    
    /// 孫視圖 (橙色)
    private var grandchildView: CustomView!
    
    /// 子視圖 2 (紫色)
    private var childView2: CustomView!
    
    // MARK: - Properties
    
    /// 日誌計數器
    private var logCounter = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設置背景色
        view.backgroundColor = .white
        
        // 設置 UI
        setupLogArea()
        setupCustomViews()
        setupConstraints()
        
        // 添加歡迎日誌
        log("========================================")
        log("📱 UIView 事件傳遞與響應鏈演示")
        log("========================================")
        log("")
        log("演示 1️⃣：方形按鈕指定區域響應")
        log("  - 點擊紅色方形按鈕測試圓形響應區域")
        log("  - 試試點擊四個角落（應該不會響應）")
        log("")
        log("演示 2️⃣：多層視圖的事件傳遞")
        log("  - 點擊下方彩色視圖查看完整的事件流程")
        log("")
    }
    
    // MARK: - Setup Methods
    
    /// 設置日誌顯示區域
    private func setupLogArea() {
        view.addSubview(logTextView)
        view.addSubview(clearButton)
        view.addSubview(drawingDemoButton)
        view.addSubview(kvoDemoButton)
        view.addSubview(delegateProtocolDemoButton)
        view.addSubview(instructionLabel)
        view.addSubview(buttonContainerView)
        
        // 添加按鈕容器的子視圖
        buttonContainerView.addSubview(buttonLabel)
        
        // 創建圓形響應按鈕
        circularButton = CircularHitButton(frame: .zero)
        circularButton.buttonName = "圓形響應按鈕"
        circularButton.logDelegate = self
        circularButton.translatesAutoresizingMaskIntoConstraints = false
        circularButton.addTarget(self, action: #selector(circularButtonTapped), for: .touchUpInside)
        buttonContainerView.addSubview(circularButton)
        
        buttonContainerView.addSubview(hintLabel)
        
        // 清除按鈕事件
        clearButton.addTarget(self, action: #selector(clearLog), for: .touchUpInside)
        
        // UI 繪製演示按鈕事件
        drawingDemoButton.addTarget(self, action: #selector(showDrawingDemo), for: .touchUpInside)
        
        // KVO 演示按鈕事件
        kvoDemoButton.addTarget(self, action: #selector(showKVODemo), for: .touchUpInside)
        
        // Delegate 和 Protocol 演示按鈕事件
        delegateProtocolDemoButton.addTarget(self, action: #selector(showDelegateProtocolDemo), for: .touchUpInside)
    }
    
    /// 設置自定義視圖層級結構
    private func setupCustomViews() {
        // 父視圖 (藍色) - 300x300
        parentView = CustomView(frame: .zero)
        parentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
        parentView.viewName = "Parent View (藍色)"
        parentView.depth = 0
        parentView.logDelegate = self
        parentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(parentView)
        
        // 子視圖 1 (綠色) - 200x200，位於父視圖左上角
        childView1 = CustomView(frame: .zero)
        childView1.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.5)
        childView1.viewName = "Child View 1 (綠色)"
        childView1.depth = 1
        childView1.logDelegate = self
        childView1.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(childView1)
        
        // 孫視圖 (橙色) - 100x100，位於子視圖1的中心
        grandchildView = CustomView(frame: .zero)
        grandchildView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.7)
        grandchildView.viewName = "Grandchild View (橙色)"
        grandchildView.depth = 2
        grandchildView.logDelegate = self
        grandchildView.translatesAutoresizingMaskIntoConstraints = false
        childView1.addSubview(grandchildView)
        
        // 子視圖 2 (紫色) - 120x120，位於父視圖右下角
        childView2 = CustomView(frame: .zero)
        childView2.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.5)
        childView2.viewName = "Child View 2 (紫色)"
        childView2.depth = 1
        childView2.logDelegate = self
        childView2.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(childView2)
    }
    
    /// 設置約束
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 日誌文本視圖 - 頂部區域
            logTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            logTextView.heightAnchor.constraint(equalToConstant: 200),
            
            // 清除按鈕
            clearButton.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 10),
            clearButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            clearButton.heightAnchor.constraint(equalToConstant: 40),
            clearButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -5),
            
            // UI 繪製演示按鈕
            drawingDemoButton.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 10),
            drawingDemoButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 5),
            drawingDemoButton.heightAnchor.constraint(equalToConstant: 40),
            drawingDemoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            // KVO 演示按鈕
            kvoDemoButton.topAnchor.constraint(equalTo: drawingDemoButton.bottomAnchor, constant: 8),
            kvoDemoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            kvoDemoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            kvoDemoButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Delegate 和 Protocol 演示按鈕
            delegateProtocolDemoButton.topAnchor.constraint(equalTo: kvoDemoButton.bottomAnchor, constant: 8),
            delegateProtocolDemoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            delegateProtocolDemoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            delegateProtocolDemoButton.heightAnchor.constraint(equalToConstant: 40),
            
            // 圓形響應按鈕容器
            buttonContainerView.topAnchor.constraint(equalTo: delegateProtocolDemoButton.bottomAnchor, constant: 10),
            buttonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonContainerView.heightAnchor.constraint(equalToConstant: 170),
            
            // 按鈕標籤
            buttonLabel.topAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: 10),
            buttonLabel.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor, constant: 10),
            buttonLabel.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor, constant: -10),
            
            // 圓形響應按鈕（方形外觀，圓形響應區域）
            circularButton.topAnchor.constraint(equalTo: buttonLabel.bottomAnchor, constant: 10),
            circularButton.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor),
            circularButton.widthAnchor.constraint(equalToConstant: 100),
            circularButton.heightAnchor.constraint(equalToConstant: 100),
            
            // 提示標籤
            hintLabel.topAnchor.constraint(equalTo: circularButton.bottomAnchor, constant: 8),
            hintLabel.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor, constant: 10),
            hintLabel.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor, constant: -10),
            
            // 說明標籤
            instructionLabel.topAnchor.constraint(equalTo: buttonContainerView.bottomAnchor, constant: 10),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 父視圖 (藍色) - 300x300，居中顯示
            parentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            parentView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 10),
            parentView.widthAnchor.constraint(equalToConstant: 300),
            parentView.heightAnchor.constraint(equalToConstant: 300),
            
            // 子視圖 1 (綠色) - 200x200，位於父視圖左上角
            childView1.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 20),
            childView1.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20),
            childView1.widthAnchor.constraint(equalToConstant: 200),
            childView1.heightAnchor.constraint(equalToConstant: 200),
            
            // 孫視圖 (橙色) - 100x100，位於子視圖1的中心
            grandchildView.centerXAnchor.constraint(equalTo: childView1.centerXAnchor),
            grandchildView.centerYAnchor.constraint(equalTo: childView1.centerYAnchor),
            grandchildView.widthAnchor.constraint(equalToConstant: 100),
            grandchildView.heightAnchor.constraint(equalToConstant: 100),
            
            // 子視圖 2 (紫色) - 120x120，位於父視圖右下角
            childView2.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -20),
            childView2.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20),
            childView2.widthAnchor.constraint(equalToConstant: 120),
            childView2.heightAnchor.constraint(equalToConstant: 120),
        ])
    }
    
    // MARK: - Actions
    
    /// 清除日誌
    @objc private func clearLog() {
        logTextView.text = ""
        logCounter = 0
        log("日誌已清除")
        log("")
    }
    
    /// 圓形按鈕點擊事件
    @objc private func circularButtonTapped() {
        log("🎉 按鈕成功響應點擊事件！")
        log("   └─ 說明：因為點擊位置在圓形區域內")
        log("")
    }
    
    /// 顯示 UI 繪製演示
    @objc private func showDrawingDemo() {
        let demoVC = DrawingDemoViewController()
        demoVC.modalPresentationStyle = .fullScreen
        present(demoVC, animated: true)
    }
    
    /// 顯示 KVO 演示
    @objc private func showKVODemo() {
        let demoVC = KVODemoViewController()
        demoVC.modalPresentationStyle = .fullScreen
        present(demoVC, animated: true)
    }
    
    /// 顯示 Delegate 和 Protocol 演示
    @objc private func showDelegateProtocolDemo() {
        let demoVC = DelegateProtocolDemoViewController()
        demoVC.modalPresentationStyle = .fullScreen
        present(demoVC, animated: true)
    }
    
    // MARK: - Touch Events Override
    
    /// 重寫 ViewController 的 touchesBegan，展示響應鏈繼續向上傳遞
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        log("⬆️ [ViewController] touchesBegan 被調用")
        log("   └─ 事件已到達 ViewController，繼續傳遞...")
        super.touchesBegan(touches, with: event)
    }
}

// MARK: - LogDelegate

extension ViewController: LogDelegate {
    /// 記錄日誌到文本視圖
    func log(_ message: String) {
        logCounter += 1
        let timestamp = String(format: "%03d", logCounter)
        let logMessage = "[\(timestamp)] \(message)\n"
        logTextView.text += logMessage
        
        // 自動滾動到底部
        let range = NSRange(location: logTextView.text.count - 1, length: 1)
        logTextView.scrollRangeToVisible(range)
    }
}

