//
//  FeedbackViewController.swift
//  SquatCheck
//
//  Created by RAGAVAN, Seyoon on 11/11/17.
//  Copyright © 2017 Seyoon Ragavan. All rights reserved.
//

import UIKit
import CoreML

class FeedbackViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var frontStart: UIImage!
    var frontStop: UIImage!
    var start: UIImage!
    var stop: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let model = openposescale()
    let dim = 40
    var n = 0
    var p: MLMultiArray!
    var selectedRow = -1
    
    var initparts = [CGSize]()
    var finalparts = [CGSize]()
    var initpartsfront = [CGSize]()
    var finalpartsfront = [CGSize]()
    
    let errors = ["Knees Outwards", "Shoulders Balanced", "Knees Back", "Depth of Squat", "Back Rounding", "Head Position"]
    var indexArr = [Int]()
    let weights = [1, 1, 1, 1, 1, 1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView.isHidden = true
        // Do any additional setup after loading the view.
        print("loaded")
        imageView.isHidden = true
        
        /*var alert = UIAlertController(title: "Title", message: "Analysing videos", preferredStyle: .alert);
        
        
        var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        self.present(alert, animated: true, completion: nil)*/
        
        if let pixelBuffer = start.pixelBuffer(width: 320, height: 320) {
            
            if let prediction = try? model.prediction(image: pixelBuffer) {
                print(prediction.net_output)
                p = prediction.net_output
                
                for i in 0..<16 {
                    initparts.append(coord(q: p, id: i))
                }
            }
        }
        
        if let pixelBuffer = stop.pixelBuffer(width: 320, height: 320) {
            
            if let prediction = try? model.prediction(image: pixelBuffer) {
                print(prediction.net_output)
                p = prediction.net_output
                
                for i in 0..<16 {
                    finalparts.append(coord(q: p, id: i))
                }
            }
        }
        
        if let pixelBuffer = frontStart.pixelBuffer(width: 320, height: 320) {
            
            if let prediction = try? model.prediction(image: pixelBuffer) {
                print(prediction.net_output)
                p = prediction.net_output
                
                for i in 0..<16 {
                    initpartsfront.append(coord(q: p, id: i))
                }
            }
        }
        
        if let pixelBuffer = frontStop.pixelBuffer(width: 320, height: 320) {
            
            if let prediction = try? model.prediction(image: pixelBuffer) {
                print(prediction.net_output)
                p = prediction.net_output
                
                for i in 0..<16 {
                    finalpartsfront.append(coord(q: p, id: i))
                }
            }
        }
        
        
        
        print("KNEES INWARD")
        print(knees_inward())
        print("SHOULDERS LEVEL")
        print(shoulder_level())
        print("KNEES FORWARD")
        print(knee_forward())
        print("ANKLES FORWARD")
        print(ankle_forward())
        print("SHALLOW SQUAT")
        print(shallow_squat())
        print("ROUNDED BACK")
        print(rounded_back())
        print("HEAD FORWARD")
        print(head_forward())
        
        indexArr = indexErrors()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        
        
        /*if (squatScore() == 3.0) {
            scoreLabel.backgroundColor = UIColor.green
        }
        else {
            scoreLabel.addStraightCG()
        }*/
        
        scoreLabel.backgroundColor = UIColor.green
        
        scoreLabel.text = "Squat Score: " + String(squatScore())
        scoreLabel.layer.borderColor = UIColor.black.cgColor
        
        //alert.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goHome(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToHome", sender: self)
    }
    
    func squatScore() -> Double {
        var total = 0
        var totalweight = 0
        
        for i in 0 ..< indexArr.count {
            total += weights[i] * indexArr[i]
            totalweight += weights[i]
        }
        
        return Double(total)/Double(totalweight)
    }
    
    func indexErrors() -> [Int] {
        return [class1(dist: knees_inward()), class2(dist: shoulder_level()), class3(dist: knee_forward()), class4(slope: shallow_squat()), class5(round: rounded_back()), class6(dist: head_forward())]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indexArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "error", for: indexPath) as! FeedbackTableViewCell
        cell.titleButton.setTitle(errors[indexPath.row], for: [])
        switch indexArr[indexPath.row] {
        case 0:
            cell.titleButton.backgroundColor = UIColor.red
        case 1:
            cell.titleButton.backgroundColor = UIColor.orange
        case 2:
            cell.titleButton.backgroundColor = UIColor.yellow
        default:
            cell.titleButton.backgroundColor = UIColor.green
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        performSegue(withIdentifier: "toDetail", sender: self)
    }
    
    func class1(dist: Int) -> Int {
        switch dist {
        case Int.min ..< -2:
            return 3
        case -2, -1:
            return 2
        case 0:
            return 1
        default:
            return 0
            
        }
    }
    
    func class2(dist: Int) -> Int {
        switch dist {
        case Int.min...0:
            return 3
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func class3(dist: Int) -> Int {
        switch dist {
        case Int.min...3:
            return 3
        case 4:
            return 2
        case 5:
            return 1
        default:
            return 0
        }
    }
    
    func class4(slope: Double) -> Int {
        switch slope {
        case -(Double.infinity) ... 0.5:
            return 3
        case 0.5...1:
            return 2
        case 1...1.5:
            return 1
        default:
            return 0
        }
    }
    
    func class5(round: Double) -> Int {
        switch round {
        case 1...(Double.infinity):
            return 3
        case 0.9...1:
            return 2
        case 0.7...0.9:
            return 1
        default:
            return 0
        }
    }
    
    func class6(dist: Int) -> Int {
        switch dist {
        case -10 ..< 3:
            return 3
        case 3:
            return 2
        case 4:
            return 1
        default:
            return 0
        }
    }

    
    func coord(q: MLMultiArray, id: Int) -> CGSize {
        n = dim * dim * id
        var test: Int!
        var retx = -1
        var rety = -1
        var curmax = 0.0
        for i in (0..<dim) {
            for j in (0..<dim) {
                test = dim*i + j
                if Double(truncating: q[test + n]) > curmax {
                    curmax = Double(truncating: q[test + n])
                    retx = i
                    rety = j
                }
            }
        }
        return CGSize(width: retx, height: rety)
    }
    
    // id of right knee is 9, id of left knee is 12
    func knees_inward() -> Int {
        let init_kneesep: Int = Int(abs(initpartsfront[9].height - initpartsfront[12].height))
        let final_kneesep: Int = Int(abs(finalpartsfront[9].height - finalpartsfront[12].height))
        return init_kneesep - final_kneesep
    }
    
    // 2 is right shoulder, 5 is left shoulder
    func shoulder_level() -> Int {
        return Int(abs(finalpartsfront[2].width - finalpartsfront[5].width))
    }
    
    
    // from the left
    func knee_forward() -> Int {
        return Int(abs(finalparts[12].height - initparts[12].height))
    }
    
    // 10 is right ankle, 13 is left ankle
    func ankle_forward() -> Int {
        return Int(abs(finalparts[13].height - initparts[13].height))
    }
    
    // right hip is 8, left hip is 11, right knee is 9, left knee is 12
    func shallow_squat() -> Double {
        // compute initial slope between
        //    var slope_init:Double = (initparts[].width - initparts[8].width) / Double(initparts[14].height - initparts[8].height)
        let slope_final:Double = Double(finalparts[11].width - finalparts[12].width) / Double(finalparts[11].height - initparts[12].height)
        return abs(slope_final)
    }
    
    // chest is 14, right hip is 8
    func rounded_back() -> Double {
        // compute initial distance between chest and hip
        let init_x: Double = Double(initparts[14].width - initparts[11].width)
        let init_y: Double = Double(initparts[14].height - initparts[11].height)
        let init_dist: Double = init_x * init_x + init_y * init_y
        
        // compute final distance between chest and hip
        let final_x: Double = Double(finalparts[14].width - finalparts[11].width)
        let final_y: Double = Double(finalparts[14].height - finalparts[11].height)
        let final_dist:Double = final_x * final_x + final_y * final_y
        
        return final_dist.squareRoot()/init_dist.squareRoot()
        
    }
    
    func head_forward() -> Int {
        return Int(abs(finalparts[0].height - initparts[0].height))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "toDetail") {
            let dest = segue.destination as! DetailedFeedbackViewController
            dest.id = selectedRow
            switch selectedRow {
            case 0, 1:
                dest.image = frontStop
                dest.parts = finalpartsfront
            default:
                dest.image = stop
                dest.parts = finalparts
            }
            dest.outcome = indexArr[selectedRow]
        }
    }
    

}

extension UILabel {
    func addStraightCG() {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    let rightColour = UIColor.yellow.cgColor
    let leftColour = UIColor.red.cgColor
    gradientLayer.colors = [leftColour, rightColour]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    layer.addSublayer(gradientLayer)
    }
}
