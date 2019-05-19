//
//  ViewController.swift
//  FlickerSearchApp
//
//  Created by santosh chaurasia on 17/05/19.
//  Copyright © 2019 santosh104. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
 
    //MARK :- Local variables
    var pageNo = 1
    var searchField: UITextField?
    var collectionChangeBtn : UIButton?
    var oldString = ""
    var displayConstant: CGFloat = 3
    var selectedIndexPath : IndexPath!
    
    var viewModel : FlickerSearchViewModel?
    {
        didSet {
            if viewModel != nil {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSearchField()
        searchField?.delegate = self
        searchField?.becomeFirstResponder()
        collectionView.register(UINib(nibName: "FlickerCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "collectionViewCell")
        collectionView.keyboardDismissMode = .interactive
        viewModel = FlickerSearchViewModel()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.searchField?.isHidden = false
        self.collectionChangeBtn?.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.searchField?.isHidden = true
        self.collectionChangeBtn?.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func addSearchField()
    {
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 10, y: 0, width: navigationBar.frame.width/2, height: navigationBar.frame.height)
            let secondFrame = CGRect(x: navigationBar.frame.width/2 + 20 , y: 0, width: navigationBar.frame.width/2 - 30, height: navigationBar.frame.height)

            searchField = UITextField(frame: firstFrame)
            searchField?.backgroundColor = .lightGray
            searchField?.tintColor = .blue
            searchField?.placeholder = "Search Images"
            searchField?.autocorrectionType = .no
            collectionChangeBtn = UIButton(frame: secondFrame)
            collectionChangeBtn?.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
            collectionChangeBtn?.backgroundColor = .brown
            collectionChangeBtn?.setTitle("Change View", for: .normal)
            if let field = searchField {
                navigationBar.addSubview(field)
            }
            if let btn = collectionChangeBtn {
                navigationBar.addSubview(btn)
            }
        }
    }
    @objc func btnClicked(sender : UIButton!)
    {
        if displayConstant == 5 {
            displayConstant = 3
        } else {
            displayConstant += 1
        }
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    func loadDataForCollectionView(text: String?) {


        if let searchText = text , searchText.count > 0 {
            if oldString != searchText {
                viewModel?.photosData.removeAll()
                viewModel?.setItemCount(items: 0)
                self.collectionView.reloadData()
            }
            oldString = searchText
            let activityIndicator = UIActivityIndicatorView(style: .gray)
            collectionView.addSubview(activityIndicator)
            activityIndicator.frame = collectionView.bounds
            activityIndicator.startAnimating()
            DispatchQueue.global(qos: .background).async {
                self.viewModel?.getJSONForImagesData(searchtext: searchText,pageNo: self.pageNo, complete: { [weak self] status in
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                        if status {
                            self?.collectionView.reloadData()
                        }
                        else {
                            let alert = UIAlertController(title: "Error", message: "Network or server error occured", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                            self?.present(alert, animated: false, completion: nil)
                        }
                    }
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailPhotoSegue" {
            let vc = segue.destination as? DetailViewController
            vc?.photoData = viewModel?.photoDataAt(indexPath: self.selectedIndexPath)
        }
    }
    
}

//MARK :- TextFieldDelegate
extension ViewController : UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchField?.resignFirstResponder()
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.loadDataForCollectionView(text: searchField?.text)
        searchField?.resignFirstResponder()
        return true
    }
    
    
}

extension ViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.photosCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! FlickerCollectionViewCell
        cell.layer.borderColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.5, 0.5, 0.5, 1.0])
         cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 3
        

        if let photo  = viewModel?.photoDataAt(indexPath: indexPath)
        {
            cell.configure(photoData:photo)
        } else {
            cell.flickerCellImage.image = UIImage(named: "thumb")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "DetailPhotoSegue", sender: self)
    }
    
    // Check if the current page to scrolled is within limit
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let photosCount = viewModel?.photosData.count,
            let maxPages = viewModel?.totalPages else{
            return
        }
        if(indexPath.row == photosCount-1){
            if (pageNo<maxPages), let text = searchField?.text{
                pageNo = pageNo + 1
                loadDataForCollectionView(text: text)
            }
            
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let wh = self.view.frame.width / displayConstant
        return CGSize(width: wh, height: wh)
        
    }
}





