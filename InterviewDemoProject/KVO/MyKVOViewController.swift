//
//  MyKVOViewController.swift
//  InterviewDemoProject
//
//  Created by MarsChang on 2025/12/5.
//

import UIKit

class MyKVOViewController: UIViewController {
    var stundet:Student = Student(name: "mars", age: 18)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var observation: NSKeyValueObservation = stundet.observe(\.age,options: [.new, .old]) { stundet, change in
            print("action;\(stundet.age)")
            print("\(change.newValue)")
            print("\(change.oldValue)")
        }
        
        stundet.age = 10
        stundet.age = 20
       

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
