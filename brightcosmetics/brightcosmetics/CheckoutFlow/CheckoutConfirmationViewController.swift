//
//  CheckoutConfirmationViewController.swift
//  brightcosmetics
//
//  Created by George FitzGibbons on 6/18/18.
//  Copyright © 2018 George FitzGibbons. All rights reserved.
//

import UIKit
import moltin

class CheckoutConfirmationViewController: UIViewController {
    @IBOutlet weak var titleLAbel: UILabel!
    @IBOutlet weak var voucherLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var creditCardInfoLabel: UILabel!
    
    @IBOutlet weak var editLabel: UIButton!
    @IBOutlet weak var yourItemsLabel: UILabel!
    
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var buyNowButtonLabel: UIButton!
    
    //lines
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var midLine: UIView!
    @IBOutlet weak var bottomeLine: UIView!
    
    var cartItems: [moltin.CartItem] = Array()
    var productsInCart: [moltin.Product] = Array()

    
    //need to pass order object here
    var orderId: Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.voucherLabel.isHidden = true
        self.codeLabel.isHidden = true

        self.totalLabel.textColor = Colors.lightGreyText()
        let cart = MoltinManager.instance().getCart(cartId: "")

        self.editLabel.setTitleColor(Colors.buttonColor(), for: .normal)

        self.totalAmount.text = cart.meta?.displayPrice.withTax.formatted
        
       self.voucherLabel.text = orderId?.status
       self.paymentMethodLabel.text = orderId?.payment
        
        buyNowButtonLabel.layer.cornerRadius = 25
        buyNowButtonLabel.backgroundColor = Colors.buttonColor()
        buyNowButtonLabel.setTitleColor(UIColor.white, for: .normal)
        
        tableView.register(UINib(nibName: "ConfirmationTableViewCell", bundle: nil), forCellReuseIdentifier: "ConfirmationCell")
        
        //TODO: return cartItems and products fetch cartItems
        let cartItems = MoltinManager.instance().getCartItems(cartId: "")
        self.cartItems = cartItems
        let productIds = self.cartItems.map({ $0.productId })
        
        for id in productIds {
            let productItem = MoltinManager.instance().getProductById(productId: id)
            self.productsInCart.insert(productItem, at: self.productsInCart.endIndex)
        }
        print("here we be", self.productsInCart)

        self.topLine.layer.addBorder(edge: .top, color: Colors.buttonOutlineGrey(), thickness: 2)
        self.midLine.layer.addBorder(edge: .top, color: Colors.buttonOutlineGrey(), thickness: 2)
        self.bottomeLine.layer.addBorder(edge: .top, color: Colors.buttonOutlineGrey(), thickness: 2)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    
    func hidePromo() {
        self.voucherLabel.isHidden = true
        self.codeLabel.isHidden = true
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        //Navigate back to payment
        let storyboard = UIStoryboard(name: "CheckoutFlow", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CartView") as UIViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func buyNowButtonPressed(_ sender: Any) {
        //Manual Example
        let paymentMethod = ManuallyAuthorizePayment()
        let paymentWorked = MoltinManager.instance().payForOrder(order: self.orderId!, paymentMethod: paymentMethod)
        //if worked reload data
        let title = paymentWorked ? "Your purchase is on the way" : "There was an issue with ytour payment"
        let message = paymentWorked ? "Continue to see your reciept" : "Please try again"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler:  { (action) in
            if (paymentWorked){
                let storyboard = UIStoryboard(name: "CheckoutFlow", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Receipt") as UIViewController
                self.present(vc, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    
    }
}

extension CheckoutConfirmationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmationCell", for: indexPath) as! ConfirmationTableViewCell
        let cartItem = self.cartItems[indexPath.row]
        let cartProduct: Product = self.productsInCart[indexPath.row]
        cell.displayProducts(cartProduct: cartItem, product: cartProduct)

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}
