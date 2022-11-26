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
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var vectors: FetchedResults<Vector>
    
    @State private var vectorName = ""
    @State var showMenu: Bool = false
    
    @ObservedObject var viewModel: VectorsGame
    @State private var currentStatus = GameStatus.enableCamera
    
    static var fullScreen: CGSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.height)

    var body: some View {
        ZStack {
            ZStack {
                
                SpriteView(scene: VectorsScene($currentStatus))
                
                sideMenuButtons()
                    .zIndex(10)
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .position(
                    x: UIScreen.main.bounds.width / 2,
                    y: UIScreen.main.bounds.height * 0.9
                )
                
                GeometryReader {_ in
                    HStack{
                        
                        VStack{
                            Text("Vectors").foregroundColor(.white)
                                .frame(width: 100)
                            List {
                                ForEach(vectors) {vector in
                                    Text(vector.name ?? "Unknown")
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
//            .toolbar {
//                ToolbarItemGroup(placement: .bottomBar) {
//                                sideMenuButtons()
//                    }
//            }
            
            
            
        }
    }
    //MARK: - delete items
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { vectors[$0] }.forEach(moc.delete)

            do {
                try moc.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)") 
            }
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
                
                let randomString = "@-\(Int.random(in: 0 ... 1000000))"
                let vector = Vector(context: moc)
                vector.id = UUID()
                vector.name = randomString
                try? moc.save()
                
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


        }.padding(.top)
        
    }
        
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = VectorsGame()
        ContentView(viewModel: game)
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
