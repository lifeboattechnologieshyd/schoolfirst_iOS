//
//  QuestionVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//
import UIKit

class QuestionVC: UIViewController {

    @IBOutlet weak var secondPopupVw: UIView!
    @IBOutlet weak var scoreVw: UIView!
    @IBOutlet weak var scoreNumberLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var progressVw: UIProgressView!
    @IBOutlet weak var viewanswersButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    struct MCQ {
        let number: Int
        let question: String
        let description: String?
        let options: [String]
        let correctAnswer: Int
    }

    var questions: [MCQ] = []
    var correctAnswers = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(
            UINib(nibName: "QuestionCell", bundle: nil),
            forCellWithReuseIdentifier: "QuestionCell"
        )

        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = false
        
        loadQuestions()
        secondPopupVw.isHidden = true

        viewanswersButton.addTarget(self, action: #selector(viewAnswersTapped(_:)), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.itemSize = collectionView.bounds.size
            layout.invalidateLayout()
        }

        // Circle
        scoreVw.layer.cornerRadius = scoreVw.frame.height / 2
        scoreVw.layer.borderWidth = 4
        scoreVw.layer.borderColor = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1).cgColor
        scoreVw.clipsToBounds = true
    }

    func loadQuestions() {
        questions = [
            MCQ(number: 1, question: "What is 2 + 2?", description: "Basic Addition", options: ["1","2","3","4","5"], correctAnswer: 3),
            MCQ(number: 2, question: "Which planet is red?", description: "Mars is red", options: ["Mercury","Mars","Earth","Jupiter","Venus"], correctAnswer: 1),
            MCQ(number: 3, question: "Largest Ocean?", description: "Starts with P", options: ["Indian","Arctic","Atlantic","Pacific","None"], correctAnswer: 3),
            MCQ(number: 4, question: "Sample Q4?", description: nil, options: ["A","B","C","D","E"], correctAnswer: 0),
            MCQ(number: 5, question: "Sample Q5?", description: nil, options: ["A","B","C","D","E"], correctAnswer: 1),
            MCQ(number: 6, question: "Sample Q6?", description: nil, options: ["A","B","C","D","E"], correctAnswer: 2),
            MCQ(number: 7, question: "Sample Q7?", description: nil, options: ["A","B","C","D","E"], correctAnswer: 0),
            MCQ(number: 8, question: "Sample Q8?", description: nil, options: ["A","B","C","D","E"], correctAnswer: 1),
            MCQ(number: 9, question: "Sample Q9?", description: nil, options: ["A","B","C","D","E"], correctAnswer: 3),
            MCQ(number: 10, question: "Sample Q10?", description: nil, options: ["A","B","C","D","E"], correctAnswer: 4),
            MCQ(number: 11, question: "Sample Q11?", description: nil, options: ["A","B","C","D","E"], correctAnswer: 2),
            MCQ(number: 12, question: "Sample Q12?", description: nil, options: ["A","B","C","D","E"], correctAnswer: 1)
        ]
    }

    @objc func optionTapped(_ sender: UIButton) {

        let qIndex = sender.tag / 10
        let oIndex = sender.tag % 10

        if oIndex == questions[qIndex].correctAnswer {
            correctAnswers += 1
        }

        // Last question → show popup
        if qIndex == questions.count - 1 {
            showSecondPopup()
            return
        }

        let nextX = collectionView.bounds.width * CGFloat(qIndex + 1)

        UIView.animate(withDuration: 0.3) {
            self.collectionView.contentOffset.x = nextX
        }
    }

    func showSecondPopup() {

        secondPopupVw.isHidden = false
        secondPopupVw.isUserInteractionEnabled = true   // ⭐ allows touches on popup
        view.bringSubviewToFront(secondPopupVw)

        scoreNumberLbl.text = "\(correctAnswers)"
        totalLbl.text = "\(questions.count)"

        progressVw.setProgress(Float(correctAnswers) / Float(questions.count), animated: true)

        secondPopupVw.alpha = 0
        secondPopupVw.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.4,
                       options: .curveEaseInOut) {

            self.secondPopupVw.alpha = 1
            self.secondPopupVw.transform = .identity
        }
    }

    @IBAction func viewAnswersTapped(_ sender: UIButton) {
        print("VIEW ANSWERS BUTTON PRESSED")

        let sb = UIStoryboard(name: "Main", bundle: nil)

        if let vc = sb.instantiateViewController(withIdentifier: "PastAssessmentsVC") as? PastAssessmentsVC {
            print("Navigation working")
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            print("PastAssessmentsVC NOT FOUND. Check storyboard ID.")
        }
    }
}

extension QuestionVC: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return questions.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "QuestionCell",
            for: indexPath
        ) as! QuestionCell

        cell.resetOptions()   // ⭐ FIX OVERLAPS + OLD STATE BUG

        let q = questions[indexPath.item]

        cell.QuestionNo.text = "Question \(q.number)/\(questions.count)"
        cell.Question.text = q.question
        cell.Description.text = q.description ?? ""

        let buttons = [cell.optionA, cell.optionB, cell.optionC, cell.optionD, cell.optionE]

        for (i, btn) in buttons.enumerated() {
            btn?.tag = (indexPath.item * 10) + i
            btn?.removeTarget(nil, action: nil, for: .allEvents)
            btn?.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        }

        return cell
    }
}

extension QuestionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}
