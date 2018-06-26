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
    @IBOutlet weak var navBarTitle: UINavigationItem!
    @IBOutlet weak var categoyNameLabel: UILabel!
    
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
    var navigationBarAppearace = UINavigationBar.appearance()


    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().barTintColor = Colors.navBar()
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]

        self.navBarTitle.title = "Catalogue"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.viewAll1Label.setTitleColor(Colors.navBar(), for: .normal)
        self.viewAllLabel2.setTitleColor(Colors.navBar(), for: .normal)
        self.viewAllLabel3.setTitleColor(Colors.navBar(), for: .normal)

        // Do any additional setup after loading the view, typically from a nib.
        self.product = MoltinManager.instance().getProducts()
        //get all cat
        self.categories = MoltinManager.instance().getCategories()

        for products in self.product  {
            if  (products.categories![0].name == "Body Skincare") {
                bodySkincareProducts.append(products)
            }
            else if (products.categories![0].name == "Haircare") {
                hairProducts.append(products)
            }
            else if (products.categories![0].name == "Facial Skincare") {
                facialProducts.append(products)
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
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
    
}
