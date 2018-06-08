//
//  VocabularyViewController.swift
//  VocabularyTrainer
//
//  Created by M, Vijayaragavan on 6/8/18.
//  Copyright © 2018 M, Vijayaragavan. All rights reserved.
//

import UIKit

private struct Constants {
    
    
    static let title                = "Lesson: %d"
    static let evaluate             = "Evaluate"
    static let summaryVC            = "summaryVC"
    static let lessonCompletionVC   = "lessonCompletionVC"
    static let next                 = "Next"
    static let correct              = "Correct"
    static let finished             = "Finished"
    static let wrongImage           = "wrong"
    static let correctImage         = "correct"
    
}

class VocabularyViewController: UIViewController,LessonCompletionDelegate {
    
    @IBOutlet var germanWordLabel: UILabel!
    @IBOutlet var correctAnswerLabel: UILabel!
    @IBOutlet var englisWordTextField: UITextField!
    @IBOutlet var evaluationButton: UIButton!
    @IBOutlet var resultImageView: UIImageView!
    
    private var vocabularies:[Lesson] = []
    var lastSelectedIndex:Int?
    var answer:String?
    var generatedNumber:[Int] = []
    var correctAnswerCount = 0
    var wrongAnswerCount = 0
    var level:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadVocabularies()
        
    }
    
    //Fetch vocabularies from database
    func loadVocabularies()  {
        correctAnswerCount = 0
        wrongAnswerCount = 0
        englisWordTextField.borderColor = UIColor.clear
        englisWordTextField.textColor = UIColor.black
        generatedNumber.removeAll()
        lastSelectedIndex = nil
        answer = nil
        if let vocabularies = CoreDataManager.getLesson() {
            
            for vocabulary in vocabularies {
                print("=====>",vocabulary.level,"========",vocabulary.count)
            }
            if vocabularies.count > 0 {
                level = Int(vocabularies[0].level)
            }
            self.vocabularies = vocabularies.filter{$0.count < 4}
            
            if self.vocabularies.count > 0 {
                let vocabulary = vocabularies[0]
                title = String(format: Constants.title, vocabulary.level)
            }
            displayVocabulary()
        }
    }
    
    
    //Display vocabulary
    func displayVocabulary() {
        
        englisWordTextField.text = nil
        resultImageView.image = nil
        correctAnswerLabel.isHidden = true
        englisWordTextField.isEnabled = true
        evaluationButton.setTitle(Constants.evaluate, for: .normal)
        
        if vocabularies.count == 0 {
            displaySuccessVC(successLevel: level)
            return
        }
        var isVocabularySelected = false
        
        while isVocabularySelected == false {
            
            let randomNum = Int(arc4random_uniform(UInt32(vocabularies.count)))
            let vocabulary = vocabularies[randomNum]
            if vocabulary.count < 4 && !generatedNumber.contains(randomNum){
                germanWordLabel.text = vocabulary.german
                answer = vocabulary.english
                isVocabularySelected = true
                lastSelectedIndex = randomNum
                generatedNumber.append(randomNum)
            } else if (isFinished() == true) || (generatedNumber.count == vocabularies.count) {
                break
            }
        }
        
        
    }
    
    
    //Check all vocabularies are correctly evaluated for 4 times
    func isFinished() -> Bool {
        var count = 0
        var level = 0
        for vocabulary in vocabularies {
            if vocabulary.count < 4 {
                count += 1
            }
            level = Int(vocabulary.level)
        }
        
        if count == 1 {
            lastSelectedIndex = nil
            generatedNumber.removeAll()
            return false
        }else if count == 0 {
            displaySuccessVC(successLevel: level)
            return true
        }
        return false
    }
    
    
    //Display summary viewcontroller
    func displaySummaryVC(level:Int) {
        let summaryVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.summaryVC) as! SummaryVC
        summaryVC.delegate = self
        summaryVC.wrongAnswerCount = wrongAnswerCount
        summaryVC.correctAnswerCount = correctAnswerCount
        summaryVC.level = level
        let navController = UINavigationController(rootViewController: summaryVC)
        self.present(navController, animated:true, completion: nil)
    }
    
    
    //Display lesson completion viewcontroller
    func displaySuccessVC(successLevel:Int) {
        let lessonCompletionVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.lessonCompletionVC) as! LessonCompletionVC
        lessonCompletionVC.delegate = self
        lessonCompletionVC.level = successLevel
        let navController = UINavigationController(rootViewController: lessonCompletionVC)
        self.present(navController, animated:true, completion: nil)
    }
    
    
    //Update evaluation(success/fail) count in database
    func updateSuccessCount() {
        let managedObjectContext = CoreDataManager.shared.managedObjectContext
        do {
            _ = try managedObjectContext.save()
        }
        catch {
            print("Failed to retrieve record")
            print(error)
        }
        
    }
    
    //Restart lession
    func restartLesson() {
        if isFinished() == false {
            loadVocabularies()
        }else {
            displaySuccessVC(successLevel: level)
        }
        
    }
    
    
    //Vocabulary evaluation success
    func correctEvaluation () {
        correctAnswerCount += 1
        self.answer = nil
        englisWordTextField.isEnabled = false
        englisWordTextField.borderColor = UIColor.green
        englisWordTextField.textColor = UIColor.lightGray
        evaluationButton.setTitle(Constants.next, for: .normal)
        resultImageView.image = UIImage(named: Constants.correctImage)
        correctAnswerLabel.isHidden = true
        if let index = lastSelectedIndex {
            let vocabulary = vocabularies[index]
            vocabulary.count += 1
            updateSuccessCount()
        }
        
        if generatedNumber.count == vocabularies.count && isFinished() == false {
            displaySummaryVC(level: level)
        }else if isFinished() == true {
            evaluationButton.setTitle(Constants.finished, for: .normal)
        }
    }
    
    
    //Vocabulary evaluation fail
    func wrongEvaluation () {
        resultImageView.image = UIImage(named: Constants.wrongImage)
        wrongAnswerCount += 1
        englisWordTextField.isEnabled = false
        englisWordTextField.borderColor = UIColor.red
        englisWordTextField.textColor = UIColor.lightGray
        if let answer = self.answer {
            correctAnswerLabel.isHidden = false
            correctAnswerLabel.text = Constants.correct+": "+answer
        }
        
        if let index = lastSelectedIndex {
            evaluationButton.setTitle(Constants.next, for: .normal)
            let vocabulary = vocabularies[index]
            vocabulary.count -= 1
            updateSuccessCount()
            let count = vocabularies.filter{$0.count < 4}.count
            if generatedNumber.count == count  {
                evaluationButton.isUserInteractionEnabled = false
                let delayInSeconds = 1.0
                let delay = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    self.evaluationButton.isUserInteractionEnabled = true
                    self.displaySummaryVC(level:self.level)
                }
            }
        }
    }
    
    
    //Show next vocabulary for evaluation
    func nextEvaluation() {
        englisWordTextField.borderColor = UIColor.clear
        englisWordTextField.textColor = UIColor.black
        displayVocabulary()
        let count = vocabularies.count
        if generatedNumber.count == count && count == 1{
            evaluationButton.isUserInteractionEnabled = false
            let delayInSeconds = 0.3
            let delay = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.evaluationButton.isUserInteractionEnabled = true
                self.displaySummaryVC(level:self.level)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//Extension for Action
extension VocabularyViewController {
    
    //Evaluation Action
    @IBAction func evaluationAction(_ sender: Any) {
        
        guard let count = englisWordTextField.text?.count,count > 0 else {
            return
        }
        
        if let answer = self.answer,let trimedValue = englisWordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),answer.caseInsensitiveCompare(trimedValue) == .orderedSame {
            correctEvaluation()
        } else if evaluationButton.titleLabel?.text == Constants.next{
            nextEvaluation()
        }else if evaluationButton.titleLabel?.text != Constants.finished{
            wrongEvaluation()
        }
    }
    
}