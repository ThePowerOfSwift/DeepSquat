//
//  DetailedFeedbackViewController.swift
//  SquatCheck
//
//  Created by RAGAVAN, Seyoon on 11/11/17.
//  Copyright © 2017 Seyoon Ragavan. All rights reserved.
//

import UIKit

class DetailedFeedbackViewController: UIViewController {
    
    var id = -1
    var outcome = -1
    var image: UIImage!
    var parts = [CGSize]()
    var width = CGFloat(0.0)
    var height = CGFloat(0.0)
    var dotColour: UIColor!
    
    let captions = [["You’re doing great, keep it up!", "You’re doing great, keep it up!", "You’re doing great, keep it up!", "You’re doing great, keep it up!", "You’re doing great, keep it up!", "You’re doing great, keep it up!"], ["Pushing your knees inward is risky and can lead to knee joint damage. In order to overcome this problem, do hip abduction exercises, or train with bands around the knees.", "Not keeping your shoulders level means one shoulder takes more of the weight, creating a dangerous situation. You should be able to avoid this by simply being conscious of your shoulders.", "Moving your knees too far forward is a common but important issue, putting strain on the knees and lower joints. Make sure to keep your knees in line with your toes.", "Not squatting deep enough isn’t bad for you, but it doesn’t give you the full value of the exercise. Make sure that your butt and knees are approximately parallel.", "Back rounding is dangerous and can put a lot of strain on your back. Stretch out your hamstrings and glutes before squatting and keep your back straight.", "Moving your head forward means your weight shifts forward, and you put strain on your back. Keep your head in the same vertical plane. "]]
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var frontView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        switch outcome {
        case 3:
            dotColour = UIColor.green
        case 2:
            dotColour = UIColor.yellow
        case 1:
            dotColour = UIColor.orange
        default:
            dotColour = UIColor.red
        }
        backView.image = image
        if outcome == 3 {
            captionLabel.text = captions[0][id]
        }
        else {
            captionLabel.text = captions[1][id]
        }
        width = frontView.bounds.width
        height = frontView.bounds.height
        for i in relevantIndices() {
            draw(x: parts[i].height, y: parts[i].width)
        }
    }
    
    func relevantIndices() -> [Int] {
        switch id {
        case 0:
            return [9, 12]
        case 1:
            return [2, 5]
        case 2:
            return [12]
        case 3:
            return [11, 12]
        case 4:
            return [11, 14]
        default:
            return [0]
        }
    }
    
    func draw(x: CGFloat, y: CGFloat) {
        var offsetx: CGFloat
        var offsety: CGFloat
        if id == 5 {
            offsetx = 0
            offsety = 0
        }
        else {
            offsetx = 25
            offsety = 50
        }
        let newx = width/CGFloat(40) * x
        let newy = height/CGFloat(40) * y
        let dotView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        dotView.center = CGPoint(x: newx - offsetx, y: newy - offsety)
        dotView.layer.cornerRadius = 10
        dotView.backgroundColor = dotColour
        frontView.addSubview(dotView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
