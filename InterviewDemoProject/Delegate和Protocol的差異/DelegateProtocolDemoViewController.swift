//
//  DelegateProtocolDemoViewController.swift
//  InterviewDemoProject
//
//  Delegate 和 Protocol 差異演示
//

import UIKit

// MARK: - Part 1: Protocol 基本用法（非 Delegate 模式）

/// Protocol 定義了一組能力/接口規範
/// 這是 Protocol 作為語言特性的用法，不是 Delegate 模式
protocol Drawable {
    var color: UIColor { get }
    func draw(in context: CGContext)
}

/// Protocol 可以被不同類型採納，實現多態
struct DrawableCircle: Drawable {
    var color: UIColor
    var radius: CGFloat
    
    func draw(in context: CGContext) {
        print("Drawing a \(color) circle with radius \(radius)")
    }
}

struct DrawableRectangle: Drawable {
    var color: UIColor
    var width: CGFloat
    var height: CGFloat
    
    func draw(in context: CGContext) {
        print("Drawing a \(color) rectangle \(width)x\(height)")
    }
}

// MARK: - Part 2: Delegate 設計模式（使用 Protocol 實現）

/// Delegate Protocol：定義委託者可以通知 delegate 的事件
/// 注意：繼承 AnyObject 使其只能被 class 採納，這樣才能使用 weak
protocol DataTaskDelegate: AnyObject {
    func dataTask(_ task: DataTask, didStartWithMessage message: String)
    func dataTask(_ task: DataTask, didUpdateProgress progress: Float)
    func dataTask(_ task: DataTask, didFinishWithResult result: String)
}

/// 委託者：負責執行任務，並在關鍵時刻通知 delegate
class DataTask {
    // weak 防止循環引用
    // delegate 是可選的，因為委託是可選的行為
    weak var delegate: DataTaskDelegate?
    
    private var taskName: String
    
    init(taskName: String) {
        self.taskName = taskName
    }
    
    /// 執行任務，並在不同階段通知 delegate
    func execute() {
        // 開始時通知
        delegate?.dataTask(self, didStartWithMessage: "Task '\(taskName)' started")
        
        // 模擬進度更新
        for progress in stride(from: 0.0, through: 1.0, by: 0.25) {
            delegate?.dataTask(self, didUpdateProgress: Float(progress))
        }
        
        // 完成時通知
        delegate?.dataTask(self, didFinishWithResult: "Task '\(taskName)' completed successfully")
    }
}

// MARK: - Part 3: 自定義 View 的 Delegate 模式

protocol CustomButtonDelegate: AnyObject {
    func customButtonDidTap(_ button: CustomDelegateButton)
    func customButton(_ button: CustomDelegateButton, didLongPressWithDuration duration: TimeInterval)
}

class CustomDelegateButton: UIButton {
    weak var customDelegate: CustomButtonDelegate?
    private var longPressStartTime: Date?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestures()
    }
    
    private func setupGestures() {
        // 點擊事件
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        // 長按手勢
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPress)
    }
    
    @objc private func handleTap() {
        // 委託給 delegate 處理點擊事件
        customDelegate?.customButtonDidTap(self)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            longPressStartTime = Date()
        case .ended:
            if let startTime = longPressStartTime {
                let duration = Date().timeIntervalSince(startTime)
                // 委託給 delegate 處理長按事件
                customDelegate?.customButton(self, didLongPressWithDuration: duration)
            }
        default:
            break
        }
    }
}

// MARK: - Main ViewController

class DelegateProtocolDemoViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let logTextView = UITextView()
    
    private var dataTask: DataTask?
    private var customButton: CustomDelegateButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        demonstrateProtocol()
    }
    
    private func setupUI() {
        title = "Delegate vs Protocol"
        view.backgroundColor = .systemBackground
        
        // ScrollView setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Section 1: Protocol 示範
        let protocolSection = createSectionView(
            title: "1. Protocol（語言特性）",
            description: "Protocol 定義接口規範，可用於多態"
        )
        
        let protocolButton = createButton(title: "演示 Protocol 多態", tag: 1)
        protocolSection.addArrangedSubview(protocolButton)
        
        // Section 2: Delegate 示範
        let delegateSection = createSectionView(
            title: "2. Delegate（設計模式）",
            description: "使用 Protocol 實現的委託模式"
        )
        
        let delegateButton = createButton(title: "演示 Delegate 模式", tag: 2)
        delegateSection.addArrangedSubview(delegateButton)
        
        // Section 3: 自定義 Delegate
        let customDelegateSection = createSectionView(
            title: "3. 自定義 Delegate",
            description: "點擊或長按按鈕測試 Delegate"
        )
        
        customButton = CustomDelegateButton(type: .system)
        customButton?.setTitle("測試按鈕（可點擊或長按）", for: .normal)
        customButton?.backgroundColor = .systemBlue
        customButton?.setTitleColor(.white, for: .normal)
        customButton?.layer.cornerRadius = 8
        customButton?.translatesAutoresizingMaskIntoConstraints = false
        customButton?.customDelegate = self
        customButton?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        if let customButton = customButton {
            customDelegateSection.addArrangedSubview(customButton)
        }
        
        // Log TextView
        logTextView.isEditable = false
        logTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logTextView.backgroundColor = .systemGray6
        logTextView.layer.cornerRadius = 8
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        logTextView.text = "日誌輸出區域\n"
        
        // Main Stack View
        let mainStack = UIStackView(arrangedSubviews: [
            protocolSection,
            delegateSection,
            customDelegateSection,
            logTextView
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            logTextView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func createSectionView(title: String, description: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 0
        
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        stack.axis = .vertical
        stack.spacing = 8
        
        return stack
    }
    
    private func createButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.tag = tag
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            demonstrateProtocol()
        case 2:
            demonstrateDelegate()
        default:
            break
        }
    }
    
    // MARK: - Demonstrations
    
    /// 演示 Protocol 作為語言特性的用法（非 Delegate）
    private func demonstrateProtocol() {
        log("\n=== Protocol 演示（語言特性） ===")
        log("Protocol 定義接口，實現多態")
        
        // 創建不同類型的 Drawable 對象
        let shapes: [Drawable] = [
            DrawableCircle(color: .red, radius: 50),
            DrawableRectangle(color: .blue, width: 100, height: 60),
            DrawableCircle(color: .green, radius: 30)
        ]
        
        log("\n使用 Protocol 實現多態：")
        // 多態：統一處理不同類型
        for (index, shape) in shapes.enumerated() {
            log("Shape \(index + 1): color = \(shape.color)")
            shape.draw(in: CGContext.init(
                data: nil,
                width: 100,
                height: 100,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: 0
            )!)
        }
        
        log("\n說明：這是 Protocol 的基本用法")
        log("用於定義共同接口，不是 Delegate 模式")
    }
    
    /// 演示 Delegate 設計模式
    private func demonstrateDelegate() {
        log("\n=== Delegate 演示（設計模式） ===")
        log("Delegate 使用 Protocol 實現對象間通信")
        
        // 創建任務並設置 delegate
        dataTask = DataTask(taskName: "下載數據")
        dataTask?.delegate = self  // ViewController 作為 delegate
        
        log("\n開始執行任務...")
        log("任務會通過 Delegate 回調通知狀態")
        
        // 執行任務（會觸發 delegate 回調）
        dataTask?.execute()
        
        log("\n說明：這是 Delegate 模式")
        log("DataTask 將狀態變化委託給 delegate 處理")
    }
    
    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logTextView.text += "[\(timestamp)] \(message)\n"
        
        // 自動滾動到底部
        let bottom = NSRange(location: logTextView.text.count - 1, length: 1)
        logTextView.scrollRangeToVisible(bottom)
    }
}

// MARK: - DataTaskDelegate Implementation

extension DelegateProtocolDemoViewController: DataTaskDelegate {
    
    /// Delegate 方法：任務開始
    func dataTask(_ task: DataTask, didStartWithMessage message: String) {
        log("📢 Delegate 回調: \(message)")
    }
    
    /// Delegate 方法：進度更新
    func dataTask(_ task: DataTask, didUpdateProgress progress: Float) {
        let percentage = Int(progress * 100)
        log("📊 Delegate 回調: 進度 \(percentage)%")
    }
    
    /// Delegate 方法：任務完成
    func dataTask(_ task: DataTask, didFinishWithResult result: String) {
        log("✅ Delegate 回調: \(result)")
    }
}

// MARK: - CustomButtonDelegate Implementation

extension DelegateProtocolDemoViewController: CustomButtonDelegate {
    
    /// Delegate 方法：按鈕點擊
    func customButtonDidTap(_ button: CustomDelegateButton) {
        log("\n🔘 自定義 Delegate 回調")
        log("按鈕被點擊了")
    }
    
    /// Delegate 方法：按鈕長按
    func customButton(_ button: CustomDelegateButton, didLongPressWithDuration duration: TimeInterval) {
        log("\n🔘 自定義 Delegate 回調")
        log(String(format: "按鈕被長按了 %.2f 秒", duration))
    }
}

/*
 總結：
 
 1. Protocol（語言特性）
    - 定義接口規範
    - 可以被任何類型採納
    - 用途廣泛：多態、擴展、約束等
    - 範例：Drawable protocol
 
 2. Delegate（設計模式）
    - 使用 Protocol 實現
    - 專門用於對象間通信
    - 通常使用 weak 防止循環引用
    - 通常是 class-only protocol（繼承 AnyObject）
    - 範例：DataTaskDelegate, CustomButtonDelegate
 
 3. 關係
    - Delegate 是使用 Protocol 實現的設計模式
    - Protocol 的用途不僅限於 Delegate
    - Protocol 是工具，Delegate 是模式
 
 4. 記憶要點
    - Protocol = 定義接口
    - Delegate = 委託責任
    - Delegate 一定用 Protocol
    - Protocol 不一定是 Delegate
 */

