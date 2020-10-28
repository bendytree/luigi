//
//  AppDelegate.swift
//  Luigi
//
//  Created by Josh Wright on 10/25/20. MIT License.
//

import UIKit
import CoreMotion
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let motion = CMMotionManager();
    var timer:Timer?;
    var players: [AVAudioPlayer] = []
    var waitUntil:TimeInterval = 0
    var playerIndex:Int = -1

    func playSound() {
        DispatchQueue.main.async {
            let now = Date().timeIntervalSinceReferenceDate
            if (now < self.waitUntil) {
                return;
            }
            self.waitUntil = now + 0.5;
            self.playerIndex += 1
            let player = self.players[self.playerIndex % self.players.count]
            player.play()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            guard let url = Bundle.main.url(forResource: "jump", withExtension: "m4a") else { return false }
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            for _ in (0..<4) {
                let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                player.prepareToPlay()
                self.players.append(player)
            }
        }catch let error {
            NSLog("ERROR: %@", [error .localizedDescription]);
        }
        
        if self.motion.isAccelerometerAvailable {
            self.motion.accelerometerUpdateInterval = 1.0 / 10.0  // 60 Hz
            self.motion.deviceMotionUpdateInterval = 1.0 / 10.0  // 60 Hz
            self.motion.startAccelerometerUpdates()
            self.motion.startDeviceMotionUpdates(to: OperationQueue()) { (m, e) in
                if let deviceMotion = self.motion.deviceMotion {
                    let gravityVector = Vector3(x: CGFloat(deviceMotion.gravity.x),
                                                y: CGFloat(deviceMotion.gravity.y),
                                                z: CGFloat(deviceMotion.gravity.z))

                    let userAccelerationVector = Vector3(x: CGFloat(deviceMotion.userAcceleration.x),
                                                         y: CGFloat(deviceMotion.userAcceleration.y),
                                                         z: CGFloat(deviceMotion.userAcceleration.z))

                    // Acceleration to/from earth
                    let zVector = gravityVector * userAccelerationVector
                    let zAcceleration:CGFloat = zVector.length()
                    if (zAcceleration > 1) {
                        self.playSound()
                    }
                }
            }
       }
        
       return true
    }
}

