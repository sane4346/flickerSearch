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
    
    private func addSearchField()
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
            let nav = self.navigationController
            let vc = segue.destination as? PhotoPageContainerViewController
            vc?.photoData = viewModel?.photoDataAt(indexPath: self.selectedIndexPath)
            nav?.delegate = vc?.transitionController
            vc?.transitionController.fromDelegate = self
            vc?.transitionController.toDelegate = vc ?? nil
            vc?.delegate = self
            vc?.photos = getImageViewFromCollectionViewCell(for: selectedIndexPath).image
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as? FlickerCollectionViewCell
        cell?.layer.borderColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.5, 0.5, 0.5, 1.0])
        cell?.layer.borderWidth = 0.5
        cell?.layer.cornerRadius = 3
        
        
        if let photo  = viewModel?.photoDataAt(indexPath: indexPath)
        {
            cell?.configure(photoData:photo)
        } else {
            cell?.flickerCellImage.image = UIImage(named: "thumb")
        }
        if let cell1 = cell{
            return cell1
        } else {
            return UICollectionViewCell()
        }
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
    
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        
        
        let visibleCells = self.collectionView.indexPathsForVisibleItems
        
        if !visibleCells.contains(self.selectedIndexPath) {
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            self.collectionView.layoutIfNeeded()
            
            
            guard let cell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? FlickerCollectionViewCell) else {
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return cell.flickerCellImage
        }
        else {
            
            guard let cell = self.collectionView.cellForItem(at: self.selectedIndexPath) as? FlickerCollectionViewCell else {
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            return cell.flickerCellImage
        }
        
    }
    
    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
        
        let visibleCells = self.collectionView.indexPathsForVisibleItems
        if !visibleCells.contains(self.selectedIndexPath) {
            
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            self.collectionView.layoutIfNeeded()
            
            //Prevent the collectionView from returning a nil value
            guard let cell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? FlickerCollectionViewCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            
            return cell.frame
        }
        else {
            //Prevent the collectionView from returning a nil value
            guard let cell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? FlickerCollectionViewCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            return cell.frame
        }
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.frame.width
        return CGSize(width: collectionViewWidth/displayConstant, height: collectionViewWidth/displayConstant)
    }
    
}




extension ViewController: PhotoPageContainerViewControllerDelegate {
    
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int) {
        self.selectedIndexPath = IndexPath(row: currentIndex, section: 0)
        self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
    }
}

extension ViewController: AnimatorDelegate {
    
    func referenceImageView(for Animator: Animator) -> UIImageView? {
        
        //Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: self.selectedIndexPath)
        
        return referenceImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for Animator: Animator) -> CGRect? {
        
        //Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: self.selectedIndexPath)
        
        let cellFrame = self.collectionView.convert(unconvertedFrame, to: self.view)
        
        if cellFrame.minY < self.collectionView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: self.collectionView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (self.collectionView.contentInset.top - cellFrame.minY))
        }
        
        return cellFrame
    }
    
}






