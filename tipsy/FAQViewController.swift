//
//  FAQViewController.swift
//  tipsy
//
//  Created by Debarshi Chaudhuri on 8/26/15.
//  Copyright (c) 2015 Wavelength. All rights reserved.
//

import Foundation
import Amplitude_iOS

class FAQViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!

    
    
    override func viewDidAppear(animated: Bool) {
        Amplitude.instance().logEvent("faqViewed")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.scrollRangeToVisible(NSMakeRange(0, 1))
        
        let questionOne = "What is Tipsy?\r\n\n"
        
        let answerOne = "Tipsy is a new way for you to engage with your local community.  We believe that the best moments are those that bring people together, and we’ve built Tipsy to help you bring together the people around you.\r\n\nYou can use Tipsy to broadcast your plans to your friends or other members of Tipsy, see what your friends in your area are up to, or check out events made by others around you.\r\n\n"
        
        let questionTwo = "What events show up in the Activity feed?\r\n\n"
        
        let answerTwo = "The Activity feed contains all the awesome public events around you, as well as any plans made by friends near your location.\r\n\n"
        
        let questionThree = "How is the Friend Feed on Tipsy constructed?\r\n\n"
        
        let answerThree = "Tipsy uses your Facebook friends list to put together a calendar of events your friends have planned on Tipsy and shows you the ones that are happening near your location.\r\n\n"
        
        let questionFour = "I’m not seeing one of my friend’s events in Tipsy!  What’s up with that?\r\n\n"
        
        let answerFour = "It’s possible that the event is outside of the location radius Tipsy uses.  If you think there are events you should be seeing that you’re not, holla at us at debarshi@everybodygettipsy.com.\r\n\n"
        
        let questionFive = "I love Tipsy!  How can I help?\r\n\n"
        
        let answerFive = "Thanks!  We love you too!  Spread the good word about Tipsy!  And let us know what we can do to make Tipsy even better by emailing debarshi@everybodygettipsy.com.\r\n\n"
        
        let questionSix = "I hate Tipsy!  How can I let you know how much I hate it?\r\n\n"
        
        let answerSix = "Yikes, sorry about that.  Same as above- feel free to reach out to debarshi@everybodygettipsy.com and let us know what sucks about Tipsy.\r\n\n"

        let boldString = [NSFontAttributeName : UIFont.boldSystemFontOfSize(14)]
        
//        let avenirString = [NSFontAttributeName : UIFont.fontNamesForFamilyName("Avenir")]
        
        let answerOneAttributed = NSMutableAttributedString(string: answerOne)
        
        let answerTwoAttributed = NSMutableAttributedString(string: answerTwo)
        
        let answerThreeAttributed = NSMutableAttributedString(string: answerThree)
        
        let answerFourAttributed = NSMutableAttributedString(string: answerFour)
        
        let answerFiveAttributed = NSMutableAttributedString(string: answerFive)
        
        let answerSixAttributed = NSMutableAttributedString(string: answerSix)
        
        let questionOneBold = NSMutableAttributedString(string: questionOne, attributes: boldString)
        
        let questionTwoBold = NSMutableAttributedString(string: questionTwo, attributes: boldString)
        
        let questionThreeBold = NSMutableAttributedString(string: questionThree, attributes: boldString)
        
        let questionFourBold = NSMutableAttributedString(string: questionFour, attributes: boldString)
        
        let questionFiveBold = NSMutableAttributedString(string: questionFive, attributes: boldString)
        
        let questionSixBold = NSMutableAttributedString(string: questionSix, attributes: boldString)
        
        
        let finalAttributedString = questionOneBold

        let attributedStringArray = [answerOneAttributed, questionTwoBold, answerTwoAttributed, questionThreeBold, answerThreeAttributed, questionFourBold, answerFourAttributed, questionFiveBold, answerFiveAttributed, questionSixBold, answerSixAttributed]
        
        
        for attributedString in attributedStringArray {
            finalAttributedString.appendAttributedString(attributedString)
        }
        
        textView.attributedText = finalAttributedString
        
    }
    
    
    
    
}