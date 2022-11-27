import SwiftUI
import CoreData
import SpriteKit


enum GameStatus: String {
    case addVector, enableCamera
    
    var isVectorCreating: Bool {
        switch self {
        case .addVector: return .init(true)
        case .enableCamera: return .init(false)
        }
    }
}

var vectors: [Memory.Vector] = [] //ContainerView - 

struct ContentView: View {
    @FetchRequest(sortDescriptors: []) var vectors: FetchedResults<Vector>

    @StateObject private var dataController = DataController()
    
    @State private var vectorName = ""
    @State var showMenu: Bool = false
    @State var scene = VectorsScene()
    @State var isLandscape: Bool = false
    
    let a:CGPoint = CGPoint(
        x: UIScreen.main.bounds.height / 2,
        y: UIScreen.main.bounds.width * 0.9)
    
    let b:CGPoint = CGPoint(
        x: UIScreen.main.bounds.width / 2,
        y: UIScreen.main.bounds.height * 0.9)
    
    @ObservedObject var viewModel: VectorsGame = VectorsGame()
    @ObservedObject var vectorsData: VectorAsData = VectorAsData()
    
    
    @State private var currentStatus = GameStatus.enableCamera
    
    static var fullScreen: CGSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.height)

    func stringWithoutZero(_ value: CGFloat) -> String {
        return String(format: "%.2f", value)
    }
    
    var body: some View {
        ZStack {
            ZStack {
                SpriteView(scene: scene)
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    
                
                sideMenuButtons()
                    .zIndex(10)
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .position(
                        x: isLandscape ? a.x : b.x,
                        y: isLandscape ? a.y : b.y
                    )
                
                GeometryReader {_ in
                    HStack{
                        
                        VStack{
                            Text("Vectors").foregroundColor(.white)
                                .frame(width: 100)
                            
                            List {
                                ForEach(viewModel.vectors) {vector in
                                    VStack{
                                        HStack{
                                            Text("Id:\(vector.id)").font(.system(size:15))
                                            Spacer()
                                        }
                                        Text("Start: x:\(stringWithoutZero(vector.start.x)), y:\(stringWithoutZero(vector.start.y))").font(.system(size:10))
                                        Text("End: x:\(stringWithoutZero(vector.end.x)), y:\(stringWithoutZero(vector.end.y))").font(.system(size:10))
                                    }
                                }
                                .onDelete(perform: deleteItems)
                            }
                            
                            Spacer()
                        }
                        .frame(width: UIScreen.main.bounds.width / 3)
                        .background(Color.black.opacity(0.8))
                        .edgesIgnoringSafeArea(.bottom)
                    }.offset(x: showMenu ?  0 : -(UIScreen.main.bounds.width / 3))
                        .animation(.easeInOut(duration: 0.4), value: showMenu)
                }
            }
            .background(Color(red: 0.04, green: 0.16, blue: 0.3))
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                            isLandscape = UIDevice.current.orientation.isLandscape
                            print(isLandscape)
                            scene.set(isLandscape)
                        }
        }
    }
    //MARK: - delete items
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
//            offsets.map { vectors[$0] }.forEach(moc.delete)
//
//            do {
//                try moc.save()
//            } catch {
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
        }
    }
    
    //MARK: - side menu buttons
    private func sideMenuButtons() -> some View {
        HStack {
            Button{
                showMenu.toggle()
            } label: {
                ZStack{
                    Circle()
                        .frame(width: 50,height: 50)
                        .foregroundColor(Color(red: 0, green: 0.1, blue: 0.2).opacity(0.9))
                    if(showMenu) {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.white)
                    } else {
                        
                        Image(systemName: "list.bullet")
                            .foregroundColor(.white)
                    }
                }
            }.opacity(0.8)
            
            Spacer()
            
            Button(action: {
                self.currentStatus = self.currentStatus.isVectorCreating ? .enableCamera : .addVector
                viewModel.changeVectorCreatingStatus()
                scene.setStatus(self.currentStatus.isVectorCreating ? true : false)

            }) {
                ZStack{
                    Circle()
                        .frame(width: 50,height: 50)
                        .foregroundColor(Color(red: 0, green: 0.1, blue: 0.2).opacity(0.9))
                    
                    if(self.currentStatus.isVectorCreating){
                        Image(systemName: "hand.draw").foregroundColor(.white.opacity(0.8))
                    } else {
                        Image(systemName: "plus").foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            
            Button(action: {
                let savedVector = VectorAsData.lastVector
                
                let newVector = Memory.Vector(
                    id: viewModel.vectors.count + 1,
                    start: CGPoint(x: savedVector!.startX, y: savedVector!.startY),
                    end: CGPoint(x: savedVector!.endX, y: savedVector!.endY),
                    color: savedVector!.color
                )
                
                print(newVector)
                viewModel.addVector(newVector)
            }) {
                ZStack{
                    Circle()
                        .frame(width: 50,height: 50)
                        .foregroundColor(Color(red: 0, green: 0.1, blue: 0.2).opacity(0.9))
                    
                    Image(systemName: "opticaldisc.fill").foregroundColor(.white.opacity(0.8))
                }
            }


        }.padding(.top)
        
    }
        
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
