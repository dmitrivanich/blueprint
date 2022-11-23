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

struct ContentView: View {
    @Environment (\.managedObjectContext) var managedObjectContext
    @Environment (\.dismiss) var dismiss
    
    @State private var vectorName = ""
    @State var showMenu: Bool = false
    
    @ObservedObject var viewModel: VectorsGame
    @State private var currentStatus = GameStatus.enableCamera
    
    static var fullScreen: CGSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.height)
    
    func sideMenuButtons() -> some View {
        HStack {
            Button{
                showMenu.toggle()
                print("show menu")
            } label: {
                ZStack{
                    Circle()
                        .frame(width: 50,height: 50)
                        .foregroundColor(Color(red: 0, green: 0.1, blue: 0.2).opacity(0.9))
                    if(showMenu) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "text.justify")
                            .foregroundColor(.white)
                    }
                }
            }.opacity(0.8)
            
            Spacer()
            
            Button(action: {
                self.currentStatus = self.currentStatus.isVectorCreating ? .enableCamera : .addVector
                viewModel.changeVectorCreatingStatus()
            }) {
                ZStack{
                    Circle()
                        .frame(width: 50,height: 50)
                        .foregroundColor(Color(red: 0, green: 0.1, blue: 0.2).opacity(0.9))
                    Text("\(self.currentStatus.isVectorCreating ? "✥🎥" : "+ ↖")")
//                        .font(.title)
                        .foregroundColor(.white.opacity(0.8))
                    
                }
            }


        }.padding(.top)
        
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                
                SpriteView(scene: VectorsScene($currentStatus))
                
                GeometryReader {_ in
                    HStack{
                        
                        VStack{
                            Text("Settings").foregroundColor(.white)
                                .frame(width: 100)
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
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                                sideMenuButtons()
                            }
                
                
            }
            
        }
    }
    
    
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        var game = VectorsGame()
        ContentView(viewModel: game)
    }
}
