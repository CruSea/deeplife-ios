//
//  Validation.swift
//  DeepLife
//
//

import Foundation

import UIKit

enum ValidationError {
    
    case required, notString, notNumber, tooLong, tooShort
    
    func errorDescription() -> String {
        
        switch self {
            
        case .required:
        
            return "This field is required"
            
        case .notString:
            
            return "This field should be text"
            
        case .notNumber:
            
            return "This field should be a number"
            
        case .tooLong:
            
            return "Your input is too long."
            
        case .tooShort:
            
            return "Your input is too short"
            
            
        }
        
    }
    
}

struct Validation {
    
    var isValid: Bool
    
    var validationError: ValidationError?
    
}

extension UITextField {
    
    func isStringValid() -> Validation {
        
        guard let text = text else { return Validation(isValid: false, validationError: ValidationError.required) }
        
        if text.isEmpty {
            
            return Validation(isValid: false, validationError: ValidationError.required)
            
        }
        
        return Validation(isValid: true, validationError: nil)
        
    }
    
    func isNumberValid() -> Validation {
        
        guard let text = text else { return Validation(isValid: false, validationError: ValidationError.required) }
        
        if text.isEmpty {
            
            return Validation(isValid: false, validationError: ValidationError.required)
            
        }
        
        if Int(text) != nil {
        
            return Validation(isValid: true, validationError: nil)
            
        }
        else {
            
            return Validation(isValid: false, validationError: ValidationError.notNumber)
            
        }
        
    }
    
}

extension UITextView {
    
    func isStringValid() -> Validation {
        
        guard let text = text else { return Validation(isValid: false, validationError: ValidationError.required) }
        
        if text.isEmpty {
            
            return Validation(isValid: false, validationError: ValidationError.required)
            
        }
        
        return Validation(isValid: true, validationError: nil)
        
    }
    
    func isNumberValid() -> Validation {
        
        guard let text = text else { return Validation(isValid: false, validationError: ValidationError.required) }
        
        if text.isEmpty {
            
            return Validation(isValid: false, validationError: ValidationError.required)
            
        }
        
        if Int(text) != nil {
            
            return Validation(isValid: true, validationError: nil)
            
        }
        else {
            
            return Validation(isValid: false, validationError: ValidationError.notNumber)
            
        }
        
    }
    
    
}
