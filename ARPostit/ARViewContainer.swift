//
//  ARViewContainer.swift
//  ARPostit
//
//  Created by Bartolomeo Sorrentino on 25/07/23.
//

import SwiftUI
import ARKit
import RealityKit

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

struct ARViewContainer: View {
    @StateObject private var notesStorage = NotesStorage()
    @State private var notes: [String: [CGPoint]] = [:]
    
    var body: some View {
        ARViewContainerRepresentable(notes: $notes)
            .environmentObject(notesStorage)
            .onAppear {
                notes = notesStorage.savedNotes
            }
            .overlay(
                ZStack {
                    ForEach(notes.keys.sorted(), id: \.self) { key in
                        Group {
                            if let positions = notes[key] {
                                ForEach(positions, id: \.self) { position in
                                    TextNoteView(text: key)
                                        .position(position)
                                }
                            }
                        }
                    }
                }
            )
    }
}

struct ARViewContainerRepresentable: UIViewRepresentable {
    @Binding var notes: [String: [CGPoint]]

//    let arView = ARView(frame: .zero)
//    let arView = ARView()
    
    // [Using Vision and RealityKit Rotates Counterclockwise and Distorts(Stretches?) Video](https://stackoverflow.com/a/72252900/521197)
    let arView = ARView(frame: .init(x: 1, y: 1, width: 1, height: 1),
                        cameraMode: .ar,
                        automaticallyConfigureSession: false)

    
    func makeUIView(context: Context) -> ARView {
        // [RealityKit tutorial: Plane Detection and Raycasting](https://www.youtube.com/watch?v=T1u1tyMlMLM&t=101s)
        arView.debugOptions = [ .showSceneUnderstanding, .showFeaturePoints ]
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration)

        let tapGesture = UITapGestureRecognizer(target: context.coordinator,
                                                action: #selector(context.coordinator.handleTap_and_raycast(_:)))
//                                                action: #selector(context.coordinator.handleTap_and_hitTest(_:)))
         
        arView.addGestureRecognizer(tapGesture)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
      // FROM BING: prompt[which are events related to detected planes]
//    func planesDetectionSetup() {
//        
//        let session = ARKitSession()
//        let planeData = PlaneDetectionProvider(alignments: [.horizontal, .vertical])
//
//        Task {
//            try await session.run([planeData])
//            
//            for await update in planeData.anchorUpdates {
//                // Skip planes that are windows.
//                if update.anchor.classification == .window { continue }
//                
//                switch update.event {
//                case .added, .updated:
//                    updatePlane(update.anchor)
//                case .removed:
//                    removePlane(update.anchor)
//                }
//            }
//        }
//
//    }
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainerRepresentable
        var grids = [GridEntity]()
        
        init(_ parent: ARViewContainerRepresentable) {
            self.parent = parent
            super.init()
            self.parent.arView.session.delegate = self
        }
     
        // FROM BING: prompt[Can you show me how to detect vertical planes?]
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical {
                    // Add a new Grid entity to your scene for the detected vertical plane
                    let grid = GridEntity(planeAnchor: planeAnchor)
                    
                    parent.arView.scene.addAnchor(grid)
                    grids.append(grid)
                }
            }
        }
        
        // [RealityKit – Visualizing Grid on detected planes](https://stackoverflow.com/a/71351712/521197)
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
                
            guard let planeAnchor = anchors[0] as? ARPlaneAnchor else { return }
            
            if let updatedGrid = grids.first( where: { $0.planeAnchor.identifier == planeAnchor.identifier } ) {
                updatedGrid.didUpdate(anchor: planeAnchor)
            }
        }

        //
        // FROM PHIND:
        //
        @objc func handleTap_and_raycast(_ sender: UITapGestureRecognizer) {
            let location = sender.location(in: parent.arView)
            
            guard let raycastQuery = parent.arView.makeRaycastQuery(from: location,
                                                     allowing: .estimatedPlane,
                                                     alignment: .vertical) else {
                print("no plane detect at \(location)!")
                return
            }
             
            let result = parent.arView.session.raycast(raycastQuery)
            
            if let result = result.first {
                addNoteEntityToWall( worldTransform: result.worldTransform)
            }
            else {
                print("no plane detect at \(location)!")
            }

        }

        @objc func handleTap_and_hitTest(_ sender: UITapGestureRecognizer) {
            
            let location = sender.location(in: parent.arView)
            
            let results = parent.arView.hitTest(location, types: .existingPlane)
            
            if results.isEmpty {
                print("no plane detect at \(location)!")
            }
            else {
                addNoteEntityToWall( worldTransform: results.first!.worldTransform)
            }
        }
        
        func addNoteEntityToWall( worldTransform: simd_float4x4 ) {
            
//            let position = SIMD3<Float>(worldTransform.columns.3.x,
//                                     worldTransform.columns.3.y,
//                                     worldTransform.columns.3.z)
            let position = SIMD3<Float>(x: 0.0, y: 0.0, z: -0.5)

            let anchor = AnchorEntity(world: worldTransform )
            parent.arView.scene.addAnchor(anchor)
            
            let note = makeNoteEntity(text: "New Note" )
            
            anchor.addChild(note)
            
            note.transform.translation = position
            
        }

        func addNoteViewToWall( worldTransform: simd_float4x4 ) {
            
            let position = SCNVector3(worldTransform.columns.3.x,
                                     worldTransform.columns.3.y,
                                     worldTransform.columns.3.z)
            
            let anchor = ARAnchor(name: "Note", transform: worldTransform)
            parent.arView.session.add(anchor: anchor)
            
            let noteText = "New Note"
            let point = CGPoint(x: CGFloat(position.x), y: CGFloat(position.y))
            
            if var existingNotes = parent.notes[noteText] {
                existingNotes.append(point)
                parent.notes[noteText] = existingNotes
            } else {
                parent.notes[noteText] = [point]
            }

        }
    }
}

    //extension ARViewContainerRepresentable {
    //    var arView: ARView {
    //        (UIApplication.shared.windows.first?.rootViewController as! UIHostingController<ARViewContainer>).arView
    //    }
    //}

#Preview {
    ARViewContainer()
}
