//
//  AnnotationHandler.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 25.07.14.
//
//

import AVFoundation
import AVKit
import CoreMedia
import MobileCoreServices
import UIKit

protocol AnnotationDataSource: class {
    func dictionaryEntity() -> NSObject?
    func dictionaryAggregation() -> String?
    func numberOfAnnotation() -> Int
    func numberOfAnnotationGroup() -> Int
    func numberOfAnnotation(byGroup group: Int) -> Int
    func numberOfAnnotation(byGroupName groupName: String?) -> Int
    func annotationGroupName(_ group: Int) -> String?
    func annotationGroupIndex(byUUID uuid: String?) -> IndexPath?
    func annotation(byGroup group: Int, index: Int) -> Annotation?
    func annotation(byUUID uuid: String?) -> Annotation?
    func addAnnotation(_ parameters: [AnyHashable : Any]?) -> Annotation?
    func insert(_ annotation: Annotation?)
    func update(_ annotation: Annotation?, parameters: [AnyHashable : Any]?)
    func removeAnnotation(byUUID uuid: String?)
    func remove(_ annotation: Annotation?)
    func sortAnnotation()
}

protocol AnnotationHandlerDelegate: NSObjectProtocol {
    func didAddAnnotation(_ data: Data?, thumbnail: Data?, length: CGFloat, sender: Any?)
    func didUpdateAnnotation(_ data: Data?, thumbnail: Data?, length: CGFloat, sender: Any?)
    func didFinish()
}

class AnnotationHandler: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVAudioPlayerDelegate, TextAnnotationViewControllerDelegate, PhotoAnnotationViewControllerDelegate, ImageAnnotationViewControllerDelegate {
    private(set) var annotationType: Int = 0
    weak var presenter: UIViewController?
    weak var delegate: AnnotationHandlerDelegate?
    weak var dataSource: (NSObject & AnnotationDataSource)?
    weak var imageDataSource: (NSObject & ImageAnnotationDataSource)?
    var editing = false

    convenience init(annotationType type: Int, presenter: UIViewController?) {
        self.init()
        annotationType = type
        self.presenter = presenter
    }

    func create(_ crop: Bool) {
        var viewController: UIViewController?
        if annotationType == 0 {
            viewController = writeText()
        } else if annotationType == 1 {
            viewController = takePhoto(crop)
        } else if annotationType == 2 {
            viewController = drawImage()
        } else if annotationType == 3 {
            viewController = recordAudio()
        } else if annotationType == 4 {
            viewController = recordVideo()
        }
        show(viewController, annotation: nil, presenter: presenter)
    }

    func choose(_ crop: Bool) {
        var viewController: UIViewController?
        if annotationType == 0 {
            return
        } else if annotationType == 1 {
            viewController = choosePhoto(crop)
        } else if annotationType == 2 {
            return
        } else if annotationType == 3 {
            return
        } else if annotationType == 4 {
            viewController = chooseVideo()
        }
        show(viewController, annotation: nil, presenter: presenter)
    }

    func display(_ annotation: Annotation?) {
        var viewController: UIViewController?
        if annotationType == 0 {
            viewController = displayText(annotation?.text())
        } else if annotationType == 1 {
            viewController = display(annotation?.image())
        } else if annotationType == 2 {
            viewController = display(annotation?.image())
        } else if annotationType == 3 {
            viewController = playAudio(annotation?.data())
        } else if annotationType == 4 {
            viewController = playVideo(annotation?.data())
        }
        show(viewController, annotation: annotation, presenter: presenter)
    }

    func present(_ annotation: Annotation?, presenter: UIViewController?) -> UIViewController? {
        var viewController: UIViewController?
        if annotation?.type == 0 {
            viewController = displayText(annotation?.text())?.embedInNavigationController()
        } else if annotation?.type == 1 {
            viewController = display(annotation?.image())?.embedInNavigationController()
        } else if annotation?.type == 2 {
            viewController = display(annotation?.image())?.embedInNavigationController()
        } else if annotation?.type == 3 {
            viewController = playAudio(annotation?.data())
        } else if annotation?.type == 4 {
            viewController = playVideo(annotation?.data())
        }
        if viewController != nil {
            show(viewController, annotation: annotation, presenter: presenter)
        }
        return viewController
    }

    private var imagePicker: UIImagePickerController?
    private var videoPicker: UIImagePickerController?
    private var alert: UIAlertController?
    private var startTime: Date?
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    private var audioRecorder: AVAudioRecorder?
    private var filePath = ""

    var navigationController: UINavigationController? {
        return presenter?.navigationController
    }

    func show(_ viewController: UIViewController?, annotation: Annotation?, presenter: UIViewController?) {
        if viewController != nil {
            if annotation != nil {
                var annotationViewController: UIViewController? = viewController
                if (viewController is UINavigationController) {
                    annotationViewController = (viewController as? UINavigationController)?.topViewController
                    annotationViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close".localized, style: .plain, target: presenter, action: nil)
                    annotationViewController?.navigationItem.rightBarButtonItems = nil
                }
                if (annotation?.subTitle()?.count ?? 0) > 0 {
                    let title = "\(annotation?.title() ?? "")\n\(annotation?.subTitle() ?? "")"
                    let label = UILabel.createTwoLineTitleLabel(title, color: UIColor.black)
                    annotationViewController?.navigationItem.titleView = label
                } else {
                    annotationViewController?.title = annotation?.title()
                }
            }
            if (viewController is UINavigationController) || (viewController is UIImagePickerController) || (viewController is UIAlertController) || presenter?.navigationController == nil {
                if presenter?.navigationController != nil {
                } else {
                }
            } else if (viewController is AVPlayerViewController) {
                ((viewController as? AVPlayerViewController)?.player)?.play()
            } else {
                if let viewController = viewController {
                    presenter?.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        }
    }

    func writeText() -> TextAnnotationViewController? {
        let textAnnotation = TextAnnotationViewController()
        textAnnotation.delegate = self
        textAnnotation.isEditing = true
        textAnnotation.dataSource = dataSource
        return textAnnotation
    }

    func displayText(_ text: String?) -> TextAnnotationViewController? {
        let textAnnotation = TextAnnotationViewController(text: text ?? "")
        textAnnotation.delegate = self
        textAnnotation.isEditing = editing
        textAnnotation.dataSource = dataSource
        textAnnotation.title = "View Text".localized
        return textAnnotation
    }

    func didFinishWritingText(_ text: String?, updated: Bool) {
        let data: Data? = text?.data(using: .utf8)
        if !updated {
            delegate?.didAddAnnotation(data, thumbnail: nil, length: CGFloat((text?.count ?? 0)), sender: self)
        } else {
            delegate?.didUpdateAnnotation(data, thumbnail: nil, length: CGFloat((text?.count ?? 0)), sender: self)
        }
        navigationController?.popViewController(animated: true)
        delegate?.didFinish()
    }

    func takePhoto(_ crop: Bool) -> UIImagePickerController? {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.sourceType = .camera
        imagePicker?.mediaTypes = [kUTTypeImage as String]
        imagePicker?.allowsEditing = crop
        return imagePicker
    }

    func choosePhoto(_ crop: Bool) -> UIImagePickerController? {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.sourceType = .photoLibrary
        imagePicker?.mediaTypes = [kUTTypeImage as String]
        imagePicker?.allowsEditing = crop
        return imagePicker
    }

    func recordAudio() -> UIAlertController? {
        alert = Common.showConfirmation(nil, title: "Record Audio".localized, message: "Tap record to start".localized, okButtonTitle: "Record".localized, destructive: false, cancelButtonTitle: nil, okHandler: {
            self.alert = Common.showMessage(self.presenter, title: "Recording...".localized, message: Utilities.formatSeconds(0), okButtonTitle: "Stop".localized, okHandler: {
                let length: Int = self.stopRecording()
                let data = NSData(contentsOfFile: self.filePath) as Data?
                self.delegate?.didAddAnnotation(data, thumbnail: nil, length: CGFloat(length), sender: self)
                self.timer?.invalidate()
                self.timer = nil
                self.startTime = nil
                self.alert = nil
            })
            self.filePath = URL(fileURLWithPath: "folder").appendingPathComponent("audio.aac").absoluteString
            _ = self.startRecording(kAudioFormatMPEG4AAC, filePath: self.filePath)
            self.startTime = Date()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AnnotationHandler.updateTime), userInfo: nil, repeats: true)

        }, cancelHandler: {
            self.alert = nil
        })
        return alert
    }

    @objc func updateTime() {
        var seconds: Int? = nil
        if let startTime = startTime {
            seconds = Int(Date().timeIntervalSince(startTime))
        }
        alert?.message = Utilities.formatSeconds(seconds ?? 0)
    }

    func startRecording(_ format: AudioFormatID, filePath: String?) -> Bool {
        audioRecorder = nil
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(AVAudioSession.Category.record)
        var recordSettings: [AnyHashable : Any]
        if format == kAudioFormatLinearPCM {
            recordSettings = [
            AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
            AVNumberOfChannelsKey: NSNumber(value: 2),
            AVSampleRateKey: NSNumber(value: 44100),
            AVLinearPCMBitDepthKey: NSNumber(value: 16),
            AVLinearPCMIsBigEndianKey: NSNumber(value: false),
            AVLinearPCMIsFloatKey: NSNumber(value: false)
            ]
        } else {
            recordSettings = [
            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.medium.rawValue),
            AVFormatIDKey: NSNumber(value: format),
            AVEncoderBitRateKey: NSNumber(value: 128000),
            AVNumberOfChannelsKey: NSNumber(value: 2),
            AVSampleRateKey: NSNumber(value: 44100),
            AVLinearPCMBitDepthKey: NSNumber(value: 16)
            ]
        }
        let url = URL(fileURLWithPath: filePath ?? "")
        if let recordSettings = recordSettings as? [String : Any] {
            audioRecorder = try? AVAudioRecorder(url: url, settings: recordSettings)
        }
        if audioRecorder?.prepareToRecord() ?? false {
            audioRecorder?.record()
            return true
        }
        return false
    }

    func stopRecording() -> Int {
        let length: Int = lroundf(Float(audioRecorder?.currentTime ?? 0.0))
        audioRecorder?.stop()
        return length
    }

    func playAudio(_ data: Data?) -> UIAlertController? {
        let url: URL? = URL(fileURLWithPath: "audio.aac")
        alert = Common.showMessage(nil, title: "Playing...".localized, message: Utilities.formatSeconds(0), okButtonTitle: "Stop".localized, okHandler: {
            self.stopPlaying()
            self.playingStopped()
            self.alert = nil
        })
        startTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AnnotationHandler.updateTime), userInfo: nil, repeats: true)
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(AVAudioSession.Category.playback)
        if let url = url {
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
        }
        audioPlayer?.delegate = self
        audioPlayer?.numberOfLoops = 0
        audioPlayer?.play()
        return alert
    }

    func stopPlaying() {
        audioPlayer?.stop()
    }

    func playingStopped() {
        timer?.invalidate()
        timer = nil
        startTime = nil
        alert = nil
        delegate?.didFinish()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playingStopped()
    }

    func drawImage() -> ImageAnnotationViewController? {
        let imageAnnotation = ImageAnnotationViewController()
        imageAnnotation.delegate = self
        imageAnnotation.dataSource = imageDataSource
        return imageAnnotation
    }

    func didFinishDrawing(_ image: UIImage?, updated: Bool) {
        let data = image?.jpegData(compressionQuality: CGFloat(kAnnotationJPGImageQuality))
        let thumbnailImage: UIImage? = image?.scaledImage(CGFloat(kAnnotationThumbnailSize))
        let thumbnailData = thumbnailImage?.jpegData(compressionQuality: CGFloat(kAnnotationJPGImageQuality))
        delegate?.didAddAnnotation(data, thumbnail: thumbnailData, length: CGFloat((data?.count ?? 0)), sender: self)
        navigationController?.popViewController(animated: true)
        delegate?.didFinish()
    }

    func display(_ image: UIImage?) -> PhotoAnnotationViewController? {
        var photoAnnotation: PhotoAnnotationViewController? = nil
        if let image = image {
            photoAnnotation = PhotoAnnotationViewController(image: image)
        }
        photoAnnotation?.delegate = self
        photoAnnotation?.dataSource = imageDataSource
        photoAnnotation?.isEditing = editing
        photoAnnotation?.title = "View Picture".localized
        return photoAnnotation
    }

    func didFinishEdit(_ image: UIImage?) {
        let data = image?.jpegData(compressionQuality: CGFloat(kAnnotationJPGImageQuality))
        let thumbnailImage: UIImage? = image?.scaledImage(CGFloat(kAnnotationThumbnailSize))
        let thumbnailData = thumbnailImage?.jpegData(compressionQuality: CGFloat(kAnnotationJPGImageQuality))
        delegate?.didUpdateAnnotation(data, thumbnail: thumbnailData, length: CGFloat((data?.count ?? 0)), sender: self)
        navigationController?.popViewController(animated: true)
        delegate?.didFinish()
    }

    func recordVideo() -> UIImagePickerController? {
        videoPicker = UIImagePickerController()
        videoPicker?.delegate = self
        videoPicker?.sourceType = .camera
        videoPicker?.mediaTypes = [kUTTypeMovie as String]
        videoPicker?.allowsEditing = true
        videoPicker?.videoQuality = .typeMedium
        videoPicker?.videoMaximumDuration = 30.0
        return videoPicker
    }

    func chooseVideo() -> UIImagePickerController? {
        videoPicker = UIImagePickerController()
        videoPicker?.delegate = self
        videoPicker?.sourceType = .photoLibrary
        videoPicker?.mediaTypes = [kUTTypeMovie as String]
        videoPicker?.allowsEditing = true
        return videoPicker
    }

    func playVideo(_ data: Data?) -> AVPlayerViewController? {
        let url: URL? = URL(fileURLWithPath: "video.mp4")
        var player: AVPlayer? = nil
        if let url = url {
            player = AVPlayer(url: url)
        }
        let playerViewController = VideoAnnotationViewController()
        playerViewController.player = player
        return playerViewController
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if picker == imagePicker {
            var image: UIImage?
            if picker.allowsEditing {
                image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            } else {
                image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            }
            let thumbnailImage: UIImage? = image?.scaledImage(CGFloat(kAnnotationThumbnailSize))
            let data = image?.jpegData(compressionQuality: CGFloat(kAnnotationJPGImageQuality))
            let thumbnailData = thumbnailImage?.jpegData(compressionQuality: CGFloat(kAnnotationJPGImageQuality))
            delegate?.didAddAnnotation(data, thumbnail: thumbnailData, length: CGFloat((data?.count ?? 0)), sender: self)
            delegate?.didFinish()
        } else if picker == videoPicker {
            let url = info[.mediaURL] as? URL
            var movie: AVAsset? = nil
            if let url = url {
                movie = AVAsset(url: url)
            }
            let movieDuration: CMTime? = movie?.duration
            let length: Int = Int(round(Float(movieDuration?.value ?? 0) / Float((movieDuration?.timescale ?? 0))))
            var data: Data? = nil
            if let url = url {
                data = try? Data(contentsOf: url)
            }
            var asset: AVURLAsset? = nil
            if let url = url {
                asset = AVURLAsset(url: url, options: nil)
            }
            var generate1: AVAssetImageGenerator? = nil
            if let asset = asset {
                generate1 = AVAssetImageGenerator(asset: asset)
            }
            generate1?.appliesPreferredTrackTransform = true
            let time: CMTime = CMTimeMake(value: 1, timescale: 2)
            let thumbnailRef = try? generate1?.copyCGImage(at: time, actualTime: nil)
            var thumbnailImage: UIImage? = nil
            if let thumbnailRef = thumbnailRef {
                thumbnailImage = UIImage(cgImage: thumbnailRef)
            }
            let thumbnailData = thumbnailImage?.jpegData(compressionQuality: CGFloat(kAnnotationJPGImageQuality))
            delegate?.didAddAnnotation(data, thumbnail: thumbnailData, length: CGFloat(length), sender: self)
            delegate?.didFinish()
        }
    }

    func convertVideoToLowQuailty(withInputURL inputURL: URL?, outputURL: URL?) {
        var videoAsset: AVAsset? = nil
        if let inputURL = inputURL {
            videoAsset = AVURLAsset(url: inputURL, options: nil)
        }
        let videoTrack: AVAssetTrack? = videoAsset?.tracks(withMediaType: .video)[0]
        let videoSize: CGSize? = videoTrack?.naturalSize
        let videoWriterCompressionSettings = [
            AVVideoAverageBitRateKey : NSNumber(value: 1250000)
        ]
        let videoWriterSettings:[String: Any] = [
            AVVideoCodecKey : AVVideoCodecType.h264,
            AVVideoCompressionPropertiesKey : videoWriterCompressionSettings,
            AVVideoWidthKey : NSNumber(value: Float(videoSize?.width ?? 0.0)),
            AVVideoHeightKey : NSNumber(value: Float(videoSize?.height ?? 0.0))
        ]
        let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoWriterSettings)
        videoWriterInput.expectsMediaDataInRealTime = true
        if let preferredTransform = videoTrack?.preferredTransform {
            videoWriterInput.transform = preferredTransform
        }
        var videoWriter: AVAssetWriter? = nil
        if let outputURL = outputURL {
            videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mov)
        }
        videoWriter?.add(videoWriterInput)
        let videoReaderSettings = [kCVPixelBufferPixelFormatTypeKey : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)]
        var videoReaderOutput: AVAssetReaderTrackOutput? = nil
        if let videoTrack = videoTrack {
            videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings as [String : Any])
        }
        var videoReader: AVAssetReader? = nil
        if let videoAsset = videoAsset {
            videoReader = try? AVAssetReader(asset: videoAsset)
        }
        if let videoReaderOutput = videoReaderOutput {
            videoReader?.add(videoReaderOutput)
        }
        let audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
        audioWriterInput.expectsMediaDataInRealTime = false
        videoWriter?.add(audioWriterInput)
        let audioTrack: AVAssetTrack? = videoAsset?.tracks(withMediaType: .audio)[0]
        var audioReaderOutput: AVAssetReaderOutput? = nil
        if let audioTrack = audioTrack {
            audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        }
        var audioReader: AVAssetReader? = nil
        if let videoAsset = videoAsset {
            audioReader = try? AVAssetReader(asset: videoAsset)
        }
        if let audioReaderOutput = audioReaderOutput {
            audioReader?.add(audioReaderOutput)
        }
        videoWriter?.startWriting()
        videoReader?.startReading()
        videoWriter?.startSession(atSourceTime: .zero)
        let processingQueue = DispatchQueue(label: "processingQueue1")
        videoWriterInput.requestMediaDataWhenReady(on: processingQueue, using: {
            while videoWriterInput.isReadyForMoreMediaData {
                let sampleBuffer: CMSampleBuffer? = videoReaderOutput?.copyNextSampleBuffer()
                if videoReader?.status == .reading && sampleBuffer != nil {

                    if let sampleBuffer = sampleBuffer {
                        videoWriterInput.append(sampleBuffer)
                    }
                } else {
                    videoWriterInput.markAsFinished()
                    if videoReader?.status == .completed {
                        audioReader?.startReading()
                        videoWriter?.startSession(atSourceTime: .zero)
                        let processingQueue = DispatchQueue(label: "processingQueue2")
                        audioWriterInput.requestMediaDataWhenReady(on: processingQueue, using: {
                            while audioWriterInput.isReadyForMoreMediaData {
                                let sampleBuffer: CMSampleBuffer? = audioReaderOutput?.copyNextSampleBuffer()
                                if audioReader?.status == .reading && sampleBuffer != nil {

                                    if let sampleBuffer = sampleBuffer {
                                        audioWriterInput.append(sampleBuffer)
                                    }
                                } else {
                                    audioWriterInput.markAsFinished()
                                    if audioReader?.status == .completed {
                                        videoWriter?.finishWriting(completionHandler: {
                                            DispatchQueue.main.async(execute: {
                                                self.videoCompressionDone(outputURL)

                                            })
                                        })
                                    } else if audioReader?.status == .failed || audioReader?.status == .cancelled {
                                        DispatchQueue.main.async(execute: {
                                            self.videoCompressionFailed()
                                        })
                                    }
                                }
                            }

                        })
                    } else if videoReader?.status == .failed || videoReader?.status == .cancelled {
                        DispatchQueue.main.async(execute: {
                            self.videoCompressionFailed()
                        })
                    }
                }
            }
        })
        navigationController?.popViewController(animated: true)
        delegate?.didFinish()
    }

    func videoCompressionDone(_ videoURL: URL?) {
        var data: Data? = nil
        if let videoURL = videoURL {
            data = try? Data(contentsOf: videoURL)
        }
        let fileManager = FileManager.default
        try? fileManager.removeItem(atPath: videoURL?.path ?? "")
        delegate?.didAddAnnotation(data, thumbnail: nil, length: CGFloat((data?.count ?? 0)), sender: self)
        navigationController?.popViewController(animated: true)
        delegate?.didFinish()
    }

    func videoCompressionFailed() {
        navigationController?.popViewController(animated: true)
        delegate?.didFinish()
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    }
}

let kAnnotationThumbnailSize = 100.0
let kAnnotationJPGImageQuality = 0.5
