//
//  QuizModel.swift
//  Quiz
//
//  Created by Aleksander  on 17/04/2019.
//

import Foundation

protocol QuizProtocol {
    
    func questionsRetrieved(questions:[Question])
    
    
}



class QuizModel {
    
    var delegate:QuizProtocol?
    
    func getQuestions() {
        
        
        
        // otrzymywanie danych z JSON
        
        getRemoteJsonFile()
    }
    
    // pierwotna funkcja pobierajaca dane z pliku JSON lokalnie, skonstruowana by zobaczyc czy kod zadziała
    
    func getLocalJsonFile() {
        
        // utworzenie połaczenia z plikiem JSON
        let path = Bundle.main.path(forResource: "QuestionData", ofType: ".json")
        
        
        guard path != nil else {
            
            print("Can't find the json file")
            
            return
        }
        
        // tworze objekt URL z tego połączenia
        
        let url = URL(fileURLWithPath: path!)
        
        do {
            // otrzymuje dane z tego URL
            
            let data = try Data(contentsOf: url)
            
            // odkodowanie danych z json
            let decoder = JSONDecoder()
            let array = try decoder.decode([Question].self, from: data)
            
            // zwrócenie pytań do view controler
            delegate?.questionsRetrieved(questions: array)
            
        }
        catch {
            
            print("Couldn't create Data object from file")
            
        }
        
    }
    
    // docelowa funkcja pobierajaca plik json z zewnatrz
    
    func getRemoteJsonFile() {
        
        // uzycie objektu URL
        
        let stringUrl = "https://api.myjson.com/bins/qv7vw"
        
        let url = URL(string: stringUrl)
        
        guard url != nil else {
            
            print("couldn't get a URL object")
            return
        }
        
        let session = URLSession.shared
        
        
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            
            if error == nil && data != nil {
                
                let decoder = JSONDecoder()
                
                do {
                    
                    let array = try decoder.decode([Question].self, from: data!)
                    
                    DispatchQueue.main.async {
                        
                        self.delegate?.questionsRetrieved(questions: array)
                        
                    }
                    
                }
                catch {
                    
                    print("Couldn't parse the json")
                    
                }
            }
        }
        
        dataTask.resume()
        
    }
}
