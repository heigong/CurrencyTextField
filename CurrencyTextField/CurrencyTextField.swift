//
//  CurrencyTextField.swift
//  CurrencyTextFieldDemo
//
//  Created by Deshmukh,Richa on 6/2/16.
//  Copyright © 2016 Richa. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable public class CurrencyTextField : UITextField{
    
    private let maxDigits = 12
    
    private var defaultValue: Double = 0.00
    
    private let currencyFormattor = NumberFormatter()
    
    private var previousValue : String = ""
    
    open var amount: NSNumber? {
        
        let cleanNumericString : String = getCleanNumberString()
        let textFieldNumber = Double(cleanNumericString) ?? 0
        
        return NSNumber(value: textFieldNumber)
    }
    
    // MARK: - init functions
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initTextField()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTextField()
    }
    
    func initTextField(){
        self.keyboardType = UIKeyboardType.decimalPad
        currencyFormattor.numberStyle = .currency
        currencyFormattor.minimumFractionDigits = 2
        currencyFormattor.maximumFractionDigits = 2
        setAmount(amount: defaultValue)
    }
    
    // MARK: - UITextField Notifications
    
    override public func willMove(toSuperview newSuperview: UIView!) {
        if newSuperview != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(CurrencyTextField.textDidChange(notification:)), name:NSNotification.Name.UITextFieldTextDidChange, object: self)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    func textDidChange(notification: NSNotification){
        
        //Get the original position of the cursor
        let cursorOffset = getOriginalCursorPosition();
        
        let cleanNumericString : String = getCleanNumberString()
        let textFieldLength = self.text?.characters.count
       
        if cleanNumericString.characters.count > maxDigits{
            self.text = previousValue
        }
        else{
            let textFieldNumber = Double(cleanNumericString)
            if let textFieldNumber = textFieldNumber{
                let textFieldNewValue = textFieldNumber/100
                setAmount(amount: textFieldNewValue)
            }else{
                self.text = previousValue
            }
        }
        //Set the cursor back to its original poistion
        setCursorOriginalPosition(cursorOffset: cursorOffset, oldTextFieldLength: textFieldLength)
    }
    
    //MARK: - Custom text field functions
    
    open func setAmount (amount : Double){
        let textFieldStringValue = currencyFormattor.string(from: NSNumber(value: amount))
        self.text = textFieldStringValue
        if let textFieldStringValue = textFieldStringValue{
            previousValue = textFieldStringValue
        }
    }
    
    //MARK - helper functions
    
    private func getCleanNumberString() -> String {
        var cleanNumericString: String = ""
        let textFieldString = self.text
        if let textFieldString = textFieldString{
            
            //Remove $ sign
            var toArray = textFieldString.components(separatedBy: "$")
            cleanNumericString = toArray.joined(separator: "")
            
            //Remove periods, commas
            toArray = cleanNumericString.components(separatedBy: NSCharacterSet.punctuationCharacters)
            cleanNumericString = toArray.joined(separator: "")
        }
        
        return cleanNumericString
    }
    
    private func getOriginalCursorPosition() -> Int{
        
        var cursorOffset : Int = 0
        let startPosition : UITextPosition = self.beginningOfDocument
        if let selectedTextRange = self.selectedTextRange{
            cursorOffset = self.offset(from: startPosition, to: selectedTextRange.start)
        }
        return cursorOffset
    }
    
    private func setCursorOriginalPosition(cursorOffset: Int, oldTextFieldLength : Int?){
        
        let newLength = self.text?.characters.count
        let startPosition : UITextPosition = self.beginningOfDocument
        if let oldTextFieldLength = oldTextFieldLength, let newLength = newLength, oldTextFieldLength > cursorOffset{
            let newOffset = newLength - oldTextFieldLength + cursorOffset
            let newCursorPosition = self.position(from: startPosition, offset: newOffset)
            if let newCursorPosition = newCursorPosition{
                let newSelectedRange = self.textRange(from:newCursorPosition, to: newCursorPosition)
                self.selectedTextRange = newSelectedRange
            }
            
        }
    }

    
    
    
}
