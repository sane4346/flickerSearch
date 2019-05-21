//
//  DetailViewController.swift
//  FlickerSearchApp
//
//  Created by santosh chaurasia on 19/05/19.
//  Copyright © 2019 santosh104. All rights reserved.
//

import UIKit


protocol PhotoPageContainerViewControllerDelegate: class {
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int)
}


class PhotoPageContainerViewController: UIViewController {
    
    weak var delegate: PhotoPageContainerViewControllerDelegate?
    
    var pageViewController: UIPageViewController {
        return self.children[0] as! UIPageViewController
    }
    
    var currentViewController: PhotoZoomViewController {
        return self.pageViewController.viewControllers![0] as! PhotoZoomViewController
    }
    
    var photos: UIImage!    
    var transitionController = TransitionController()
    
    var photoData : PhotoData?
    var vc : PhotoZoomViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photodata = self.photoData {
            self.downloadImageForGiven(photoDta: photodata)
        }
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        
        vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoZoomViewController") as? PhotoZoomViewController
        vc?.delegate = self as? PhotoZoomViewControllerDelegate
        if let photo = photos {
            vc?.image = photo
        }
        let viewControllers = [vc]
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func downloadImageForGiven(photoDta: PhotoData) {
        
        let id = photoDta.id
        let farm = String(photoDta.farm)
        let secret = photoDta.secret
        let server = photoDta.server
        
        let urlString = flickerApi.getFLickerImagePathFor(farm: farm, server: server, id: id, secret: secret).path
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url, completionHandler :{ [weak self ] (data , response ,error) in
            guard let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
                let data = data else { return }
            DispatchQueue.main.async {
                if let imageTo = UIImage(data: data) {
                    self?.photos = imageTo
                    self?.vc?.image = imageTo
                    self?.vc?.imageView.image = imageTo
                }
            }
            
        }).resume()
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}





extension PhotoPageContainerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        return nil
        
    }
}
extension PhotoPageContainerViewController: AnimatorDelegate {
    
    func referenceImageView(for Animator: Animator) -> UIImageView? {
        return self.currentViewController.imageView
    }
    
    func referenceImageViewFrameInTransitioningView(for Animator: Animator) -> CGRect? {
        return self.currentViewController.scrollView.convert(self.currentViewController.imageView.frame, to: self.currentViewController.view)
        
    }
}
