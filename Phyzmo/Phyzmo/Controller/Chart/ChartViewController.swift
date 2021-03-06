//
//  ChartViewController.swift
//  Phyzmo
//
//  Created by Athena Leong on 11/9/19.
//  Copyright © 2019 Athena. All rights reserved.
//

import UIKit
import SpreadsheetView

class ChartViewController: UIViewController {
    
    var time : [Double]?
    var rawDisplacement : [Double]?
    var rawVelocity : [Double]?
    var rawAcceleration : [Double]?
    var cellWidth : Double?

    @IBOutlet weak var chartSpreadsheetView: SpreadsheetView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.orientation.isLandscape {
            cellWidth = Double(view.frame.height/4)
        }
        else{
            cellWidth = Double(view.frame.width/4)
        }
        
        // Render Spreadsheet
        readVals()
        chartSpreadsheetView.dataSource = self
        chartSpreadsheetView.delegate = self
        let hairline = 1 / UIScreen.main.scale
               chartSpreadsheetView.intercellSpacing = CGSize(width: hairline, height: hairline)
               chartSpreadsheetView.gridStyle = .solid(width: hairline, color: .lightGray)

        chartSpreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        chartSpreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
        
        chartSpreadsheetView.bounces = false
    
       
    }

    
    override func viewDidAppear(_ animated: Bool){
        chartSpreadsheetView.flashScrollIndicators()
        tabBarController!.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(export))
        tabBarController!.navigationItem.title = "Chart"

        
    }

    override func viewWillTransition(to size: CGSize,
                            with coordinator: UIViewControllerTransitionCoordinator){
        print("ORIENTATION: \(UIDevice.current.orientation.isLandscape)")
        coordinator.animate(alongsideTransition: nil) { (context) in
            self.cellWidth = Double(size.width/4)
            if self.chartSpreadsheetView != nil{
                self.chartSpreadsheetView.reloadData()
            }
        }
        
    }
    
    //EXPORT
    @objc func export(sender: UIButton) {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd-HH:mm"
        let fileName = "Phyzmo-\(dateFormatterPrint.string(from: Date.init())).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Time,Displacement,Velocity,Acceleration\n" //FIXME
        for i in 0..<time!.count {
            let newLine = "\(time![i]),\(rawDisplacement![i]),\(rawVelocity![i]),\(rawAcceleration![i])\n" //FIXME
            csvText += newLine
        }
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            
            let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
            vc.excludedActivityTypes = [
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo,
                UIActivity.ActivityType.postToTwitter,
                UIActivity.ActivityType.postToFacebook,
                UIActivity.ActivityType.openInIBooks
            ]
            present(vc, animated: true, completion: nil)
            if let popOver = vc.popoverPresentationController {
              popOver.sourceView = self.view
              //popOver.sourceRect =
              popOver.barButtonItem = tabBarController!.navigationItem.rightBarButtonItem
            }
            
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }
    
    //Update Values
    func readVals(){
        guard let data = (self.tabBarController as! DataViewController).video?.data else{
            return
        }
        time = data["time"]! as! [Double]
        rawDisplacement = data["total_distance"]! as! [Double]
        rawVelocity = data["normalized_velocity"]! as! [Double]
        rawAcceleration = data["normalized_acce"]! as! [Double]
        print("\n\(time)")
        print("\n\(rawDisplacement)")
        print("\n\(rawVelocity)")
        print("\n\(rawAcceleration)")
    }
    
    
}
