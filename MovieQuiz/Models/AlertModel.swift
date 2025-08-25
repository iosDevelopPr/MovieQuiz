//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Igor on 22.08.2025.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> Void
}
