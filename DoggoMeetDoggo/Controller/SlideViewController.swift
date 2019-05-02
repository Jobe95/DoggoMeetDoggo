//
//  SlideViewController.swift
//  DoggoMeetDoggo
//
//  Created by Jonatan Bengtsson on 2019-04-10.
//  Copyright © 2019 Jonatan Bengtsson. All rights reserved.
//

import UIKit

class SlideViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var pageControll: UIPageControl!
    
    var slides = [SlideView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Information om appen"
        scrollView.delegate = self
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        continueButton.isHidden = true
        continueButton.isEnabled = false
        
        pageControll.numberOfPages = slides.count
        pageControll.currentPage = 0
        pageControll.currentPageIndicatorTintColor = UIColor.white
        view.bringSubviewToFront(pageControll)
    }
    
    func createSlides () -> [SlideView] {
        let slide1:SlideView = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! SlideView
        slide1.imageView.image = UIImage(named: "lerone-pieters-1395409-unsplash")
        slide1.titleLabel.text = "Det hundarna gillar"
        slide1.infoTextlabel.text = "Hundägare älskar sina hundar, så varför inte ge dem det de förtjänar? Dax att catcha upp och gå tillsammans med era hundar så de får leka och ha kul tillsammans."
        slide1.backgroundColor = UIColor.lightGray
        
        let slide2:SlideView = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! SlideView
        slide2.imageView.image = UIImage(named: "lerone-pieters-1395409-unsplash")
        slide2.titleLabel.text = "Ta möjligheten"
        slide2.infoTextlabel.text = "Medans hundarna får mer glädje i vardagen så får vi möjlighet att lära känna nya personer som kan komma att bli riktigt bra vänner, varför inte ta den möjligheten?"
        slide2.backgroundColor = UIColor.yellow
        
        let slide3:SlideView = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! SlideView
        slide3.imageView.image = UIImage(named: "lerone-pieters-1395409-unsplash")
        slide3.titleLabel.text = "Det stora hela"
        slide3.infoTextlabel.text = "Vi lär känna nya personer, kanske till och med riktigt bra vänner samtidigt som hundarna får nya riktigt bra vänner, catcha upp tillsammans och ge platsinformationen så ni kan mötas och ha en riktigt bra promenad med era kära hundar och nyblivna vänner"
        slide3.backgroundColor = UIColor.green
        
        return [slide1, slide2, slide3]
    }
    
    func setupSlideScrollView(slides : [SlideView]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControll.currentPage = Int(pageIndex)
        if pageIndex == CGFloat(2) {
            continueButton.isEnabled = true
            continueButton.isHidden = false
        } else {
            continueButton.isEnabled = false
            continueButton.isHidden = true
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
    }
    

}
