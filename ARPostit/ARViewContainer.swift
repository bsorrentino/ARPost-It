//
//  ARViewContainer.swift
//  ARPostit
//
//  Created by Bartolomeo Sorrentino on 25/07/23.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

struct ARViewContainer: View {
    @StateObject private var notesStorage = NotesStorage()
//    @State private var notes: [String: [CGPoint]] = [:]
    
    var body: some View {
        ARViewContainerRepresentable()
            .environmentObject(notesStorage)
//        ARViewContainerRepresentable(notes: $notes)
//            .environmentObject(notesStorage)
//            .onAppear {
//                notes = notesStorage.savedNotes
//            }
//            .overlay(
//                ZStack {
//                    ForEach(notes.keys.sorted(), id: \.self) { key in
//                        Group {
//                            if let positions = notes[key] {
//                                ForEach(positions, id: \.self) { position in
//                                    NoteView(text: key)
//                                        .position(position)
//                                }
//                            }
//                        }
//                    }
//                }
//            )
    }
}

struct ARViewContainerRepresentable: UIViewRepresentable {
//    @Binding var notes: [String: [CGPoint]]

//    let arView = ARView(frame: .zero)
//    let arView = ARView()
    
    // [Using Vision and RealityKit Rotates Counterclockwise and Distorts(Stretches?) Video](https://stackoverflow.com/a/72252900/521197)
    let arView = PostitARView(frame: .init(x: 1, y: 1, width: 1, height: 1),
                        cameraMode: .ar,
                        automaticallyConfigureSession: false)

    
    func makeUIView(context: Context) -> ARView {
        // [RealityKit tutorial: Plane Detection and Raycasting](https://www.youtube.com/watch?v=T1u1tyMlMLM&t=101s)
        arView.debugOptions = [ .showSceneUnderstanding, .showFeaturePoints ]
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration)

        arView.setupGesture()
                 
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: ARViewContainerRepresentable
        var grids = [GridEntity]()
        private var subscription: Cancellable!
        
        init(_ parent: ARViewContainerRepresentable) {
            self.parent = parent
            super.init()
            self.parent.arView.session.delegate = self
            
            subscription = self.parent.arView.scene.subscribe(to: SceneEvents.Update.self) { _ in   
//                NoteEntity.updateScene(arView: parent.arView)
            }
            
        }

    }
}

extension ARViewContainerRepresentable.Coordinator : ARSessionDelegate {
    
    // FROM BING: prompt[Can you show me how to detect vertical planes?]
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        // GRID
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical {
                // Add a new Grid entity to your scene for the detected vertical plane
                let grid = GridEntity(planeAnchor: planeAnchor)
                
                parent.arView.scene.addAnchor(grid)
                grids.append(grid)
            }
            if let anchorName = anchor.name, anchorName == "Text" {
                parent.arView.placePostit(on: anchor, text: "test")
            }
        }
        
    }
    
    // [RealityKit – Visualizing Grid on detected planes](https://stackoverflow.com/a/71351712/521197)
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
        if let planeAnchor = anchors[0] as? ARPlaneAnchor,
           let updatedGrid = grids.first( where: { $0.planeAnchor.identifier == planeAnchor.identifier } ) {
            updatedGrid.didUpdate(anchor: planeAnchor)
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
