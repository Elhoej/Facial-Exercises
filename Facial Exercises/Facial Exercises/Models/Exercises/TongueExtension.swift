//
//  TongueExtension.swift
//  Facial Exercises
//
//  Created by Samantha Gatt on 1/3/19.
//  Copyright © 2019 Vuk Radosavljevic. All rights reserved.
//

import ARKit

class TongueExtension: FacialExercise {
    
    static var displayedTitle: String {
        return "Tongue Extensions"
    }
    static var displayedDescription: String {
        return "Stick your tongue out for 2 seconds. Complete 5 repetitions."
    }
    
    var expressionsWithThresholds: [ARFaceAnchor.BlendShapeLocation : SuccessThreshold] = [.tongueOut : 1.0]
    
    func calculateProgress(currentCoefficients: [ARFaceAnchor.BlendShapeLocation : ExerciseSession.Coefficient]) -> Float {
        
        if let expression = expressionsWithThresholds.first?.key,
            let threshold = expressionsWithThresholds.first?.value,
            let currentCoefficient = currentCoefficients[expression] {
            
            if currentCoefficient.floatValue >= threshold.floatValue {
                return 1.0
            } else {
                return currentCoefficient.floatValue / threshold.floatValue
            }
        } else {
            return 0.0
        }
    }
    
    func calculateSuccess(currentCoefficients: [ARFaceAnchor.BlendShapeLocation : ExerciseSession.Coefficient]) -> Bool {
        return calculateProgress(currentCoefficients: currentCoefficients) == 1 ? true : false
    }
}
