//
//  StateManager.swift
//  Quiz
//
//  Created by Aleksander  on 20/04/2019.
//

import Foundation

class StateManager {
    
    static var questionIndexKey = "QuestionIndexKey"
    static var numCorrectKey = "NumberCorrectKey"
    
    static func saveState(numCorrect:Int, questionIndex:Int) {
        
        let defaults = UserDefaults.standard
        
       defaults.set(questionIndex, forKey: questionIndexKey)
        defaults.set(numCorrect, forKey: numCorrectKey)
        
    }
    
    static func retriveValue(key:String) -> Any? {
        
        let defaults = UserDefaults.standard
        
        return defaults.value(forKey: key)
        
    }
    
    static func clearState() {
        
        let defaults = UserDefaults.standard
        
        defaults.removeObject(forKey: questionIndexKey)
        defaults.removeObject(forKey: numCorrectKey)
    }
    
}
