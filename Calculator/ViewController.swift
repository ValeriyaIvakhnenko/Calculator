//
//  ViewController.swift
//  Calculator
//
//  Created by Valeriya Ivachnenko on 03.11.2024.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var resultLabel: UILabel!
    
    @IBOutlet private var acButton: UIButton!
    @IBOutlet private var changeSignButton: UIButton!
    @IBOutlet private var percentButton: UIButton!
    @IBOutlet private var divideButton: UIButton!
    
    @IBOutlet private var sevenButton: UIButton!
    @IBOutlet private var eightButton: UIButton!
    @IBOutlet private var nineButton: UIButton!
    @IBOutlet private var multiplyButton: UIButton!
    
    @IBOutlet private var fourButton: UIButton!
    @IBOutlet private var fiveButton: UIButton!
    @IBOutlet private var sixButton: UIButton!
    @IBOutlet private var minusButton: UIButton!
    
    @IBOutlet private var oneButton: UIButton!
    @IBOutlet private var twoButton: UIButton!
    @IBOutlet private var threeButton: UIButton!
    @IBOutlet private var plusButton: UIButton!
    
    @IBOutlet private var zeroButton: UIButton!
    @IBOutlet private var commaButton: UIButton!
    @IBOutlet private var equalButton: UIButton!
    
    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSize = 3
        numberFormatter.secondaryGroupingSize = 2
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 10
        numberFormatter.decimalSeparator = ","
        numberFormatter.groupingSeparator = " "
        
        return numberFormatter
    }()
    
    private var operation: CalcOperation? {
        didSet {
            highlightOperationButtonIfNeeded()
            
            let currentOperation = operation
            calculateResult()
            operation = currentOperation
        }
    }
    
    private var firstValue: Double? {
        didSet {
            showCalculationResult()
        }
    }
    
    private var secondValue: Double? {
        didSet {
            showCalculationResult()
        }
    }
    
    private var useComma: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        acButton.layer.cornerRadius = acButton.frame.height / 2
        
        setupButtons([
            acButton,
            changeSignButton,
            percentButton,
            divideButton,
            sevenButton,
            eightButton,
            nineButton,
            multiplyButton,
            fourButton,
            fiveButton,
            sixButton,
            minusButton,
            oneButton,
            twoButton,
            threeButton,
            plusButton,
            zeroButton,
            commaButton,
            equalButton,
        ])
    }
    
    private func highlightOperationButtonIfNeeded() {
        func removeHighlight() {
            divideButton.backgroundColor = .orange
            divideButton.tintColor = .white
            multiplyButton.backgroundColor = .orange
            multiplyButton.tintColor = .white
            minusButton.backgroundColor = .orange
            minusButton.tintColor = .white
            plusButton.backgroundColor = .orange
            plusButton.tintColor = .white
        }
        
        if secondValue == nil {
            switch operation {
            case .divide:
                divideButton.backgroundColor = .white
                divideButton.tintColor = .orange
            case .multiply:
                multiplyButton.backgroundColor = .white
                multiplyButton.tintColor = .orange
            case .minus:
                minusButton.backgroundColor = .white
                minusButton.tintColor = .orange
            case .plus:
                plusButton.backgroundColor = .white
                plusButton.tintColor = .orange
            case nil:
                removeHighlight()
            }
        } else {
            removeHighlight()
        }
    }
    
    private func setCurrentValue(_ button: UIButton) {
        let nextNumber: Double = switch button {
        case zeroButton: 0
        case oneButton: 1
        case twoButton: 2
        case threeButton: 3
        case fourButton: 4
        case fiveButton: 5
        case sixButton: 6
        case sevenButton: 7
        case eightButton: 8
        case nineButton: 9
        default:
            fatalError("Unexpected number button tapped")
        }
        
        guard let newNumber = numberFormatter
            .string(from: NSNumber(floatLiteral: nextNumber))?.removeWhitespaces() else { return }
        
        if useComma {
            if let firstValue, operation == nil {
                self.firstValue = firstValue + (nextNumber / 10)
            } else if let secondValue {
                self.secondValue = secondValue + (nextNumber / 10)
            }
            
            useComma = false
        } else {
            if operation == nil {
                if let firstValue,
                   let firstNumber = numberFormatter
                       .string(from: NSNumber(floatLiteral: firstValue))?.removeWhitespaces() {
                    self.firstValue = Double("\(firstNumber)\(newNumber)") ?? 0
                } else {
                    self.firstValue = Double("\(newNumber)") ?? 0
                }
            } else {
                if let secondValue,
                   let secondNumber = numberFormatter
                       .string(from: NSNumber(floatLiteral: secondValue))?.removeWhitespaces() {
                    self.secondValue = Double("\(secondNumber)\(newNumber)") ?? 0
                } else {
                    self.secondValue = Double("\(newNumber)") ?? 0
                }
                
                highlightOperationButtonIfNeeded()
            }
        }
    }
    
    @objc private func onCalculatorButtonTapped(button: UIButton) {
        switch button {
        case zeroButton,
            oneButton,
            twoButton,
            threeButton,
            fourButton,
            fiveButton,
            sixButton,
            sevenButton,
            eightButton,
            nineButton:
            setCurrentValue(button)

        case acButton:
            if acButton.title(for: .normal) == "AC" {
               operation = nil
                firstValue = nil
                secondValue = nil
            } else {
                if operation == nil {
                    firstValue = nil
                } else {
                    secondValue = nil
                }
            }
        case changeSignButton:
            if let firstValue, operation == nil {
                self.firstValue = firstValue * -1
            } else if let secondValue {
                self.secondValue = secondValue * -1
            }
        case percentButton:
            if let firstValue, operation == nil {
                self.firstValue = firstValue / 100
            } else if let secondValue {
                self.secondValue = secondValue / 100
            }
        case divideButton:
            operation = .divide
        case multiplyButton:
            operation = .multiply
        case minusButton:
            operation = .minus
        case plusButton:
            operation = .plus
        case commaButton:
            let currentValue = operation == nil ? firstValue : secondValue
                
            let alreadyHasComma = currentValue == nil || currentValue?.rounded() != currentValue
            
            guard !alreadyHasComma else { return }
            
            useComma = true
            
            if let resultLabelText = resultLabel.text {
                resultLabel.text = resultLabelText + ","
            }
        case equalButton:
            calculateResult()
        default:
            break
        }
    }
    
    private func calculateResult() {
        guard let firstValue, let secondValue, let operation else { return }
        
        self.firstValue = switch operation {
        case .divide:
            firstValue / secondValue
        case .multiply:
            firstValue * secondValue
        case .minus:
            firstValue - secondValue
        case .plus:
            firstValue + secondValue
        }
     
        self.secondValue = nil
        self.operation = nil
    }
    
    private func showCalculationResult() {
        if firstValue == nil && secondValue == nil {
            resultLabel.text = "0"
        }
        
        if let firstValue, secondValue == nil {
            resultLabel.text = numberFormatter
                .string(from: NSNumber(floatLiteral: firstValue))
        } else if let secondValue {
            resultLabel.text = numberFormatter
                .string(from: NSNumber(floatLiteral: secondValue))
        }
        
        acButton.setTitle(resultLabel.text == "0" ? "AC" : "C", for: .normal)
    }
    
    private func setupButtons(_ buttons: [UIButton]) {
        buttons.forEach { button in
            button.layer.cornerRadius = button.frame.height / 2
            button.addTarget(
                self,
                action: #selector(onCalculatorButtonTapped(button:)),
                for: .touchUpInside
            )
        }
    }
}

enum CalcOperation {
    case divide
    case multiply
    case minus
    case plus
}

private extension String {
    func removeWhitespaces() -> String {
        self.filter { !$0.isWhitespace }
    }
}
