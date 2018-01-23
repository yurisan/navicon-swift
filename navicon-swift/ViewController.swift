//
//  ViewController.swift
//  navicon-swift
//
//  Created by Yuria Hiraga on 1/23/18.
//  Copyright © 2018 Yuria Hiraga. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // セッション
    var mySession : AVCaptureSession!
    // カメラデバイス
    var myDevice : AVCaptureDevice!
    // 出力先
    var myOutput : AVCaptureVideoDataOutput!
    
    let detector = Detector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // カメラを準備
        if initCamera() {
            // 撮影開始
            mySession.startRunning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // カメラの準備処理
    func initCamera() -> Bool {
        // セッションの作成.
        mySession = AVCaptureSession()
        
        // 解像度の指定.
        mySession.sessionPreset = AVCaptureSession.Preset.medium
        
        
        // デバイス一覧の取得.
        let devices = AVCaptureDevice.devices()
        
        // バックカメラをmyDeviceに格納.
        for device in devices {
            if(device.position == AVCaptureDevice.Position.back){
                myDevice = device as AVCaptureDevice
            }
        }
        if myDevice == nil {
            return false
        }
        
        // バックカメラからVideoInputを取得.
        do{
            let myInput = try AVCaptureDeviceInput(device: myDevice)
            
            // セッションに追加.
            if mySession.canAddInput(myInput) {
                mySession.addInput(myInput)
            } else {
                return false
            }
        }catch{
            return false
        }
        
        // 出力先を設定
        myOutput = AVCaptureVideoDataOutput()
        myOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String : Int(kCVPixelFormatType_32BGRA)]
        
        // FPSを設定
        do{
            try myDevice.lockForConfiguration()
            myDevice.activeVideoMinFrameDuration = CMTimeMake(1, 15)
            myDevice.unlockForConfiguration()
        }catch{
            return false
        }
        
        // デリゲートを設定
        let queue = DispatchQueue(label: "myqueue")
        myOutput.setSampleBufferDelegate(self, queue: queue)
        
        
        // 遅れてきたフレームは無視する
        myOutput.alwaysDiscardsLateVideoFrames = true
        
        
        // セッションに追加.
        if mySession.canAddOutput(myOutput) {
            mySession.addOutput(myOutput)
        } else {
            return false
        }
        
        // カメラの向きを合わせる
        for connection in myOutput.connections {
            if let conn = connection as? AVCaptureConnection {
                if conn.isVideoOrientationSupported {
                    conn.videoOrientation = AVCaptureVideoOrientation.portrait
                }
            }
        }
        return true
    }
    
    // 毎フレーム実行される処理
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        DispatchQueue.main.async{
            /**
             *  ここでSampleBufferからUIImageを作成し、imageViewへ反映させる
             */
            let image = CameraUtil.imageFromSampleBuffer(sampleBuffer: sampleBuffer)
            
            let faceImage = self.detector?.recognizeFace(image)
            
            // Debug
            let hit = self.detector?.hit()
            print(hit)
            if(hit == 1){
                let storyboard: UIStoryboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "fail") as! FailViewController
                self.present(nextView, animated: true, completion: nil)
            }
            // Debug
            
            self.imageView.image = faceImage
        }
    }
    
    
}

