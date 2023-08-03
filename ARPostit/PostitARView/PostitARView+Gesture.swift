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
            self.addNoteEntityToWall( at: location, worldTransform: result.worldTransform)
        }
        else {
            print("no plane detect at \(location)!")
        }
        
    }
    
    //        @objc func handleTap_and_hitTest(_ sender: UITapGestureRecognizer) {
    //
    //            let location = sender.location(in: parent.arView)
    //
    //            let results = parent.arView.hitTest(location, types: .existingPlane)
    //
    //            if results.isEmpty {
    //                print("no plane detect at \(location)!")
    //            }
    //            else {
    //                addNoteEntityToWall( at: location, worldTransform: results.first!.worldTransform)
    //            }
    //        }
    
}
