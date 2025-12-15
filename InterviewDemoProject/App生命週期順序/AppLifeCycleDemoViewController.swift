//
//  AppLifeCycleDemoViewController.swift
//  InterviewDemoProject
//
//  This ViewController demonstrates the lifecycle methods of both AppDelegate and UIViewController
//  It logs all lifecycle events to help understand the order of method calls in different scenarios
//

import UIKit

class AppLifeCycleDemoViewController: UIViewController {
    
    // MARK: - UI Components
    
    // ScrollView to display all lifecycle logs
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    // Label to display lifecycle event logs
    private let logLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    // Clear button to reset logs
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("清除記錄", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // Info button to show instructions
    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("說明", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // Next button to push to another ViewController
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("跳轉到下一頁", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // Array to store log messages
    private var logs: [String] = []
    
    // Date formatter for timestamps
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    // MARK: - Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addLog("init - ViewController initialized")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addLog("init(coder:) - ViewController initialized from storyboard")
    }
    
    // MARK: - Lifecycle Methods
    
    // Called after the view controller's view is loaded into memory
    // This is called only once in the ViewController's lifetime
    override func viewDidLoad() {
        super.viewDidLoad()
        addLog("viewDidLoad - View loaded into memory")
        
        setupUI()
        setupNotifications()
        
        title = "App 生命週期演示"
        view.backgroundColor = .systemBackground
        
        // Add close button for navigation
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "關閉",
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }
    
    // Called before the view is about to be added to the view hierarchy
    // This can be called multiple times (e.g., when returning from background)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addLog("viewWillAppear - View is about to appear")
    }
    
    // Called after the view has been added to the view hierarchy
    // This is where you typically start animations or load data
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addLog("viewDidAppear - View has appeared")
    }
    
    // Called before the view is about to be removed from the view hierarchy
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addLog("viewWillDisappear - View is about to disappear")
    }
    
    // Called after the view has been removed from the view hierarchy
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        addLog("viewDidDisappear - View has disappeared")
    }
    
    // Called when the view controller receives a memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        addLog("didReceiveMemoryWarning - Memory warning received")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Add subviews
        view.addSubview(scrollView)
        view.addSubview(clearButton)
        view.addSubview(infoButton)
        view.addSubview(nextButton)
        scrollView.addSubview(logLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Clear button constraints
            clearButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            clearButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            clearButton.widthAnchor.constraint(equalToConstant: 100),
            clearButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Info button constraints
            infoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            infoButton.widthAnchor.constraint(equalToConstant: 100),
            infoButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Next button constraints
            nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nextButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            nextButton.widthAnchor.constraint(equalToConstant: 120),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            
            // ScrollView constraints
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 16),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // LogLabel constraints
            logLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            logLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            logLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            logLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            logLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        // Add button actions
        clearButton.addTarget(self, action: #selector(clearLogs), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(pushToNextPage), for: .touchUpInside)
        
        updateLogDisplay()
    }
    
    // MARK: - Notification Setup
    
    // Register for AppDelegate lifecycle notifications
    private func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        
        // App did finish launching (not typically used in ViewController, but included for completeness)
        notificationCenter.addObserver(
            self,
            selector: #selector(appDidFinishLaunching),
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )
        
        // App will resign active (losing focus, e.g., incoming call, control center)
        notificationCenter.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        // App did become active (gained focus)
        notificationCenter.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        // App did enter background (moved to background)
        notificationCenter.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        // App will enter foreground (about to return from background)
        notificationCenter.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        // App will terminate (about to terminate, rarely called)
        notificationCenter.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    // MARK: - Notification Handlers
    
    @objc private func appDidFinishLaunching() {
        addLog("didFinishLaunchingWithOptions - App finished launching")
    }
    
    @objc private func appWillResignActive() {
        addLog("applicationWillResignActive - App will resign active")
    }
    
    @objc private func appDidBecomeActive() {
        addLog("applicationDidBecomeActive - App became active")
    }
    
    @objc private func appDidEnterBackground() {
        addLog("applicationDidEnterBackground - App entered background")
    }
    
    @objc private func appWillEnterForeground() {
        addLog("applicationWillEnterForeground - App will enter foreground")
    }
    
    @objc private func appWillTerminate() {
        addLog("applicationWillTerminate - App will terminate")
    }
    
    // MARK: - Log Management
    
    // Add a log entry with timestamp
    private func addLog(_ message: String) {
        let timestamp = dateFormatter.string(from: Date())
        let logEntry = "[\(timestamp)] \(message)"
        logs.append(logEntry)
        print(logEntry) // Also print to console
        
        // Update UI on main thread
        DispatchQueue.main.async { [weak self] in
            self?.updateLogDisplay()
        }
    }
    
    // Update the log display label
    private func updateLogDisplay() {
        logLabel.text = logs.joined(separator: "\n\n")
        
        // Scroll to bottom
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let bottomOffset = CGPoint(
                x: 0,
                y: max(0, self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.contentInset.bottom)
            )
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    // Clear all logs
    @objc private func clearLogs() {
        logs.removeAll()
        updateLogDisplay()
        addLog("清除記錄 - Logs cleared")
    }
    
    // Show info alert
    @objc private func showInfo() {
        let alert = UIAlertController(
            title: "使用說明",
            message: """
            這個演示展示了 App 生命週期方法的調用順序。
            
            測試方式：
            
            1️⃣ App 首次啟動：
            - 觀察初始載入時的方法調用順序
            - 會看到完整的 ViewController 生命週期
            
            2️⃣ App 縮下（進入背景）：
            - 按下 Home 鍵或切換到其他 App
            - ❌ 不會調用 viewWillDisappear/viewDidDisappear
            - ✅ 只會調用 App 層級的生命週期方法
            
            3️⃣ App 從背景打開：
            - 從背景切換回此 App
            - ❌ 不會調用 viewDidLoad（View 已在記憶體）
            - ❌ 不會調用 viewWillAppear/viewDidAppear
            - ✅ 只會調用 App 層級的生命週期方法
            
            4️⃣ Push 到其他頁面再返回：
            - 點擊「跳轉到下一頁」按鈕
            - 會看到完整的 View 生命週期方法調用
            - ✅ 這時才會調用 viewWillDisappear/viewDidDisappear
            - 返回時會調用 viewWillAppear/viewDidAppear
            
            重要觀念：
            View 生命週期方法只在 View 真正加入或移除視圖層級時調用，
            不會在 App 進入背景或返回前景時調用。
            
            提示：
            - 所有事件都會即時記錄並顯示
            - 可以點擊「清除記錄」重新測試
            - 記錄也會同時輸出到 Xcode 控制台
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "我知道了", style: .default))
        present(alert, animated: true)
    }
    
    // Push to next page
    @objc private func pushToNextPage() {
        addLog("準備跳轉到下一頁 - 即將看到 viewWillDisappear 和 viewDidDisappear")
        let secondVC = SecondViewController()
        navigationController?.pushViewController(secondVC, animated: true)
    }
    
    // Close button tapped
    @objc private func closeButtonTapped() {
        addLog("關閉按鈕被點擊 - 即將 dismiss")
        dismiss(animated: true)
    }
    
    // MARK: - Deinitialization
    
    deinit {
        // Remove all observers
        NotificationCenter.default.removeObserver(self)
        addLog("deinit - ViewController deallocated")
    }
}

// MARK: - Expected Output Examples

/*
 場景 1：App 首次啟動（重 build）
 =====================================
 [時間] init - ViewController initialized
 [時間] didFinishLaunchingWithOptions - App finished launching
 [時間] viewDidLoad - View loaded into memory
 [時間] viewWillAppear - View is about to appear
 [時間] applicationDidBecomeActive - App became active
 [時間] viewDidAppear - View has appeared
 
 
 場景 2：App 縮下（進入背景）
 =====================================
 [時間] applicationWillResignActive - App will resign active
 [時間] applicationDidEnterBackground - App entered background
 
 ❌ 注意：不會調用 viewWillDisappear 和 viewDidDisappear
 原因：ViewController 的 View 並沒有從視圖層級中移除，
      只是 App 進入背景而已。View 仍然存在於記憶體中。
 
 
 場景 3：App 從背景打開（回到前景）
 =====================================
 [時間] applicationWillEnterForeground - App will enter foreground
 [時間] applicationDidBecomeActive - App became active
 
 ❌ 注意：不會調用 viewWillAppear 和 viewDidAppear
 原因：ViewController 的 View 一直都在視圖層級中，從未被移除。
      View 只是隨著 App 從背景返回而重新可見。
 
 ✅ 也不會調用 viewDidLoad，因為 View 已經在記憶體中
 
 
 重要觀念
 =====================================
 ViewController 的 View 生命週期方法（viewWillAppear、viewDidAppear、
 viewWillDisappear、viewDidDisappear）只在 View 真正加入或移除視圖層級時調用：
 - ✅ Push/Pop ViewController
 - ✅ Present/Dismiss ViewController
 - ✅ addSubview/removeFromSuperview
 - ❌ App 進入背景或返回前景（View 沒有從層級中移除）
 */

