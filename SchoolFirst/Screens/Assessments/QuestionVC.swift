//
//  QuestionVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//

import UIKit

class QuestionVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    struct MCQ {
        let number: Int
        let question: String
        let description: String?
        let options: [String]
    }

    var questions: [MCQ] = []

    override func viewDidLoad() {
        super.viewDidLoad()

         collectionView.register(
            UINib(nibName: "QuestionCell", bundle: nil),
            forCellWithReuseIdentifier: "QuestionCell"
        )

     
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self

        loadQuestions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

         if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(
                width: collectionView.frame.width,
                height: collectionView.frame.height
            )
        }
    }

     func loadQuestions() {

        questions = [

            MCQ(number: 1,
                question: "What is 2 + 2?",
                description: "Basic addition question.",
                options: ["1", "2", "3", "4", "5"]
            ),

            MCQ(number: 2,
                question: "Which planet is red?",
                description: nil,   // hides description
                options: ["Earth", "Mars", "Jupiter", "Venus", "Saturn"]
            ),

            MCQ(number: 3,
                question: "Largest ocean?",
                description: "Hint: It starts with P.",
                options: ["Indian", "Atlantic", "Arctic", "Pacific", "None"]
            ),

             MCQ(number: 4, question: "Sample Q4", description: nil, options: ["A","B","C","D","E"]),
            MCQ(number: 5, question: "Sample Q5", description: nil, options: ["A","B","C","D","E"]),
            MCQ(number: 6, question: "Sample Q6", description: nil, options: ["A","B","C","D","E"]),
            MCQ(number: 7, question: "Sample Q7", description: nil, options: ["A","B","C","D","E"]),
            MCQ(number: 8, question: "Sample Q8", description: nil, options: ["A","B","C","D","E"]),
            MCQ(number: 9, question: "Sample Q9", description: nil, options: ["A","B","C","D","E"]),
            MCQ(number: 10, question: "Sample Q10", description: nil, options: ["A","B","C","D","E"]),
            MCQ(number: 11, question: "Sample Q11", description: nil, options: ["A","B","C","D","E"]),
            MCQ(number: 12, question: "Sample Q12", description: nil, options: ["A","B","C","D","E"])
        ]
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

        let q = questions[indexPath.item]

         cell.QuestionNo.text = "Q\(q.number)"
        cell.Question.text = q.question

        if let desc = q.description {
            cell.Description.isHidden = false
            cell.Description.text = desc
        } else {
            cell.Description.isHidden = true
        }

         cell.optionA.setTitle(q.options[0], for: .normal)
        cell.optionB.setTitle(q.options[1], for: .normal)
        cell.optionC.setTitle(q.options[2], for: .normal)
        cell.optionD.setTitle(q.options[3], for: .normal)
        cell.optionE.setTitle(q.options[4], for: .normal)

        return cell
    }
}

 extension QuestionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return collectionView.bounds.size   // ✅ height = 480
    }
}

