//
//  PhotoZoomViewController.swift
//  FlickerSearchApp
//
//  Created by santosh chaurasia on 20/05/19.
//  Copyright © 2019 santosh104. All rights reserved.
//

import UIKit



protocol PhotoZoomViewControllerDelegate: class {
    func photoZoomViewController(_ photoZoomViewController: PhotoZoomViewController, scrollViewDidScroll scrollView: UIScrollView)
}

class PhotoZoomViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: PhotoZoomViewControllerDelegate?
    var image: UIImage! = UIImage(named: "thumb")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.imageView.image = self.image
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension PhotoZoomViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}


