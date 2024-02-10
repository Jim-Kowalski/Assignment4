//
//  ViewController.swift
//  Assignment4
//
//  Created by James Kowalski on 1/28/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var lblTimeRemaining: UILabel!
    @IBOutlet weak var dpTimerDuration: UIDatePicker!
    @IBOutlet weak var btnStartTimer: UIButton!
    @IBOutlet weak var imgBackground: UIImageView!
    
    var mobjCurrentTimeTimer = Timer()
    var mobjStartMusicTimer = Timer()
    var mobjStopMusicTimer = Timer()
    var mintRemainingSeconds : Int = 0;
    var mobjAudioPlayer : AVAudioPlayer?
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCurrentTime()
        // Do any additional setup after loading the view.
        mobjCurrentTimeTimer.invalidate()
        mobjCurrentTimeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
        
        if let audioURL = Bundle.main.url(forResource: "gnossienne1", withExtension: "mp3") {
            do {
                // Create an AVAudioPlayer with the audio URL
                mobjAudioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                
                // Prepare the audio player (optional)
                mobjAudioPlayer?.prepareToPlay()
            } catch {
                print("Error initializing AVAudioPlayer: \(error.localizedDescription)")
            }
        } else {
            print("MP3 audio file not found in bundle.")
        }
    }
    
    //-----------------------------------------------------------------------------
    // This function updates the current time label and chenges the background
    // image based on whether the time is AM or PM.
    //-----------------------------------------------------------------------------
    @objc func updateCurrentTime(){
        
        //Date Formatter to format the date and time to the
        //the assignment requirements
        let objDateFormatter = DateFormatter()
        objDateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
        objDateFormatter.locale = Locale(identifier: "en_US")
        
        //Get the current datetime and format it using the DateFormatter object
        //and assign it to the label.
        let dtNow = Date();
        lblCurrentTime.text = objDateFormatter.string(from: dtNow)
        
        // Repurpose the objDateFormetter object as an AM/PM indicator
        objDateFormatter.dateFormat = "a"
        let ampmIndicator = objDateFormatter.string(from: dtNow)


        //If the indicator is AM display sun.jpg.
        //If PM, display the Moon.jpg
        switch ampmIndicator{
        case "AM":
            if let image = UIImage(named: "sun.jpg") {
                // Set the UIImage to the UIImageView
                imgBackground.image = image
            }
        case "PM":
            if let image = UIImage(named: "Moon.png") {
                // Set the UIImage to the UIImageView
                imgBackground.image = image
            }
        default:
            imgBackground.image = nil
            
        }
    }
    //-----------------------------------------------------------------------------
    //This function handles when to turn off the music. It is after 10 seconds.
    //-----------------------------------------------------------------------------
    @objc func mobjStopMusicTimer_Tick() {
        
        	StopMusic()
            SetUiToStartTimerState()
    }
    //-----------------------------------------------------------------------------
    //The following function handles the mobjMusicTimer timeInterval selector.
    //-----------------------------------------------------------------------------
    @objc func mobjStartMusicTimer_Tick(){
        mintRemainingSeconds -= 1
        if mintRemainingSeconds <= 0
        {
            mintRemainingSeconds = 0
            mobjStartMusicTimer.invalidate() //Shutoff the start music timer
            StartMusic()
            SetUiToStopMusicState()
        }
        updateTimeRemainingLabel(intRemaingSeconds: mintRemainingSeconds)
    }
    //-----------------------------------------------------------------------------
    //This function updates the time remaining label on the UI which counts down
    //how much time is left before the music starts
    //-----------------------------------------------------------------------------
    func updateTimeRemainingLabel(intRemaingSeconds :Int)
    {
        lblTimeRemaining.text = String(format: "Time Remaining: %02d:%02d:%02d", intRemaingSeconds / 3600, (intRemaingSeconds % 3600) / 60, intRemaingSeconds % 60)
        
    }
    //-----------------------------------------------------------------------------
    //This function handles the btnStartTime selector.
    //-----------------------------------------------------------------------------
    @IBAction func btnStartTimerAction(_ sender: UIButton) {
        
        //Switch the text of the button to determine the state of the
        //application. If the button is labeled 'Start Timer', start the
        //countdown to start the music. If labeled 'Stop Music' stop the music and
        //set the interface to the Start Timer state.
        switch btnStartTimer.titleLabel?.text {
        case "Start Timer":
            StartCountdown()
        case "Stop Music":
            StopMusic()
            SetUiToStartTimerState()
        
        default:
            StartCountdown()
        }
    }
    //-----------------------------------------------------------------------------
    //The SetUiToStartTimerState function sets the interface to the start timer
    //state, which sets the button text to the 'Start Timer' and sets the
    //datepicker control enabled.
    //-----------------------------------------------------------------------------
    func SetUiToStartTimerState()
    {
        //Set the datepicker enabled state to true and set the
        //button text.
        dpTimerDuration.isEnabled = true
        btnStartTimer.setTitle("Start Timer", for: .normal)
    }
    //-----------------------------------------------------------------------------
    //The following function sets the btnStartTimer button's text to 'Stop Music'
    //-----------------------------------------------------------------------------
    func SetUiToStopMusicState()
    {
        //-----------------------------------------------------------------------------
        //Change the btnStartTimer button's title text to Stop Music since we started
        //-----------------------------------------------------------------------------
        btnStartTimer.setTitle("Stop Music", for: .normal)
    }
    //-----------------------------------------------------------------------------
    //The following function stops all running timers and stops the audio player
    //that is playing music.
    //-----------------------------------------------------------------------------
    func StopMusic()
    {
        mobjStartMusicTimer.invalidate()
        mobjStopMusicTimer.invalidate()
        mintRemainingSeconds = 0;
        //-----------------------------------------------------------------------------
        //Start the audio player.
        //-----------------------------------------------------------------------------
        if let audioPlayer = mobjAudioPlayer {
            audioPlayer.stop()
        }
    }
    //-----------------------------------------------------------------------------
    //The following function starts playing music using the audioPlayer object. It
    //also starts a timer that eventually stops playing the music.
    //-----------------------------------------------------------------------------
    func StartMusic()
    {
        //-----------------------------------------------------------------------------
        //Start the audio player.
        //-----------------------------------------------------------------------------
        if let audioPlayer = mobjAudioPlayer {
            audioPlayer.currentTime = 0
            audioPlayer.play()
        }
        //-----------------------------------------------------------------------------
        //Start a timer to shut off the music after 10 seconds.
        //-----------------------------------------------------------------------------
        mobjStopMusicTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(mobjStopMusicTimer_Tick), userInfo: nil, repeats: false)
    }
    //-----------------------------------------------------------------------------
    //The following function starts the music countdown timer, which
    //when the time has elapsed (based on the length selected on the date and time
    //picker function, will be
    //-----------------------------------------------------------------------------
    func StartCountdown()
    {
        dpTimerDuration.isEnabled = false
        mobjStartMusicTimer.invalidate()
        mintRemainingSeconds = Int(dpTimerDuration.countDownDuration)
        mobjStartMusicTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(mobjStartMusicTimer_Tick), userInfo: nil, repeats: true)
    }
    
}

