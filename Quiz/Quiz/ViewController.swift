//
//  ViewController.swift
//  Quiz
//
//  Created by Aleksander  on 16/04/2019.
//
// Created with CodeWithCris course

import UIKit

class ViewController: UIViewController, QuizProtocol, UITableViewDelegate, UITableViewDataSource, ResultViewControllerProtocol {
    
    
    
    @IBOutlet weak var stackViewTrailingConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rootStackView: UIStackView!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var model = QuizModel()
    var questions = [Question]()
    var questionIndex = 0
    var numCorrect = 0
    
    // wyswietlenie alertu
    var resultVC:ResultViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        resultVC = storyboard?.instantiateViewController(withIdentifier: "ResultVC") as? ResultViewController
        
        resultVC?.delegate = self
        resultVC?.modalPresentationStyle = .overCurrentContext
        
        
        // zgodnosc table view z protokołem
        tableView.dataSource = self
        tableView.delegate = self
        
        // ustawienie dynamicznej wysokosci rzedu w table view
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        // ustawienie self jako delegacji modelu oraz wczytanie pytań
        
        model.delegate = self
        model.getQuestions()
        
    }
    
    func displayQuestion() {
        
        guard questionIndex < questions.count else {
            
            print("trying to display a question index that is out of bounds")
            
            return
        }
        
        // wyswietlenie pytania
        
        questionLabel.text = questions[questionIndex].question!
        
        // wyswietlenie odpowiedzi
        
        tableView.reloadData()
        
        slideInQuestion()
        
    }
    
    func slideInQuestion() {
        
        rootStackView.alpha = 0
        stackViewLeadingConstraint.constant = 1000
        stackViewTrailingConstrain.constant = -1000
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 1.1, delay: 0, options: .curveEaseOut, animations: {
            
            self.rootStackView.alpha = 1
            self.stackViewLeadingConstraint.constant = 0
            self.stackViewTrailingConstrain.constant = 0
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
    }
    
    func slideOutQuestion() {
        
        rootStackView.alpha = 1
        stackViewLeadingConstraint.constant = 0
        stackViewTrailingConstrain.constant = 0
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 1.1, delay: 0, options: .curveEaseIn, animations: {
            
            self.rootStackView.alpha = 0
            self.stackViewLeadingConstraint.constant = -1000
            self.stackViewTrailingConstrain.constant = 1000
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    // MARK: - QuizProtocol methods
    
    func questionsRetrieved(questions: [Question]) {
        
        // ustawienie właściwości questions z tymi od questions z modelu
        
        self.questions = questions
        
        let qIndex = StateManager.retriveValue(key: StateManager.questionIndexKey) as? Int
        
        if qIndex != nil && qIndex! < questions.count {
            
            questionIndex = qIndex!
            
            numCorrect = StateManager.retriveValue(key: StateManager.numCorrectKey) as! Int
            
        }
        
        // wyswietlenie pierwszego pytania
        displayQuestion()
        
    }
    
    // MARK: - TableView Protocol methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard questions.count > 0 && questions[questionIndex].answers != nil else {
            return 0
        }
        
        return questions[questionIndex].answers!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
        
        // stworzenie etykiety
        
        let label = cell.viewWithTag(1) as! UILabel
        
        // tekst w etykiecie
        label.text = questions[questionIndex].answers![indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard questionIndex < questions.count else {
            return
        }
        
        // zdeklarowanie które zmienne/ stałe pokaza sie w alercie
        var title:String = ""
        let message:String = questions[questionIndex].feedback!
        let action:String = "Next"
        
        // gdy użytkownik wybrał odpowiedz
        
        if questions[questionIndex].correctAnswerIndex! == indexPath.row {
            
            // uzytkownik wybrał dobra odpowiedz
            numCorrect += 1
            
            // wiadomosc dla alertu
            title = "Correct!"
        }
        else {
            // wrong answer
            
            // wiadomosc dla alertu
            title = "Wrong!"
        }
        
        slideOutQuestion()
        
        if resultVC != nil {
            
            DispatchQueue.main.async {
                
            
         self.present(self.resultVC!, animated: true, completion: {
                
                // ustawienie wiadomosci dla alertu
                self.resultVC!.setPopup(withTitle: title, withMessage: message, withAction: action)
            })
        }
        }
        // przejscie do nastepnego pytania
        
        questionIndex += 1
        
        StateManager.saveState(numCorrect: numCorrect, questionIndex: questionIndex)
        
    }
    
    // MARK: - ResultViewControlProtocol methods
    
    func resultViewDissmissed() {
        
        // sprwdzenie ile pytan pozostało by zakonczyc quiz
        
        if questionIndex == questions.count {
            
            if resultVC != nil {
                
                present(resultVC!, animated:  true, completion:  {
                    
                    self.resultVC?.setPopup(withTitle: "Summary", withMessage: "You got \(self.numCorrect) out of \(self.questions.count) correct", withAction: "Restart")
                    
                })
                
            }
            
            questionIndex += 1
            
            StateManager.clearState()
            
        }
        else if questionIndex > questions.count {
            
            // reset gry
            numCorrect = 0
            questionIndex = 0
            displayQuestion()
            
        }
        else {
            
            displayQuestion()
            
        }
        
        
        
    }
    
}

