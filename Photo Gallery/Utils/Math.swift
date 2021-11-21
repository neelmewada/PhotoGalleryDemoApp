//
//  Math.swift
//  Photo-Learn
//
//  Created by Neel Mewada on 15/05/21.
//

import Foundation
import UIKit

/// A helper Math class.
public final class Math {
    public static func add(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        return CGPoint(x: a.x + b.x, y: a.y + b.y)
    }
    
    public static func subtract(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        return CGPoint(x: a.x - b.x, y: a.y - b.y)
    }
    
    public static func lerp(from a: CGFloat, to b: CGFloat, t: CGFloat) -> CGFloat {
        return a * (1 - clamp01(t)) + b * clamp01(t)
    }
    
    public static func clamp01(_ value: CGFloat) -> CGFloat {
        return max(0, min(1, value))
    }
}
