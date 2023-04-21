import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {

    let arModel = ARModel()

    var body: some View {
        ARViewContainer(arModel: arModel)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture(coordinateSpace: .global) { location in
                arModel.addPortal(at: location)
            }
    }
}

struct ARViewContainer: UIViewRepresentable {

    let arModel: ARModel

    init(arModel: ARModel) {
        self.arModel = arModel
    }

    func makeUIView(context: Context) -> ARSCNView {

        let view = ARSCNView()

        let session = view.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)

        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        view.addSubview(coachingOverlay)

        context.coordinator.sceneView = view

        return view
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    func makeCoordinator() -> ARModel {
        arModel
    }
}

class ARModel {

    var sceneView: ARSCNView?

    init() {}

    func addPortal(at touchPoint: CGPoint) {
        guard
            let query = sceneView?.raycastQuery(from: touchPoint, allowing: .existingPlaneGeometry, alignment: .horizontal),
            let result = sceneView?.session.raycast(query).first
        else {
            return
        }

        guard let portalNode = createPortalNode() else { return }

        portalNode.position = SCNVector3(
            x: result.worldTransform.columns.3.x,
            y: result.worldTransform.columns.3.y + 0.05, // slightly above the plane
            z: result.worldTransform.columns.3.z
        )

        sceneView?.scene.rootNode.addChildNode(portalNode)
    }

    private func createPortalNode() -> SCNNode? {
        guard
            let scene = SCNScene(named: "art.scnassets/portal.scn"),
            let portalNode = scene.rootNode.childNode(withName: "portal", recursively: true)
        else {
            return nil
        }

        return portalNode
    }

}
