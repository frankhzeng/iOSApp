import UIKit

class QuizController : UIViewController {
    var quiz: Quiz!
    @IBOutlet var testWordLabel: UILabel!
    @IBOutlet var aButton: UIButton!
    @IBOutlet var bButton: UIButton!
    @IBOutlet var cButton: UIButton!
    @IBOutlet var resultView: UIView!
    @IBOutlet var resultLabel: UILabel!
    var correctIndex: Int?
    var currQuestion = 0;
    var correctAnswers = 0;
    override func viewDidLoad() {
        super.viewDidLoad()
        resultView.center = self.view.center;
        resultView.layer.cornerRadius = 15;
        self.aButton.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10);
        self.bButton.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10);
        self.cButton.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10);
        self.aButton.layer.borderWidth = 5;
        self.aButton.layer.borderColor = UIColor.lightGray.cgColor
        self.bButton.layer.borderWidth = 5;
        self.bButton.layer.borderColor = UIColor.lightGray.cgColor
        self.cButton.layer.borderWidth = 5;
        self.cButton.layer.borderColor = UIColor.lightGray.cgColor
        self.aButton.layer.cornerRadius = 10;
        self.bButton.layer.cornerRadius = 10;
        self.cButton.layer.cornerRadius = 10;
        let currQuestion = quiz.questions.first!;
        loadQuestion(current: currQuestion)
    }
    
    func loadQuestion(current: QuizQuestion) {
        self.title = "\(currQuestion+1) / \(quiz.questions.count)"
        testWordLabel.text = current.word.word;
        aButton.setTitle(current.answerA, for: .normal);
        bButton.setTitle(current.answerB, for: .normal);
        cButton.setTitle(current.answerC, for: .normal);
        correctIndex = current.correctAnswer;
    }
    
    @IBAction func aButtonPressed() {
        if (correctIndex == 1) {
            correctAnswers += 1;
            aButton.layer.borderColor = UIColor.systemGreen.cgColor;
        } else {
            aButton.layer.borderColor = UIColor.systemRed.cgColor;
        }
        bButton.alpha = 0.5;
        cButton.alpha = 0.5;
        aButton.isUserInteractionEnabled = false;
        bButton.isUserInteractionEnabled = false;
        cButton.isUserInteractionEnabled = false;
        currQuestion += 1;
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if (self.currQuestion < self.quiz.questions.count) {
                self.loadQuestion(current: self.quiz.questions[self.currQuestion])
            } else {
                self.resultLabel.text = "You got \(self.correctAnswers) / \(self.quiz.questions.count) questions correct."
                self.view.addSubview(self.resultView)
            }
            self.aButton.layer.borderColor = UIColor.lightGray.cgColor
            self.bButton.alpha = 1;
            self.cButton.alpha = 1;
            self.aButton.isUserInteractionEnabled = true;
            self.bButton.isUserInteractionEnabled = true;
            self.cButton.isUserInteractionEnabled = true;
        }

    }
    @IBAction func bButtonPressed() {
        if (correctIndex == 2) {
            correctAnswers += 1;
            bButton.layer.borderColor = UIColor.systemGreen.cgColor;
        } else {
            bButton.layer.borderColor = UIColor.systemRed.cgColor;
        }
        aButton.alpha = 0.5;
        cButton.alpha = 0.5;
        aButton.isUserInteractionEnabled = false;
        bButton.isUserInteractionEnabled = false;
        cButton.isUserInteractionEnabled = false;
        currQuestion += 1;
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if (self.currQuestion < self.quiz.questions.count) {
                self.loadQuestion(current: self.quiz.questions[self.currQuestion])
            } else {
                self.resultLabel.text = "You got \(self.correctAnswers) / \(self.quiz.questions.count) questions correct."
                self.view.addSubview(self.resultView)
            }
            self.bButton.layer.borderColor = UIColor.lightGray.cgColor
            self.aButton.alpha = 1;
            self.cButton.alpha = 1;
            self.aButton.isUserInteractionEnabled = true;
            self.bButton.isUserInteractionEnabled = true;
            self.cButton.isUserInteractionEnabled = true;
        }
        
    }
    @IBAction func cButtonPressed() {
        if (correctIndex == 3) {
            correctAnswers += 1;
            cButton.layer.borderColor = UIColor.systemGreen.cgColor;
        } else {
            cButton.layer.borderColor = UIColor.systemRed.cgColor;
        }
        aButton.alpha = 0.5;
        bButton.alpha = 0.5;
        aButton.isUserInteractionEnabled = false;
        bButton.isUserInteractionEnabled = false;
        cButton.isUserInteractionEnabled = false;
        currQuestion += 1;
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if (self.currQuestion < self.quiz.questions.count) {
                self.loadQuestion(current: self.quiz.questions[self.currQuestion])
            } else {
                self.resultLabel.text = "You got \(self.correctAnswers) / \(self.quiz.questions.count) questions correct."
                self.view.addSubview(self.resultView)
            }
            self.cButton.layer.borderColor = UIColor.lightGray.cgColor
            self.aButton.alpha = 1;
            self.bButton.alpha = 1;
            self.aButton.isUserInteractionEnabled = true;
            self.bButton.isUserInteractionEnabled = true;
            self.cButton.isUserInteractionEnabled = true;
        }
    }
}

extension QuizController {
    @IBAction func doneButtonPressed() {
        self.navigationController?.popToRootViewController(animated: true);
    }
    @IBAction func restartButtonPressed() {
        self.quiz.questions.shuffle();
        self.currQuestion = 0;
        self.correctAnswers = 0;
        let currQuestion = quiz.questions.first!;
        loadQuestion(current: currQuestion)
        
        resultView.removeFromSuperview()
    }
}
