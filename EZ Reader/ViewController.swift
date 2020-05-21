//
//  ViewController.swift
//  EZ Reader
//
//  Created by Sean Yang on 4/21/18.
//  Copyright © 2018 Sean Yang. All rights reserved.
//

import UIKit
import AVFoundation
//import Reductio

class ViewController: UIViewController, UITextFieldDelegate {
    

    
    @IBOutlet weak var TextField: UITextField!
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var OutputField: UITextView!
    
    @IBOutlet weak var ResumeButton: UIButton!
    @IBOutlet weak var PauseButton: UIButton!
    @IBOutlet weak var XButton: UIButton!
    
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)
    private var permissionGranted = false
    
    
    //private var myString: [String] = []
    private var myString = [String]()
    
    var synth = AVSpeechSynthesizer()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        self.TextField.delegate = (self as! UITextFieldDelegate);
        
        /*
        if let path = Bundle.main.path(forResource: "stopword", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                
                myString = data.components(separatedBy: .newlines)
                
                //TextView.text = myStrings.joined(separator: ", ")
            } catch {
                print(error)
            }
        }
        **/
        
        if let url = Bundle.main.url(forResource:"stopword", withExtension: "txt") {
            do {
                let data = try Data(contentsOf:url)
                let attibutedString = try NSAttributedString(data: data, documentAttributes: nil)
                let fullText = attibutedString.string
                myString = fullText.components(separatedBy: CharacterSet.newlines)
            } catch {
                print(error)
            }
        }
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func Play(_ sender: Any) {
        if ((TextField.text?.count)! < 2) {
            
        } else {
            //PlayButton.isEnabled = false
        
            let input = TextField.text
        
            //var paragraphArray = input?.components(separatedBy: CharacterSet.newlines)
        
            /**
            for i in 0...paragraphArray!.count {
                var str = paragraphArray![0].components(separatedBy: ".")
            }
             */
        
            var sentenceArray = input?.components(separatedBy:".")
        
            //var counterArray = [sentenceArray!.count]
            var counterArray = [Int](0...sentenceArray!.count)
        
            for i in 0...sentenceArray!.count - 1 {
                var wordArray = sentenceArray![i].components(separatedBy:" ")
                counterArray[i] = 0
                if wordArray.count > 18 {
                    counterArray[i] = -5
                }
                for j in 0...wordArray.count - 1 {
                    
                    let tagger = NSLinguisticTagger(tagSchemes: [.lexicalClass], options: 0)
                    tagger.string = wordArray[j]
                    let range = NSRange(location: 0, length: wordArray[j].utf16.count)
                    let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
                    tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange, _ in
                        if let tag = tag {
                            //let word = (wordArray[j] as NSString).substring(with: tokenRange)
                            //print("\(word): \(tag)")
                            if tag.rawValue == "Adjective" {
                                wordArray[j] = ""
                                //var indexRemov = j
                            }
                            if tag.rawValue == "Adverb" {
                                wordArray[j] = ""
                                //var indexRemov = j
                            }
                        }
                    }
                    
                    
                    for k in 0...myString.count - 1 {
                        if wordArray[j] == myString[k] {
                            counterArray[i] += 1
                        }
                        
                        let decimalCharacters = CharacterSet.decimalDigits
                        let decimalRange = wordArray[j].rangeOfCharacter(from: decimalCharacters)
                        if decimalRange != nil {
                            counterArray[i] -= 9999
                        }
                        
                        /*
                        if let fontUsage = wordArray[j].font.fontDescriptor.fontAttributes["NSCTFontUIUsageAttribute"] as? String {
                            if fontUsage == "CTFontHeavyUsage" {
                                counterArray[i] -= 999
                            }
                            else if fontUsage == "CTFontBlackUsage" {
                                //print("It's Black")
                            }
                        }
                        **/
                        
                    }
                }
                sentenceArray![i] = ""
                for k in 0...wordArray.count - 1 {
                    sentenceArray![i] += wordArray[k] + " "
                }
            }
        
            var outputArray = [String]()
            //var outputArray = [counterArray.count]
        
            for i in 0...counterArray.count - 1 {
                if counterArray[i] > 4 {
                    
                } else {
                    //outputArray[i] = sentenceArray![i]
                    outputArray.append(sentenceArray![i] + ",   ")
                }
            }
        
            var string = ""
            //var stringoutput = ""
            for i in 0...outputArray.count - 1{
                string += outputArray[i]
            }
        
            /*
            Reductio.summarize(text: string, compression: 0.80) { phrases in
                phrases
            }
            **/
        
            /*
            for i in 0...phrases.count {
                stringoutput += phrasesArray[i]
            }
            **/
        
            OutputField.text = string
        
            //let string = sentenceArray![0]
        
        
            let utterance = AVSpeechUtterance(string: string)
            utterance.rate = 0.55
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        
            synth.speak(utterance)
        
            sleep(2)
            //PlayButton.isEnabled = true
        }
    }
    
    @IBAction func ResumeAudio(_ sender: Any) {
        synth.continueSpeaking()
    }
    
    @IBAction func PauseAudio(_ sender: Any) {
        synth.pauseSpeaking(at: AVSpeechBoundary.immediate)
    }
    
    @IBAction func CancelAudio(_ sender: Any) {
        synth.stopSpeaking(at: AVSpeechBoundary.immediate)
        TextField.text = ""
        OutputField.text = ""
    }
    
    @IBAction func changedText(_ sender: Any) {
        //let value: String? = TextField.text
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

