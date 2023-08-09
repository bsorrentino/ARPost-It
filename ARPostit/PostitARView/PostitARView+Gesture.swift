//
//  PostitARView+Gesture.swift
//  ARPostit
//
//  Created by Bartolomeo Sorrentino on 03/08/23.
//

import ARKit
import RealityKit


extension PostitARView {
    
    func setupGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(self.handleTap_and_raycast(_:)))
        //                                                action: #selector(context.coordinator.handleTap_and_hitTest(_:)))
        self.addGestureRecognizer(tapGesture)

    }
    
    func getPlaneFrom( location: CGPoint ) -> ARPlaneAnchor? {
        let hitTestResults = self.hitTest(location, types: .existingPlaneUsingExtent)
            
        guard let hitTestResult = hitTestResults.first, let planeAnchor = hitTestResult.anchor as? ARPlaneAnchor else { return nil }
        
        
        return planeAnchor
    }
    
    
    //
    // FROM PHIND:
    //
    @objc func handleTap_and_raycast(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
            
        guard let raycastQuery = self.makeRaycastQuery(from: location,
                                                       allowing: .estimatedPlane,
                                                       alignment: .vertical) else {
            print("no plane detect at \(location)!")
            return
        }
        
        let result = self.session.raycast(raycastQuery)
        
        if let result = result.first {
            
            let anchor = ARAnchor(name: "Text", transform: result.worldTransform)
            self.session.add(anchor: anchor)

        }
        else {
            print("no plane detect at \(location)!")
        }
        
    }
    
}
