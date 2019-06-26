//
//  ColorPicker.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 05.08.14.
//

import UIKit

protocol ColorPickerDelegate: NSObjectProtocol {
    func didPick(_ color: UIColor?, sender: Any?)
}

class ColorPicker: UIView {
    private var currentBrightness: CGFloat = 0.0
    private var currentHue: CGFloat = 0.0
    private var currentSaturation: CGFloat = 0.0

    private var _color: UIColor?
    var color: UIColor? {
        get {
            return _color
        }
        set(newColor) {
            if newColor != nil && _color != newColor {
                var hue: CGFloat
                var saturation: CGFloat
                //newColor?.getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)
                //currentHue = hue
                //currentSaturation = saturation
                _setColor(newColor)
                _updateGradientColor()
                _updateBrightnessPosition()
                _updateCrosshairPosition()
            }
        }
    }
    weak var delegate: ColorPickerDelegate?

    init(frame: CGRect, color: UIColor?) {
        super.init(frame: frame)
        self.color = color
    }


    private var _gradientView: BrightnessView?
    private var gradientView: BrightnessView? {
        if _gradientView == nil {
            _gradientView = BrightnessView()
            _gradientView?.frame = CGRect(x: CGFloat(kPickerViewDefaultMargin), y: CGFloat(frame.height - CGFloat(kPickerViewGradientViewHeight) - CGFloat(kPickerViewDefaultMargin)), width: CGFloat(frame.width - CGFloat(kPickerViewDefaultMargin * 2)), height: CGFloat(kPickerViewGradientViewHeight))
            _gradientView?.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
            _gradientView?.layer.borderWidth = 1.0
            _gradientView?.layer.borderColor = UIColor.lightGray.cgColor
            _gradientView?.layer.cornerRadius = 5.0
            _gradientView?.layer.masksToBounds = true
            if let _gradientView = _gradientView {
                addSubview(_gradientView)
            }
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ColorPicker.handleBrightnessMove(_:)))
            panGesture.minimumNumberOfTouches = 1
            panGesture.maximumNumberOfTouches = 1
            _gradientView?.addGestureRecognizer(panGesture)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ColorPicker.handleBrightnessMove(_:)))
            _gradientView?.addGestureRecognizer(tapGesture)
        }
        return _gradientView
    }

    private var _brightnessIndicator: UIImageView?
    private var brightnessIndicator: UIImageView? {
        if _brightnessIndicator == nil {
            _brightnessIndicator = UIImageView(frame: CGRect(x: (gradientView?.frame.width)! * 0.5, y: (gradientView?.frame.minY)! - 4, width: CGFloat(kPickerViewBrightnessIndicatorWidth), height: CGFloat(kPickerViewBrightnessIndicatorHeight)))
            _brightnessIndicator?.image = UIImage(named: "brightness_guide")?.tintImage(with: UIColor.lightGray)
            _brightnessIndicator?.backgroundColor = UIColor.clear
            _brightnessIndicator?.autoresizingMask = []
            if let _brightnessIndicator = _brightnessIndicator, let gradientView = gradientView {
                insertSubview(_brightnessIndicator, aboveSubview: gradientView)
            }
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ColorPicker.handleBrightnessMove(_:)))
            panGesture.minimumNumberOfTouches = 1
            panGesture.maximumNumberOfTouches = 1
            _brightnessIndicator?.addGestureRecognizer(panGesture)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ColorPicker.handleBrightnessMove(_:)))
            _brightnessIndicator?.addGestureRecognizer(tapGesture)
        }
        return _brightnessIndicator
    }

    private var _hueSatImage: UIImageView?
    private var hueSatImage: UIImageView? {
        if _hueSatImage == nil {
            _hueSatImage = UIImageView(image: UIImage(named: "colormap.png"))
            _hueSatImage?.frame = CGRect(x: CGFloat(kPickerViewDefaultMargin), y: CGFloat(kPickerViewDefaultMargin), width: CGFloat(frame.width - CGFloat(kPickerViewDefaultMargin * 2)), height: CGFloat(frame.height - CGFloat(kPickerViewGradientViewHeight) - CGFloat(kPickerViewDefaultMargin) - CGFloat(kPickerViewGradientTopMargin)))
            _hueSatImage?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            _hueSatImage?.layer.borderWidth = 1.0
            _hueSatImage?.layer.borderColor = UIColor.lightGray.cgColor
            _hueSatImage?.layer.cornerRadius = 5.0
            _hueSatImage?.layer.masksToBounds = true
            _hueSatImage?.isUserInteractionEnabled = true
            if let _hueSatImage = _hueSatImage, let gradientView = gradientView {
                insertSubview(_hueSatImage, aboveSubview: gradientView)
            }
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ColorPicker.handleHueSatMove(_:)))
            panGesture.minimumNumberOfTouches = 1
            panGesture.maximumNumberOfTouches = 1
            _hueSatImage?.addGestureRecognizer(panGesture)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ColorPicker.handleHueSatMove(_:)))
            _hueSatImage?.addGestureRecognizer(tapGesture)
        }
        return _hueSatImage
    }

    private var _crossHair: UIView?
    private var crossHair: UIView? {
        if _crossHair == nil {
            _crossHair = UIView(frame: CGRect(x: frame.width * 0.5, y: frame.height * 0.5, width: CGFloat(kPickerViewCrossHairWidthAndHeight), height: CGFloat(kPickerViewCrossHairWidthAndHeight)))
            _crossHair?.autoresizingMask = []
            let edgeColor = UIColor(white: 0.9, alpha: 0.8)
            _crossHair?.layer.cornerRadius = CGFloat(Double(kPickerViewCrossHairWidthAndHeight) / 2.0)
            _crossHair?.layer.borderColor = edgeColor.cgColor
            _crossHair?.layer.borderWidth = 1
            _crossHair?.layer.shadowColor = UIColor.black.cgColor
            _crossHair?.layer.shadowOffset = CGSize.zero
            _crossHair?.layer.shadowRadius = 1.0
            _crossHair?.layer.shadowOpacity = 0.5
            if let _crossHair = _crossHair, let hueSatImage = hueSatImage {
                insertSubview(_crossHair, aboveSubview: hueSatImage)
            }
            if let gradientView = gradientView {
                addSubview(gradientView)
            }
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ColorPicker.handleHueSatMove(_:)))
            panGesture.minimumNumberOfTouches = 1
            panGesture.maximumNumberOfTouches = 1
            _crossHair?.addGestureRecognizer(panGesture)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ColorPicker.handleHueSatMove(_:)))
            _crossHair?.addGestureRecognizer(tapGesture)
        }
        return _crossHair
    }
    private var touchPosition: Int = 0

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        crossHair?.isHidden = false
        brightnessIndicator?.isHidden = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        hueSatImage?.frame = CGRect(x: CGFloat(kPickerViewDefaultMargin), y: CGFloat(kPickerViewDefaultMargin), width: CGFloat(frame.width - CGFloat(kPickerViewDefaultMargin * 2)), height: CGFloat(frame.height - CGFloat(kPickerViewGradientViewHeight) - CGFloat(kPickerViewDefaultMargin) - CGFloat(kPickerViewGradientTopMargin)))
        gradientView?.frame = CGRect(x: CGFloat(kPickerViewDefaultMargin), y: CGFloat(frame.height - CGFloat(kPickerViewGradientViewHeight) - CGFloat(kPickerViewDefaultMargin)), width: CGFloat(frame.width - CGFloat(kPickerViewDefaultMargin * 2)), height: CGFloat(kPickerViewGradientViewHeight))
        _updateBrightnessPosition()
        _updateCrosshairPosition()
    }

    func _setColor(_ newColor: UIColor?) {
        if !(color?.isEqual(newColor) ?? false) {
            var brightness: CGFloat
            //newColor?.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
            let colorSpaceModel: CGColorSpaceModel = newColor!.cgColor.colorSpace!.model
            if colorSpaceModel == .monochrome {
                let c = newColor?.cgColor.components
                color = UIColor(hue: 0, saturation: 0, brightness: c?[0] ?? 0.0, alpha: 1.0)
            } else {
                color = newColor
            }
            delegate?.didPick(color, sender: self)
        }
    }

    func _updateBrightnessPosition() {
        color?.getHue(nil, saturation: nil, brightness: &currentBrightness, alpha: nil)
        var brightnessPosition = CGPoint(x: 0, y:0)
        brightnessPosition.x = (1.0 - currentBrightness) * (gradientView?.frame.size.width ?? 0.0) + (gradientView?.frame.origin.x ?? 0.0)
        brightnessPosition.y = gradientView?.center.y ?? 0.0
        brightnessIndicator?.center = brightnessPosition
    }

    func _updateCrosshairPosition() {
        var hueSatPosition = CGPoint(x: 0, y:0)
        hueSatPosition.x = (currentHue * (hueSatImage?.frame.size.width ?? 0.0)) + (hueSatImage?.frame.origin.x ?? 0.0)
        hueSatPosition.y = (1.0 - currentSaturation) * (hueSatImage?.frame.size.height ?? 0.0) + (hueSatImage?.frame.origin.y ?? 0.0)
        crossHair?.center = hueSatPosition
        _updateGradientColor()
    }

    func _updateGradientColor() {
        let gradientColor = UIColor(hue: currentHue, saturation: currentSaturation, brightness: 1.0, alpha: 1.0)
        crossHair?.layer.backgroundColor = gradientColor.cgColor
        gradientView?.color = gradientColor
    }

    func _updateHueSat(withMovement position: CGPoint) {
        currentHue = (position.x - (hueSatImage?.frame.origin.x ?? 0.0)) / (hueSatImage?.frame.size.width ?? 0.0)
        currentSaturation = 1.0 - (position.y - (hueSatImage?.frame.origin.y ?? 0.0)) / (hueSatImage?.frame.size.height ?? 0.0)
        let _tcolor = UIColor(hue: currentHue, saturation: currentSaturation, brightness: currentBrightness, alpha: 1.0)
        let gradientColor = UIColor(hue: currentHue, saturation: currentSaturation, brightness: 1.0, alpha: 1.0)
        crossHair?.layer.backgroundColor = gradientColor.cgColor
        _updateGradientColor()
        _setColor(_tcolor)
    }

    func _updateBrightness(withMovement position: CGPoint) {
        currentBrightness = 1.0 - ((position.x - (gradientView?.frame.origin.x ?? 0.0)) / (gradientView?.frame.size.width ?? 0.0))
        let _tcolor = UIColor(hue: currentHue, saturation: currentSaturation, brightness: currentBrightness, alpha: 1.0)
        _setColor(_tcolor)
    }

    @objc func handleHueSatMove(_ gesture: UIPanGestureRecognizer?) {
        touchPosition = kPickerViewTouchHueSat
        let point: CGPoint? = gesture?.location(in: hueSatImage)
        if gesture?.state == .began {
            dispatchTouchEvent(point ?? CGPoint.zero)
        } else if gesture?.state == .changed {
            dispatchTouchEvent(point ?? CGPoint.zero)
        } else if gesture?.state == .ended {
            dispatchTouchEvent(point ?? CGPoint.zero)
        }
    }

    @objc func handleBrightnessMove(_ gesture: UIPanGestureRecognizer?) {
        touchPosition = kPickerViewTouchBrightness
        let point: CGPoint? = gesture?.location(in: gradientView)
        if gesture?.state == .began {
            dispatchTouchEvent(point ?? CGPoint.zero)
        } else if gesture?.state == .changed {
            dispatchTouchEvent(point ?? CGPoint.zero)
        } else if gesture?.state == .ended {
            dispatchTouchEvent(point ?? CGPoint.zero)
        }
    }

    /*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
        self.touchPosition = kPickerViewTouchNone;
        if (touches.count > 0) {
            UITouch *touch = [touches anyObject];
            CGPoint position = [touch locationInView:self];
            if (CGRectContainsPoint(self.hueSatImage.frame, position) || CGRectContainsPoint(self.crossHair.frame, position)){
                self.touchPosition = kPickerViewTouchHueSat;
            }
            else if (CGRectContainsPoint(self.gradientView.frame, position) || CGRectContainsPoint(self.brightnessIndicator.frame, position)) {
                self.touchPosition = kPickerViewTouchBrightness;
            }
            [self dispatchTouchEvent:position];
        }
    }

    - (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
        if (touches.count > 0) {
            UITouch *touch = [touches anyObject];
            CGPoint position = [touch locationInView:self];
            [self dispatchTouchEvent:position];
        }
    }*/
    func dispatchTouchEvent(_ position: CGPoint) {
        if touchPosition == kPickerViewTouchHueSat {
            crossHair?.center = CGPoint(x: min(max(position.x, (hueSatImage?.frame.origin.x)!), (hueSatImage?.frame.size.width ?? 0.0) + (hueSatImage?.frame.origin.x ?? 0.0)), y: min(max(position.y, (hueSatImage?.frame.origin.y)!), (hueSatImage?.frame.size.height ?? 0.0) + (hueSatImage?.frame.origin.y ?? 0.0)))
            _updateHueSat(withMovement: position)
        } else if touchPosition == kPickerViewTouchBrightness {
            brightnessIndicator?.center = CGPoint(x: min(max(position.x, (gradientView?.frame.origin.x)!), (gradientView?.frame.size.width ?? 0.0) + (gradientView?.frame.origin.x ?? 0.0)), y: gradientView?.center.y ?? 0.0)
            _updateBrightness(withMovement: position)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

let kPickerViewGradientViewHeight = 40
let kPickerViewGradientTopMargin = 20
let kPickerViewDefaultMargin = 5
let kPickerViewBrightnessIndicatorWidth = 16
let kPickerViewBrightnessIndicatorHeight = 48
let kPickerViewCrossHairWidthAndHeight = 40

let kPickerViewTouchNone = 0
let kPickerViewTouchHueSat = 1
let kPickerViewTouchBrightness = 2
class BrightnessView: UIView {
    private var gradient: CGGradient?

    private var _color: UIColor?
    var color: UIColor? {
        get {
            return _color
        }
        set(newColor) {
            if newColor != nil && _color != newColor {
                var hue: CGFloat
                var saturation: CGFloat
                //newColor?.getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)
                /*currentHue = hue
                currentSaturation = saturation
                _setColor(newColor)
                _updateGradientColor()
                _updateBrightnessPosition()
                _updateCrosshairPosition()*/
            }
        }
    }

    func setColor(_ color: UIColor?) {
        if self.color != color {
            self.color = color
            setupGradient()
            setNeedsDisplay()
        }
    }

    func setupGradient() {
        let c = color?.cgColor.components
        let colors = [c![0], c![1], c![2], 1.0, 0.0, 0.0, 0.0, 1.0]
        let rgb = CGColorSpaceCreateDeviceRGB()
        if gradient != nil {
        }
        // gradient = CGGradient(colorsSpace: rgb, colors: colors, locations: nil) as? CGGradient
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let clippingRect = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
        let endPoints = [CGPoint(x: 0, y: 0), CGPoint(x: frame.size.width, y: 0)]
        context?.saveGState()
        context?.clip(to: clippingRect)
        context?.drawLinearGradient(gradient!, start: endPoints[0], end: endPoints[1], options: [])
        context?.restoreGState()
    }

    deinit {
    }
}
