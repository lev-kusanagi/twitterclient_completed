//
//  ViewController.swift
//  twitterclient_start
//
//  Created by Brian Voong on 2/15/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit

struct HomeStatus {
    var text: String?
    var profileImageUrl: String?
    var name: String?
    var screenName: String?
}

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    static let cellId = "cellId"
    
    var homeStatuses: [HomeStatus]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Twitter Home"
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(StatusCell.self, forCellWithReuseIdentifier: ViewController.cellId)
        
        let twitter = STTwitterAPI(oAuthConsumerKey: "DpGzxTKxAzW7jYLNF3pXyCq1R", consumerSecret: "F4i0xKVaQ8rbjnZEoUngzoeRQ5YDR4OBriyOs8XhgdbLcuJJCg", oauthToken: "4912299642-VVtj7EQbXRtGkjN4VKGw8CIdaYbLyJkVgUEJ2kc", oauthTokenSecret: "CUrPjIDUVU9LUU31ONOC1MenJW7ZJdpPkBIRjNkS2dosd")
        
        twitter?.verifyCredentials(userSuccessBlock: { (username, userId) -> Void in
            
            twitter?.getHomeTimeline(sinceID: nil, count: 10, successBlock: { (statuses) -> Void in
                
                self.homeStatuses = [HomeStatus]()
                
                for status in statuses! {
                    let text = status["text"] as? String

                    
                    if let user = status["user"] as? NSDictionary {
                        let profileImage = user["profile_image_url_https"] as? String
                        let screenName = user["screen_name"] as? String
                        let name = user["name"] as? String
                        
                        self.homeStatuses?.append(HomeStatus(text: text, profileImageUrl: profileImage, name: name, screenName: screenName))
                    }
                }
                
                self.collectionView?.reloadData()
                
                }, errorBlock: { (error) -> Void in
                    print(error)
            })
            
            }) { (error) -> Void in
                print(error)
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = homeStatuses?.count {
            return count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let statusCell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewController.cellId, for: indexPath) as! StatusCell
        
        if let homeStatus = self.homeStatuses?[indexPath.item] {
            statusCell.homeStatus = homeStatus
        }
        
        return statusCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let homeStatus = self.homeStatuses?[indexPath.item] {
            if let name = homeStatus.name, let screenName = homeStatus.screenName, let text = homeStatus.text {
                let attributedText = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)])
                
                attributedText.append(NSAttributedString(string: "\n@\(screenName)", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)]))
                
                attributedText.append(NSAttributedString(string: "\n\(text)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
                
                let size = attributedText.boundingRect(with: CGSize(width: view.frame.width - 80, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), context: nil).size
                
                return CGSize(width: view.frame.width, height: size.height + 20)
            }
        }
        
        return CGSize(width: view.frame.width, height: 80)
    }

}

class StatusCell: UICollectionViewCell {
    
    var homeStatus: HomeStatus? {
        didSet {
            if let profileImageUrl = homeStatus?.profileImageUrl {
                
                if let name = homeStatus?.name, let screenName = homeStatus?.screenName, let text = homeStatus?.text {
                    let attributedText = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)])
                    
                    attributedText.append(NSAttributedString(string: "\n@\(screenName)", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)]))
                    
                    attributedText.append(NSAttributedString(string: "\n\(text)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
                    
                    statusTextView.attributedText = attributedText
                }
                
                let url = URL(string: profileImageUrl)
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                    
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    print("loaded image")
                    let image = UIImage(data: data!)
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.profileImageView.image = image
                    })
                    
                }).resume()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let statusTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        return textView
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    func setupViews() {
        addSubview(statusTextView)
        addSubview(dividerView)
        addSubview(profileImageView)
        
        // constraints for statusTextView
        addConstraintsWithFormat("H:|-8-[v0(48)]-8-[v1]|", views: profileImageView, statusTextView)
        
        addConstraintsWithFormat("V:|[v0]|", views: statusTextView)
        
        addConstraintsWithFormat("V:|-8-[v0(48)]", views: profileImageView)
        
        // constraints for dividerView
        addConstraintsWithFormat("H:|-8-[v0]|", views: dividerView)
        addConstraintsWithFormat("V:[v0(1)]|", views: dividerView)
    }
}

extension UIView {
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

