//
//  SpinningCircleView.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 28/8/2021.
//

import UIKit


class LoaderCircleView: UIView {
    
    let spinningCircle = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    private func configure(){
        frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        
        let rect = self.bounds
        let circularPath = UIBezierPath(ovalIn: rect)
        
        spinningCircle.path = circularPath.cgPath
        spinningCircle.fillColor = UIColor.clear.cgColor
        spinningCircle.strokeColor = UIColor.MRed?.cgColor
        spinningCircle.lineWidth = 6
        spinningCircle.strokeEnd = 0.25
        spinningCircle.lineCap = .round

        self.layer.addSublayer(spinningCircle)
        
    }
    
    func animate(){
                
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear) {
            self.transform = CGAffineTransform(rotationAngle: .pi)
        } completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear) {
                self.transform = CGAffineTransform(rotationAngle: 0)
            } completion: { _ in
                self.animate()
            }
        }
    }
    
    func stopAnimate() {
        self.spinningCircle.frame = .null
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    
}



