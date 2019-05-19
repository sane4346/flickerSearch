//
//  DetailViewController.swift
//  FlickerSearchApp
//
//  Created by santosh chaurasia on 19/05/19.
//  Copyright © 2019 santosh104. All rights reserved.
//

import UIKit


class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // var transitionController = TransitionController()
    
    var photoData : PhotoData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // DispatchQueue.global(qos: .background).async { [weak self] in
        if let photodata = self.photoData {
            self.downloadImageForGiven(photoDta: photodata)
        }
        //}
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        DispatchQueue.main.async {
            self.imageView.image = UIImage(named: "thumb")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    @objc func barBtnClicked(sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    
    func downloadImageForGiven(photoDta: PhotoData) {
 
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
                    self?.imageView.image = imageTo
                }
            }
            
        })
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
