//
//  LessonCompletionVC.swift
//  VocabularyTrainer
//
//  Created by M, Vijayaragavan on 6/8/18.
//  Copyright © 2018 M, Vijayaragavan. All rights reserved.
//

import UIKit

private struct Constants {
    
    static let title                        = "Lesson: %d"
    static let successMessageAllLesson      = "Congratulation, you successfully finished all lesson!"
    static let successMessage               = "Congratulation, you just finished the lesson %d successfully!"
    static let maxLession                   = 10
    
}

protocol LessonCompletionDelegate:class {
    func loadVocabularies()
    func restartLesson()
}

class LessonCompletionVC: UIViewController {
    
    
    @IBOutlet var completionMessageLabel: UILabel!
    @IBOutlet var nextLessonButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var level:Int = 0
    weak var delegate:LessonCompletionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(format: Constants.title,level)
        
        if level == Constants.maxLession {
            nextLessonButton.isHidden = true
            completionMessageLabel.text = Constants.successMessageAllLesson
        }else {
            completionMessageLabel.text = String(format: Constants.successMessage,level)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension LessonCompletionVC {
    
    @IBAction func nextLessonAction(_ sender: Any) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            CoreDataManager.loadVocabularyData(lessonNumber: self.level+1, completion: { (status,error) in
                if status == true {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.delegate?.loadVocabularies()
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }
            })
            
        }
    }
    
}
