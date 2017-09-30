//
//  MatrixHelper.swift
//
//  Created by Jamie Perkins on 9/14/17.
//  Copyright © 2017 Inorganik Produce, Inc. All rights reserved.
//

import Foundation
import GLKit
import CoreLocation

struct MatrixHelper {
    
    // GLKMatrix to float4x4
    static func convertGLKMatrix4Tosimd_float4x4(_ matrix: GLKMatrix4) -> float4x4{
        return float4x4(float4(matrix.m00, matrix.m01, matrix.m02, matrix.m03),
                        float4(matrix.m10, matrix.m11, matrix.m12, matrix.m13),
                        float4(matrix.m20, matrix.m21, matrix.m22, matrix.m23),
                        float4(matrix.m30, matrix.m31, matrix.m32, matrix.m33))
    }
	
    // degrees - 0: straight ahead. positive: to the left. negative: to the right
    static func rotateMatrixAroundY(degrees: Float, matrix: simd_float4x4) -> simd_float4x4 {
        
        let radians = GLKMathDegreesToRadians(degrees)
        //let rotationMatrix = GLKMatrix4RotateY(GLKMatrix4Identity, radians)
        let rotationMatrix = GLKMatrix4MakeYRotation(radians)
        return simd_mul(convertGLKMatrix4Tosimd_float4x4(rotationMatrix), matrix)
    }
    
    // degrees - 0: horizon.
    // northern hemisphere - positive: toward sky. negative: toward ground
    // southern hemisphere - positive: toward ground. negative: toward sky
    static func translateMatrixFromHorizon(degrees: Float, matrix: simd_float4x4) -> simd_float4x4 {
        let radians = GLKMathDegreesToRadians(degrees)
        let horizonMatrix = GLKMatrix4MakeXRotation(radians)
        return simd_mul(convertGLKMatrix4Tosimd_float4x4(horizonMatrix), matrix)
    }
    
    // just what it says on the tin
    static func resetToHorizon(_ matrix: simd_float4x4) -> simd_float4x4 {
        var resultMatrix = matrix
        resultMatrix.columns.3.y = 0
        return resultMatrix
    }
    
    static func translate(x: Float, y: Float, z: Float) -> simd_float4x4 {
        var resultMatrix = matrix_identity_float4x4
        resultMatrix.columns.3.x = x
        resultMatrix.columns.3.y = y
        resultMatrix.columns.3.z = z
        return resultMatrix
    }
    
    static func bearingBetween(startLocation: CLLocation, endLocation: CLLocation) -> Float {
        var azimuth: Float = 0
        let lat1 = GLKMathDegreesToRadians(Float(startLocation.coordinate.latitude))
        let lon1 = GLKMathDegreesToRadians(Float(startLocation.coordinate.longitude))
        let lat2 = GLKMathDegreesToRadians(Float(endLocation.coordinate.latitude))
        let lon2 = GLKMathDegreesToRadians(Float(endLocation.coordinate.longitude))
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        azimuth = GLKMathRadiansToDegrees(Float(radiansBearing))
        if (azimuth < 0) { azimuth += 360 }
        return azimuth
    }
}
