//
//  SIMD4+Extensions.swift
//  ARPostit
//
//  Created by Bartolomeo Sorrentino on 09/08/23.
//

import RealityKit

extension SIMD4 {
    
    var xyz: SIMD3<Scalar> {
        return self[SIMD3(0, 1, 2)]
    }
    
}

