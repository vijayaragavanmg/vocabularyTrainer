//
//  SummaryVC.swift
//  VocabularyTrainer
//
//  Created by M, Vijayaragavan on 6/8/18.
//  Copyright © 2018 M, Vijayaragavan. All rights reserved.
//

import UIKit

private struct Constants {
    
    static let title             = "Lesson: %d"
    static let successMessage     = "You successfully finished the lesson!"
    static let correct            = "Correct"
    static let wrong              = "Wrong"
    
}

class SummaryVC: UIViewController {
    
    @IBOutlet var completionMessageLabel: UILabel!
    @IBOutlet var correctAnswerLabel: UILabel!
    @IBOutlet var wrongAnswerLabel: UILabel!
    @IBOutlet var restartButton: UIButton!
    
    weak var delegate:LessonCompletionDelegate?
    var level:Int = 0
    var correctAnswerCount = 0
    var wrongAnswerCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(format: Constants.title, level)
        completionMessageLabel.text = Constants.successMessage
        correctAnswerLabel.text = Constants.correct+": "+String(correctAnswerCount)
        wrongAnswerLabel.text = Constants.wrong+": "+String(wrongAnswerCount)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


//Extension for Action
extension SummaryVC {
    
    //Restart Lesson
    @IBAction func restartAction(_ sender: Any) {
        delegate?.restartLesson()
        dismiss(animated: true, completion: nil)
        
        
    }
}
