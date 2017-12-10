//
//  ViewController.swift
//  SquatCheck
//
//  Created by RAGAVAN, Seyoon on 10/11/17.
//  Copyright © 2017 Seyoon Ragavan. All rights reserved.
//

import UIKit
import Speech

@available(iOS 11.0, *)
class ViewController: UIViewController, FrameExtractorDelegate {
    
    var frameExtractor: FrameExtractor!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var startStop: UIButton!
    var recording = false
    /*var n = 0
    var m: MLMultiArray!
    var p: MLMultiArray!*/
    var prevStart: UIImage!
    var prevStop: UIImage!
    var start: UIImage!
    var stop: UIImage!
    var middle: UIImage!
    var frames = [UIImage]()
    var frameCount = 0
    var isSide = false
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var mostRecentlyProcessedSegmentDuration: TimeInterval = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // imageView.image = UIImage(named: "test")
        // testing Caffe ML model
        /*guard let poseOutput = try? model.prediction(image: buffer(image: resizeImage(image: UIImage(named: "test")!, targetSize: CGSize(width: 100, height: 100)))!)
            else {
            fatalError("Unexpected runtime error.")
        }
        
        print(poseOutput)
        print(poseOutput.Mconv7_stage6_L1.count)
        print(poseOutput.Mconv7_stage6_L2.count)
        // Mconv7_stage6_L1
        var curmax = -10.0
        for x in 0...4731 {
            if ((poseOutput.Mconv7_stage6_L1[x] as! Double) > curmax) {
                curmax = poseOutput.Mconv7_stage6_L1[x] as! Double
            }
        }
        print(curmax)
        curmax = -10.0
        for x in 0...2703 {
            if ((poseOutput.Mconv7_stage6_L2[x] as! Double) > curmax) {
                curmax = poseOutput.Mconv7_stage6_L2[x] as! Double
            }
        }
        print(curmax)*/
        
        // testing OpenPose ML model
        
        /*guard let poseOutput = try? model.prediction(image: buffer(image: resizeImage(image: UIImage(named: "test")!, targetSize: CGSize(width: 100, height: 100)))!) else {
            print("conversion failure")
            return
        }*/
        // YEAH BOY
        /*let image = UIImage(named: "side")
        
        if let pixelBuffer = image?.pixelBuffer(width: 320, height: 320) {
            
            if let prediction = try? model.prediction(image: pixelBuffer) {
                print(prediction.net_output)
                p = prediction.net_output
                
                m = try! MLMultiArray(shape:[40,40], dataType: .double)
                
                for i in 0..<m.count {
                    m[i] = p[i+n]
                }
                imageView.image = m.image(offset: 0, scale: 255)
            }
        }*/
        //imageView.image = m.image(offset: 0, scale: 255)
        
        // testing CoreImage face tracking
        
        /*guard let ciImage = CIImage(image: UIImage(named: "face")!) else {
            print("conversion failure")
            return
        }
        
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyLow]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: ciImage)
        
        for face in faces as! [CIFaceFeature] {
            print("Found bounds are \(face.bounds)")
        }*/
        
        // Do any additional setup after loading the view, typically from a nib.
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
        startStop.backgroundColor = UIColor.red
        startStop.layer.cornerRadius = startStop.bounds.height/2
        startStop.layer.borderColor = UIColor.white.cgColor
        
        // init speech recognition stuff
        
        SFSpeechRecognizer.requestAuthorization {
            [unowned self] (authStatus) in
            switch authStatus {
            case .authorized:
                print("success!")
                do {
                    try self.startRecording()
                } catch let error {
                    print("There was a problem starting recording: \(error.localizedDescription)")
                }
            case .denied:
                print("Speech recognition authorization denied")
            case .restricted:
                print("Not available on this device")
            case .notDetermined:
                print("Not determined")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startStopRecording(_ sender: Any) {
        toggleRecording()
        
        /*n += m.count
        print(n/m.count)
        
        for i in 0..<m.count {
            m[i] = p[i+n]
        }
        imageView.image = m.image(offset: 0, scale: 255)*/
    }
    
    func toggleRecording() {
        if (!recording) {
            recording = true
            startStop.layer.cornerRadius = 0
            startStop.backgroundColor = UIColor.black
            startStop.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
            
            start = imageView.image
            print("STARTING")
        }
        else {
            recording = false
            
            startStop.backgroundColor = UIColor.red
            startStop.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
            startStop.layer.cornerRadius = 30
            frameExtractor.stopRunning()
            stopRecording()
            
            stop = frames[frameCount/2]
            print("STOPPING")
            if (isSide) {
                performSegue(withIdentifier: "toFeedback", sender: self)
            }
            else {
                performSegue(withIdentifier: "toSide", sender: self)
            }
        }
    }
    
    func captured(image: UIImage) {
        print("called")
        imageView.image = image
        if (recording) {
            frames.append(image)
            frameCount += 1
            // evaluate(image: image)
        }
    }
    
    /* func evaluate(image: UIImage) {
        print("evaluated")
    } */
    
    func buffer(image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    /*func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }*/
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: targetSize.width, height: targetSize.height), true, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    /*public func preprocess(image: UIImage, width: Int, height: Int) -> MLMultiArray? {
        let size = CGSize(width: width, height: height)
        
        
        guard let pixels = resizeImage(image: image, targetSize: size).pixelData()?.map({ (Double($0) / 255.0) }) else {
            return nil
        }
        
        guard let array = try? MLMultiArray(shape: [3, height, width] as [NSNumber], dataType: .double) else {
            return nil
        }
        
        let r = pixels.enumerated().filter { $0.offset % 4 == 0 }.map { $0.element }
        let g = pixels.enumerated().filter { $0.offset % 4 == 1 }.map { $0.element }
        let b = pixels.enumerated().filter { $0.offset % 4 == 2 }.map { $0.element }
        
        let combination = r + g + b
        for (index, element) in combination.enumerated() {
            array[index] = NSNumber(value: element)
        }
        
        return array
     }*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toFeedback") {
            let destination = segue.destination as! FeedbackViewController
            destination.frontStart = self.prevStart
            destination.frontStop = self.prevStop
            destination.start = self.start
            destination.stop = self.stop
        }
        else {
            let destination = segue.destination as! ViewController
            destination.prevStart = self.start
            destination.prevStop = self.stop
            destination.isSide = true
        }
    }
}

extension ViewController {
    fileprivate func startRecording() throws {
        mostRecentlyProcessedSegmentDuration = 0
        
        // 1
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        // 2
        node.installTap(onBus: 0, bufferSize: 1024,
                        format: recordingFormat) { [unowned self]
                            (buffer, _) in
                            self.request.append(buffer)
        }
        
        // 3
        audioEngine.prepare()
        try audioEngine.start()
        recognitionTask = speechRecognizer?.recognitionTask(with: request) {
            [unowned self]
            (result, _) in
            if let transcription = result?.bestTranscription {
                self.processTranscription(transcription)
            }
        }
    }
    
    fileprivate func stopRecording() {
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
    }
}

extension ViewController {
    // 1
    fileprivate func processTranscription(_ transcription: SFTranscription) {
        print(transcription.formattedString)
        // alternative: not case sensitive
        if transcription.formattedString.lowercased().range(of:"start") != nil {
            if (!recording) {
                toggleRecording()
            }
        }
        
        if transcription.formattedString.lowercased().range(of:"stop") != nil {
            if (recording) {
                toggleRecording()
            }
        }
        
        // 2
        if let lastSegment = transcription.segments.last,
            lastSegment.duration > mostRecentlyProcessedSegmentDuration {
            mostRecentlyProcessedSegmentDuration = lastSegment.duration
            // 3
        }
    }
}

