//
//  ProductDetailViewController.swift
//  brightcosmetics
//
//  Created by George FitzGibbons on 6/18/18.
//  Copyright © 2018 George FitzGibbons. All rights reserved.
//

import UIKit
import moltin

class ProductDetailViewController: UIViewController {
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDetail: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addToBagLabel: UIButton!
    @IBOutlet weak var navBarLogo: UINavigationItem!
    @IBOutlet weak var backArrow: UIBarButtonItem!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    let moltin: Moltin = Moltin(withClientID: "j6hSilXRQfxKohTndUuVrErLcSJWP15P347L6Im0M4", withLocale: Locale(identifier: "en_US"))
    var product: moltin.Product?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "full-logo-iOS"))
        titleImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        titleImageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = titleImageView
        
        navigationController?.navigationBar.barTintColor = Colors.navBar()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
//        let logo = UIImage(named: "logo")
//        let imageView = UIImageView(image:logo)
//        self.navBarLogo.titleView = imageView
        
//        UINavigationBar.appearance().barTintColor = Colors.navBar()

//        self.navBar.backgroundColor? = Colors.navBar()
//        self.navBar.tintColor? = Colors.navBar()
        
        self.mainImage.load(urlString: self.product?.mainImage?.link["href"] ?? "")
        self.productName.text = product?.name
        self.productDetail.text = product?.description
        self.productDetail.textColor = Colors.lightGreyText()
        self.priceLabel.text = product?.meta.displayPrice?.withoutTax.formatted
        
        addToBagLabel.backgroundColor = Colors.buttonColor()
        addToBagLabel.layer.cornerRadius = 25
        addToBagLabel.clipsToBounds = true
        addToBagLabel.setTitleColor(UIColor.white, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBAction func addToBagPressed(_ sender: Any) {
        //Add to cart
        MoltinManager.instance().addItemToCart(cartId: "", productId: product?.id ?? "", qty: 1) { (itemAdded) -> (Void) in
            if itemAdded {
                let storyboard = UIStoryboard(name: "CheckoutFlow", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "CartView") as UIViewController
                self.present(vc, animated: true, completion: nil)
            }
            else
            {
                //throw some error
                
            }
        }
        
    }
    
    @IBAction func goToBagPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CheckoutFlow", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CartView") as UIViewController
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func backArrowPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CatalogView") as UIViewController
        self.present(vc, animated: true, completion: nil)
    }
}
