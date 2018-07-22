//
//  CatalogViewController.swift
//  brightcosmetics
//
//  Created by George FitzGibbons on 6/12/18.
//  Copyright © 2018 George FitzGibbons. All rights reserved.
//

import Foundation
import UIKit
import moltin

class CatalogViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionCatalogView: UICollectionView!
    @IBOutlet weak var navBar: UINavigationBar!
//    @IBOutlet weak var navBarTitle: UINavigationItem!
//    @IBOutlet weak var categoyNameLabel: UILabel!
    
    @IBOutlet weak var viewAllLabel3: UIButton!
    @IBOutlet weak var viewAllLabel2: UIButton!
    @IBOutlet weak var viewAll1Label: UIButton!
    @IBOutlet weak var cat3Label: UILabel!
    @IBOutlet weak var cat2Label: UILabel!
    @IBOutlet weak var cat1Label: UILabel!
    @IBOutlet weak var collectionCatalogThreeView: UICollectionView!
    @IBOutlet weak var collectionCatalogTwoView: UICollectionView!
    
    var product: [moltin.Product] = []
    var bodySkincareProducts: [moltin.Product] = []
    var hairProducts: [moltin.Product] = []
    var facialProducts: [moltin.Product] = []

    var categories: [moltin.Category] = []
//    var navigationBarAppearace = UINavigationBar.appearance()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        customNavigationBar()

        // Do any additional setup after loading the view, typically from a nib.
        MoltinManager.instance().getProducts { (products) -> (Void) in
            self.product = products
            
            for products in self.product  {
                if  (products.categories![0].name == "Body Skincare") {
                    self.bodySkincareProducts.append(products)
                }
                else if (products.categories![0].name == "Haircare") {
                    self.hairProducts.append(products)
                }
                else if (products.categories![0].name == "Facial Skincare") {
                    self.facialProducts.append(products)
                }
            }
            self.collectionCatalogView.reloadData()
            self.collectionCatalogTwoView.reloadData()
            self.collectionCatalogThreeView.reloadData()
    }
        //get all cat
        MoltinManager.instance().getCategories { (categories) -> (Void) in
            self.categories = categories
        }
    }
    
    func customNavigationBar() {
        
        // Presents a custom native NavigationBar
        navigationController?.navigationBar.barTintColor = Colors.navBar()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        navigationItem.title = "Catalog"

        //Cart Button
//        let cartButton = UIButton(type: .system)
//        cartButton.setImage(UIImage(named: "shoppingbag"), for: .normal)
//        cartButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "shoppingbag"), style: .done, target: nil, action: #selector(sendUserToCart))
        
//        UINavigationBar.appearance().barTintColor = Colors.navBar()
//        self.navigationController?.setNavigationBarHidden(false, animated: true)

//        self.viewAll1Label.setTitleColor(Colors.navBar(), for: .normal)
//        self.viewAllLabel2.setTitleColor(Colors.navBar(), for: .normal)
//        self.viewAllLabel3.setTitleColor(Colors.navBar(), for: .normal)
    }
    
    @objc func sendUserToCart() {
        print("send user to cart")
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bodySkincareProducts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionCatalogView {
            self.cat1Label.text = "Body Skincare"
            let cell1 = collectionCatalogView.dequeueReusableCell(withReuseIdentifier: "collectionCatalogViewCell", for: indexPath)
                as! CollectionCatalogViewCell
            cell1.displayCatalogProducts(image: self.bodySkincareProducts[indexPath.row].mainImage?.link["href"] ?? "", title: self.bodySkincareProducts[indexPath.row].name, price: self.bodySkincareProducts[indexPath.row].meta.displayPrice?.withTax.formatted ?? "")
            return cell1
        }
        else if collectionView == self.collectionCatalogThreeView {
            self.cat2Label.text = "Haircare"
            let cell2 = collectionCatalogView.dequeueReusableCell(withReuseIdentifier: "collectionCatalogViewCell", for: indexPath)
                as! CollectionCatalogViewCell
            cell2.displayCatalogProducts(image: self.hairProducts[indexPath.row].mainImage?.link["href"] ?? "", title: self.hairProducts[indexPath.row].name, price: self.hairProducts[indexPath.row].meta.displayPrice?.withTax.formatted ?? "")
            return cell2
        }
        else {
            self.cat3Label.text = "Facial Skincare"
        let cell3 = collectionCatalogTwoView.dequeueReusableCell(withReuseIdentifier: "collectionCatalogViewCell", for: indexPath)
            as! CollectionCatalogViewCell
        cell3.displayCatalogProducts(image: self.facialProducts[indexPath.row].mainImage?.link["href"] ?? "", title: self.facialProducts[indexPath.row].name, price: self.facialProducts[indexPath.row].meta.displayPrice?.withTax.formatted ?? "")
            return cell3
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //go to product Detail
        if collectionView == self.collectionCatalogView {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetail") as? ProductDetailViewController
            vc?.product =  self.bodySkincareProducts[indexPath.row]
            self.present(vc!, animated: true, completion: nil)
        }
        else if collectionView == self.collectionCatalogThreeView {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetail") as? ProductDetailViewController
            vc?.product =  self.hairProducts[indexPath.row]
            self.present(vc!, animated: true, completion: nil)
        }
        else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetail") as? ProductDetailViewController
            vc?.product =  self.facialProducts[indexPath.row]
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
    @IBAction func viewAll1Pressed(_ sender: Any) {
        let Storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let listController = Storyboard.instantiateViewController(withIdentifier:"ProductList") as? ProductListViewController
        listController?.productList = self.bodySkincareProducts
        
        self.present(listController!, animated: true, completion: nil)
    }
    @IBAction func viewAll2Pressed(_ sender: Any) {
        let Storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let listController = Storyboard.instantiateViewController(withIdentifier:"ProductList") as? ProductListViewController
        listController?.productList = self.hairProducts
        self.present(listController!, animated: true,completion: nil)
    }
    @IBAction func viewAll3Pressed(_ sender: Any) {
        let Storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let listController = Storyboard.instantiateViewController(withIdentifier:"ProductList") as? ProductListViewController
        listController?.productList = self.facialProducts
        self.present(listController!, animated: true,completion: nil)
    }
    
     // MARK: - Navigation
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ProductList" {
//            let segue = segue.destination as! ProductListViewController
//        }
//     }
    
}
