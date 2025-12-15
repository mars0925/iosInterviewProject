//
//  SecondViewController.swift
//  InterviewDemoProject
//
//  This is a simple second ViewController to demonstrate that View lifecycle methods
//  ARE called when pushing/popping ViewControllers (unlike backgrounding the app)
//

import UIKit

class SecondViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "第二個頁面"
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "點擊返回按鈕，觀察第一個頁面的\nviewWillAppear 和 viewDidAppear 會被調用"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let noteLabel: UILabel = {
        let label = UILabel()
        label.text = """
        📝 重要區別：
        
        ✅ Push/Pop ViewController：
           會調用 View 生命週期方法
           (viewWillAppear, viewDidAppear, etc.)
        
        ❌ App 進入背景/返回前景：
           不會調用 View 生命週期方法
           (只調用 App 層級的方法)
        """
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .label
        label.backgroundColor = .systemGray6
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("⭐️ [SecondViewController] viewDidLoad")
        
        view.backgroundColor = .systemBackground
        title = "第二頁面"
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("⭐️ [SecondViewController] viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("⭐️ [SecondViewController] viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("⭐️ [SecondViewController] viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("⭐️ [SecondViewController] viewDidDisappear")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(instructionLabel)
        view.addSubview(noteLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            noteLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 40),
            noteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        // Add padding to note label
        noteLabel.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        noteLabel.insetsLayoutMarginsFromSafeArea = true
    }
    
    deinit {
        print("⭐️ [SecondViewController] deinit - deallocated")
    }
}

