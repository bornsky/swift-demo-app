//
//  MoltinManager.swift
//  brightcosmetics
//
//  Created by George FitzGibbons on 6/12/18.
//  Copyright © 2018 George FitzGibbons. All rights reserved.
//

import Foundation
import moltin

class MoltinManager : NSObject {
    let semaphore = DispatchSemaphore(value: 0)
    let moltinAPI = DispatchGroup()
    let defaults = UserDefaults.standard
    
    let moltin: Moltin = Moltin(withClientID: AppDelegate.moltinId)

    var categories: [moltin.Category] = []
    var products: [Product] = []
    var product: Product?
    var cartItems: [CartItem] = Array()
    var cart: Cart?
    

    private static let instanceVar = MoltinManager()

    private override init()
    {
        super.init();
    }
    
    static func instance() -> MoltinManager
    {
        return instanceVar
    }
    
    var promoCodes: [String] = Array()

    
    //Set up to make manual api calls
    var moltinToken: String = ""
    let moltinHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    public func setMoltinToken() {
        //Get token for non-sdk api calls
        let postData = NSMutableData(data: "client_id=\(AppDelegate.moltinId)".data(using: String.Encoding.utf8)!)
        postData.append("&grant_type=implicit".data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.moltin.com/oauth/access_token")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = moltinHeaders
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error ?? "")
            } else {
                let json = try! JSONSerialization.jsonObject(with: data!, options: [])
                if let dictionary = json as? [String: Any] {
                    if let token = dictionary["access_token"] as? String {
                        self.moltinToken = token
                    }
                }
            }
        })
        
        dataTask.resume()
    }

    //Get categories
    public func getCategories() -> [moltin.Category] {
        self.moltin.category.include([.products]).all(completionHandler: { (result: Result<PaginatedResponse<[moltin.Category]>>) in
            self.semaphore.signal()
            switch result {
            case .success(let response):
                self.categories = response.data ?? []
            case .failure(let error):
                print("Get Categories error:", error)
                self.categories = []
            }
        })
        self.semaphore.wait()
        return self.categories
    }
    
    //Get products
    public func getProducts() -> [moltin.Product] {
        self.moltin.product.include([.mainImage, .categories]).all { (result: Result<PaginatedResponse<[moltin.Product]>>) in
            self.semaphore.signal()
            switch result {
            case .success(let response):
                self.products = response.data ?? []
            case .failure(let error):
                print("Get Products error:", error)
                self.products = []
            }
        }
        self.semaphore.wait()
        return self.products
    }
    
    //get product by Id
    public func getProductById(productId: String) -> Product {
        self.moltin.product.include([.mainImage]).get(forID: productId, completionHandler: { (result: Result<Product>) in
            switch result {
            case .success(let product):
                self.product = product
                self.semaphore.signal()
            default: break
            }
        })
        self.semaphore.wait()
        return self.product!
    }
    
    //get product by Filter
    public func getProductByFilter(key: String, value: String) -> [moltin.Product] {
        self.moltin.product.filter(operator: .equal, key: key, value: value).include([.mainImage]).all
            { (result: Result<PaginatedResponse<[moltin.Product]>>) in
                switch result {
                case .success(let response):
                    self.products = response.data ?? []
                case .failure(let error):
                    print("Get Products error:", error)
                    self.products = []
                }
                self.semaphore.signal()
        }
        self.semaphore.wait()
        return self.products
    }
    
    //MARK: CART
    //add item to cart
    public func addItemToCart(cartId: String?, productId: String, qty: Int) -> (Bool){
        var itemAdded = false
        self.moltin.cart.addProduct(withID: productId , ofQuantity: qty, toCart: AppDelegate.cartID, completionHandler: { (_) in
            itemAdded = true
            self.semaphore.signal()
        })
        self.semaphore.wait()
        return itemAdded
    }
    
    //remove item from cart
    public func removeItemFromCart(cartId: String?, productId: String) -> (Bool) {
        var itemRemoved = false
        self.moltin.cart.removeItem(productId, fromCart: AppDelegate.cartID, completionHandler: { (_) in
            self.semaphore.signal()
            itemRemoved = true
        })
        self.semaphore.wait()
        return itemRemoved
    }
    
    //get Cart Items
    public func getCartItems(cartId: String?) -> [moltin.CartItem]{
        self.moltin.cart.include([.products]).items(forCartID: AppDelegate.cartID) { (result) in
            switch result {
            case .success(let result):
                self.cartItems = result.data ?? []
            case .failure(let error):
                print("Cart error:", error)
                self.cartItems = []
            }
            self.semaphore.signal()
        }
        self.semaphore.wait()
        return self.cartItems
    }
    
    //get cart
    public func getCart(cartId: String?) -> moltin.Cart{
        self.moltin.cart.get(forID: AppDelegate.cartID, completionHandler: { (result)
            in
            switch result {
            case .success(let result):
                self.cart = result
            case .failure(let error):
                print("Cart error:", error)
            }
            self.semaphore.signal()
        })
        //TODO: Return products and cartItems
        self.semaphore.wait()
        return self.cart!
    }
    
    //delete cart: Easily remove all items from a cart.
    public func deleteCart(cartId: String?){
        self.moltin.cart.deleteCart(AppDelegate.cartID, completionHandler: { (result)
            in
            switch result {
            case .success(let result):
                print("Cart error:", result)
            case .failure(let error):
                print("Cart error:", error)
            }
            self.semaphore.signal()
        })
        self.semaphore.wait()
    }
    
    
    //Apply promo to cart
    public func applyPromoToCart(promoCode: String) -> Bool {
        var discountApplied: Bool = false

        let headers = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer \(self.moltinToken)",
        ]
        let promo = ["data": [
            "type": "promotion_item",
            "code": promoCode
            ]] as [String : Any]
        var promoData: Data? = nil
        do {
            promoData = try JSONSerialization.data(withJSONObject: promo, options: [])
        } catch {
            print("Error: cannot create JSON from todo")
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.moltin.com/v2/carts/\(AppDelegate.cartID)/items")! as URL,cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = promoData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                discountApplied = true
                print(httpResponse as Any)
            }
        })
        
        dataTask.resume()
   
        return discountApplied
    }
    
    
    //MARK: Customer
    public func createCustomer(userName: String, userEmail: String) {
        let headers = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer \(self.moltinToken)"
        ]
        let user = ["data": [
            "type": "customer",
            "name": userName,
            "email": userEmail,
            "password": "123456"
            ]] as [String : Any]
        
        let userData: Data
            do {
                userData = try JSONSerialization.data(withJSONObject: user, options: [])
                } catch {
                    print("Error: cannot create JSON from todo")
                    return
                }
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.moltin.com/v2/customers")! as URL,cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = userData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
            }
        })
        
        dataTask.resume()
    }
    

    //MARK: Checkout
    public func payForOrder(order: Order, paymentMethod: PaymentMethod) -> Bool {
        var worked: Bool = false
        self.moltin.cart.pay(forOrderID: order.id, withPaymentMethod: paymentMethod) { (result) in
            switch result {
            case .success(let status):
                worked = true
                print("Paid for order: \(status)")
            case .failure(let error):
                worked = true
                print("Could not pay for order: \(error)")
                self.semaphore.signal()
            }
        }
        self.semaphore.wait()
        return worked
    }
    
    public func checkoutOrder(customer: Customer, address: Address) -> Order {
        var orderComplete: Order?
        self.moltin.cart.checkout(cart: AppDelegate.cartID, withCustomer: customer, withBillingAddress: address, withShippingAddress: nil) { (result) in
            switch result {
            case .success(let order):
                orderComplete = order
                self.semaphore.signal()
            default: break
            }
        }
        self.semaphore.wait()
        return orderComplete!
    }
    
    public func payForOrder(orderId: Order, paymentGateway: PaymentMethod) -> Bool  {
        var paymentWorked: Bool = false
        self.moltin.cart.pay(forOrderID: orderId.id, withPaymentMethod: paymentGateway) { (result) in
            switch result {
            case .success:
                paymentWorked = true
            case .failure(let error):
                print("payment error:\(error)")
            }
        }
        return paymentWorked
    }
    
    //MARK: Promotions
    public func getPromotionCodes() {
        let headers = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer \(self.moltinToken)",
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://api.moltin.com/v2/promotions")! as URL,cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error ?? "")
            } else {
                let json = try! JSONSerialization.jsonObject(with: data!, options: [])
                if let dictionary = json as? [String: Any] {
                    if let codes = dictionary["codes"] as? [String] {
                        self.promoCodes = codes
                    }
                    print(self.promoCodes)
                }
            }
        })
        
        dataTask.resume()
    }
    
    
    public func checkPromoCode(promoCode: String) -> Bool {
        //check to see if the promotion code exists
        var promoWorked: Bool = false
        if self.promoCodes.contains("promoCode") {
            //apply to cart
            promoWorked = self.applyPromoToCart(promoCode: promoCode)
        }
        else {
            print("Not a valid promo")
        }
        return promoWorked
    }
}

