//
//  CheckoutPaymentViewController.swift
//  brightcosmetics
//
//  Created by George FitzGibbons on 6/18/18.
//  Copyright © 2018 George FitzGibbons. All rights reserved.
//

import UIKit
import moltin

class CheckoutPaymentViewController: UIViewController {

    @IBOutlet weak var orderConfirmationLabel: UIButton!
    @IBOutlet weak var applyPromoLabel: UILabel!
    
    @IBOutlet weak var promoTextWraper: UIView!
    @IBOutlet weak var promoTextInput: UITextField!
    @IBOutlet weak var applyButtonLabel: UIButton!
    @IBOutlet weak var applePayButtonLabel: UIButton!
    @IBOutlet weak var creditCardButtonLabel: UIButton!
    @IBOutlet weak var choosePaymentLabel: UILabel!
    @IBOutlet weak var creditCardDetailLabel: UILabel!
    
    @IBOutlet weak var creditCardTextInput: UITextField!
    @IBOutlet weak var ccMMYYTextInput: UITextField!
    @IBOutlet weak var csvTextInput: UITextField!
    
    @IBOutlet weak var applyPayCheckmark: UIImageView!
    @IBOutlet weak var creditCardCheckMark: UIImageView!
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var creditCardInputView: UIView!
    
    
    var customerName: String = "George Fitz"
    var customerEmail: String = "George.fitz@moltin.com"
    var firstName: String = "george"
    var lastName: String = "Fitz"

    override func viewDidLoad() {
        super.viewDidLoad()
        //Fetch codes incase user puts on in
        MoltinManager.instance().getPromotionCodes()
        
        //payment choice
        self.applyPayCheckmark.isHidden = true
        self.creditCardCheckMark.isHidden = false
       
        self.headerView.backgroundColor = Colors.buttonColor()
        applyButtonLabel.layer.cornerRadius = 20
        applyButtonLabel.clipsToBounds = true
        applyButtonLabel.backgroundColor = Colors.buttonColor()
        applyButtonLabel.setTitleColor(UIColor.white, for: .normal)
        
        promoTextWraper.layer.borderWidth = 2.0
        promoTextWraper.layer.borderColor = Colors.buttonOutlineGrey().cgColor
        promoTextWraper.layer.cornerRadius = 20
        promoTextWraper.clipsToBounds = true
        
        orderConfirmationLabel.backgroundColor = Colors.buttonColor()
        orderConfirmationLabel.setTitleColor(UIColor.white, for: .normal)
        orderConfirmationLabel.layer.cornerRadius = 25
        
        creditCardInputView.layer.borderWidth = 2.0
        creditCardInputView.layer.borderColor = Colors.buttonOutlineGrey().cgColor
        creditCardInputView.layer.cornerRadius = 20
        
        applyButtonLabel.layer.cornerRadius = 25
        applyPromoLabel.clipsToBounds = true


        var nameComponents = self.customerName.components(separatedBy: " ")
        //What checks are common
        if(nameComponents.count > 0)
        {
            self.firstName = nameComponents.removeFirst()
            self.lastName = nameComponents.joined(separator: " ")
        }

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func applePayPressed(_ sender: Any) {
        //TODO Apple pay flow
        self.creditCardCheckMark.isHidden = true
        self.creditCardInputView.isHidden = true
        self.csvTextInput.isHidden = true
        self.creditCardDetailLabel.isHidden = true
        self.ccMMYYTextInput.isHidden = true
        
        
        self.applyPayCheckmark.isHidden = false
        //pullup apple pay
    }
    
    @IBAction func creditCardPressed(_ sender: Any) {
        //TODO hide Scroll view
        self.creditCardCheckMark.isHidden = false
        self.applyPayCheckmark.isHidden = true
        
        self.creditCardCheckMark.isHidden = false
        self.creditCardInputView.isHidden = false
        self.csvTextInput.isHidden = false
        self.creditCardDetailLabel.isHidden = false
        self.ccMMYYTextInput.isHidden = false

    }
    
    @IBAction func applyPromoPressed(_ sender: Any) {
        //TODO set up promotions
        let promoGood = MoltinManager.instance().checkPromoCode(promoCode: self.promoTextInput.text ?? "")
        let title = promoGood ? "Discount worked" : "Discount not applied"
        let message = promoGood ? "Continue to the next page to see your updated order and complete the purchase" : "The Promo code did not work"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler:  { (action) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func orderConfirmationPressed(_ sender: Any) {
        let customer = Customer(withEmail: customerEmail, withName: self.customerName)
        let address = Address(withFirstName: self.firstName, withLastName: self.lastName)
        address.line1 = "472"
        address.county = "Suffolk"
        address.country = "Fiction"
        address.postcode = "02124"
        
        //Check out the order
        let order = MoltinManager.instance().checkoutOrder(customer: customer, address: address)

        
        let Storyboard = UIStoryboard.init(name: "CheckoutFlow", bundle: nil)
        let vc = Storyboard.instantiateViewController(withIdentifier:"CheckoutConfirmation") as? CheckoutConfirmationViewController
        vc?.orderId = order
        self.present(vc!, animated: true, completion: nil)
    }
    
}