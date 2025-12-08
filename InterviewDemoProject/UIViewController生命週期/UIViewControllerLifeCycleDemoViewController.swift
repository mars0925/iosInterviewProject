//
//  UIViewControllerLifeCycleDemoViewController.swift
//  InterviewDemoProject
//
//  UIViewController 生命週期演示
//

import UIKit

// MARK: - Lifecycle Demo View Controller
/// 演示生命週期的 ViewController
/// 這個 ViewController 會記錄所有生命週期方法的調用
class LifeCycleDemoVC: UIViewController {
    
    // Identifier for this view controller
    let vcName: String
    
    // UI Components
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let animationView = UIView()
    
    // MARK: - Initialization
    /// 程式碼初始化
    init(name: String) {
        self.vcName = name
        super.init(nibName: nil, bundle: nil)
        log("init(nibName:bundle:) - ViewController 對象創建")
    }
    
    /// 從 Storyboard 初始化
    required init?(coder: NSCoder) {
        self.vcName = "從 Storyboard"
        super.init(coder: coder)
        log("init(coder:) - 從 Storyboard 創建")
    }
    
    // MARK: - View Loading
    /// 加載視圖
    /// 如果需要完全自定義視圖，可以重寫這個方法
    override func loadView() {
        super.loadView()
        log("loadView() - 創建/加載視圖層級")
        // 注意：如果重寫此方法並完全自定義視圖，需要給 self.view 賦值
        // self.view = UIView()
    }
    
    /// 視圖加載完成
    /// 這是進行一次性設置的最佳時機
    override func viewDidLoad() {
        super.viewDidLoad()
        log("viewDidLoad() - 視圖加載完成（只調用一次）")
        
        setupUI()
        log("  └─ UI 設置完成")
    }
    
    // MARK: - View Appearance
    /// 視圖即將出現
    /// 每次視圖即將顯示時都會調用
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log("viewWillAppear(_:) - 視圖即將出現 (animated: \(animated))")
        
        // 更新可能改變的內容
        updateContent()
        log("  └─ 內容更新完成")
    }
    
    /// 視圖即將佈局子視圖
    /// 可能被多次調用（旋轉、鍵盤等）
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        log("viewWillLayoutSubviews() - 即將佈局子視圖")
        log("  └─ 當前 view.bounds: \(view.bounds)")
    }
    
    /// 視圖完成佈局子視圖
    /// 此時可以獲取準確的視圖尺寸
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        log("viewDidLayoutSubviews() - 子視圖佈局完成")
        log("  └─ 最終 view.bounds: \(view.bounds)")
        
        // 更新依賴於視圖尺寸的內容
        updateAnimationViewPosition()
    }
    
    /// 視圖已經出現
    /// 視圖完全顯示在螢幕上後調用
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log("viewDidAppear(_:) - 視圖已完全顯示 (animated: \(animated))")
        
        // 開始動畫或其他操作
        startAnimation()
        log("  └─ 動畫已開始")
    }
    
    // MARK: - View Disappearance
    /// 視圖即將消失
    /// 視圖即將從螢幕移除前調用
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        log("viewWillDisappear(_:) - 視圖即將消失 (animated: \(animated))")
        
        // 保存數據或狀態
        stopAnimation()
        log("  └─ 動畫已停止")
    }
    
    /// 視圖已經消失
    /// 視圖已經從螢幕移除後調用
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        log("viewDidDisappear(_:) - 視圖已完全消失 (animated: \(animated))")
        
        // 釋放資源
        log("  └─ 資源清理完成")
    }
    
    // MARK: - Memory Warning
    /// 記憶體警告
    /// 系統記憶體不足時調用
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        log("didReceiveMemoryWarning() - ⚠️ 收到記憶體警告")
        
        // 清理緩存和不必要的資源
        log("  └─ 清理緩存")
    }
    
    // MARK: - Deinitialization
    deinit {
        log("deinit - ViewController 被銷毀")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title Label
        titleLabel.text = vcName
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Description Label
        descriptionLabel.text = "查看控制台日誌觀察生命週期"
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        // Animation View
        animationView.backgroundColor = .systemBlue
        animationView.layer.cornerRadius = 25
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 50),
            animationView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Helper Methods
    private func updateContent() {
        // 模擬內容更新
        descriptionLabel.text = "已更新 @ \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium))"
    }
    
    private func updateAnimationViewPosition() {
        // 確保動畫視圖位置正確
        animationView.layer.removeAllAnimations()
    }
    
    private func startAnimation() {
        // 開始旋轉動畫
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 2.0
        rotation.repeatCount = .infinity
        animationView.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    private func stopAnimation() {
        // 停止動畫
        animationView.layer.removeAllAnimations()
    }
    
    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        print("[\(timestamp)] [\(vcName)] \(message)")
    }
}

// MARK: - Main Demo View Controller
/// 主演示 ViewController
/// 提供按鈕來演示不同的生命週期場景
class UIViewControllerLifeCycleDemoViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let instructionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIViewController 生命週期"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupButtons()
        
        print("\n" + String(repeating: "=", count: 60))
        print("UIViewController 生命週期演示")
        print(String(repeating: "=", count: 60) + "\n")
    }
    
    private func setupUI() {
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Instruction Label
        instructionLabel.text = """
        演示說明：
        
        1. 點擊下方按鈕進入不同的演示頁面
        2. 觀察控制台日誌輸出
        3. 返回本頁面繼續體驗其他場景
        
        請打開 Xcode 控制台查看詳細日誌！
        """
        instructionLabel.font = .systemFont(ofSize: 15)
        instructionLabel.textColor = .secondaryLabel
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .left
        instructionLabel.backgroundColor = .systemGray6
        instructionLabel.layer.cornerRadius = 12
        instructionLabel.clipsToBounds = true
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add padding
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(instructionLabel)
        contentView.addSubview(containerView)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            instructionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            instructionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            instructionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            instructionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupButtons() {
        let scenarios = [
            ("Push 導航", "演示 Push 導航的生命週期", #selector(pushDemo)),
            ("Present 模態", "演示 Present 模態的生命週期", #selector(presentDemo)),
            ("Present 全螢幕", "演示全螢幕模態的生命週期", #selector(presentFullScreenDemo)),
            ("嵌套導航", "演示嵌套導航控制器的生命週期", #selector(nestedNavigationDemo)),
            ("模擬記憶體警告", "觸發記憶體警告回調", #selector(simulateMemoryWarning))
        ]
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        for (title, description, action) in scenarios {
            let button = createScenarioButton(title: title, description: description, action: action)
            stackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: instructionLabel.superview!.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func createScenarioButton(title: String, description: String, action: Selector) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemBlue.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .systemBlue
        
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        container.addGestureRecognizer(tapGesture)
        
        return container
    }
    
    // MARK: - Demo Actions
    @objc private func pushDemo() {
        print("\n" + String(repeating: "-", count: 60))
        print("場景 1: Push 導航")
        print(String(repeating: "-", count: 60) + "\n")
        
        let demoVC = LifeCycleDemoVC(name: "Push Demo")
        demoVC.view.backgroundColor = .systemBackground
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    @objc private func presentDemo() {
        print("\n" + String(repeating: "-", count: 60))
        print("場景 2: Present 模態（非全螢幕）")
        print(String(repeating: "-", count: 60) + "\n")
        
        let demoVC = LifeCycleDemoVC(name: "Present Demo")
        demoVC.view.backgroundColor = .systemBackground
        
        // 添加關閉按鈕
        let closeButton = UIButton(type: .close)
        closeButton.addTarget(self, action: #selector(dismissDemo), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        demoVC.view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: demoVC.view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: demoVC.view.trailingAnchor, constant: -16)
        ])
        
        present(demoVC, animated: true)
    }
    
    @objc private func presentFullScreenDemo() {
        print("\n" + String(repeating: "-", count: 60))
        print("場景 3: Present 全螢幕模態")
        print(String(repeating: "-", count: 60) + "\n")
        
        let demoVC = LifeCycleDemoVC(name: "Full Screen Demo")
        demoVC.view.backgroundColor = .systemBackground
        demoVC.modalPresentationStyle = .fullScreen
        
        // 添加關閉按鈕
        let closeButton = UIButton(type: .close)
        closeButton.addTarget(self, action: #selector(dismissDemo), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        demoVC.view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: demoVC.view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: demoVC.view.trailingAnchor, constant: -16)
        ])
        
        present(demoVC, animated: true)
    }
    
    @objc private func nestedNavigationDemo() {
        print("\n" + String(repeating: "-", count: 60))
        print("場景 4: 嵌套導航控制器")
        print(String(repeating: "-", count: 60) + "\n")
        
        let demoVC = LifeCycleDemoVC(name: "Nested Nav Demo")
        demoVC.view.backgroundColor = .systemBackground
        
        let navController = UINavigationController(rootViewController: demoVC)
        demoVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissDemo)
        )
        
        present(navController, animated: true)
    }
    
    @objc private func simulateMemoryWarning() {
        print("\n" + String(repeating: "-", count: 60))
        print("場景 5: 模擬記憶體警告")
        print(String(repeating: "-", count: 60) + "\n")
        
        // 模擬記憶體警告（僅在模擬器中有效）
        #if targetEnvironment(simulator)
        NotificationCenter.default.post(
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: UIApplication.shared
        )
        print("✅ 記憶體警告已發送（僅模擬器）")
        #else
        print("⚠️ 記憶體警告僅在模擬器中可用")
        #endif
        
        let alert = UIAlertController(
            title: "記憶體警告",
            message: "已觸發記憶體警告通知，請查看控制台日誌",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func dismissDemo() {
        dismiss(animated: true)
    }
}

