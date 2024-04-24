import SwiftUI
import Web3Modal

struct ContentView: View {
    @State var showUIComponents: Bool = false
    @EnvironmentObject var socketConnectionManager: SocketConnectionManager


    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Web3ModalButton()
                
//                Web3ModalNetworkButton()
                
                Spacer()
                
            }
        }
    }
}
