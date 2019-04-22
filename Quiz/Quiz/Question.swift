//
//  Question.swift
//  Quiz
//
//  Created by Aleksander  on 16/04/2019.
//

import Foundation

struct  Question: Codable{
    
    var question:String?
    var answers:[String]?
    var correctAnswerIndex:Int?
    var feedback:String?
    
    
}
