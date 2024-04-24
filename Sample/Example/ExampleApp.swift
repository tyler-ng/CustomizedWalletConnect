import Combine
import SwiftUI
import UIKit
import WalletConnectSign
import Web3Modal

#if DEBUG
import Atlantis
#endif


class SocketConnectionManager: ObservableObject {
    @Published var socketConnected: Bool = false
}

@main
class ExampleApp: App {
    private var disposeBag = Set<AnyCancellable>()
    private var socketConnectionManager = SocketConnectionManager()


    @State var alertMessage: String = ""

    required init() {
        #if DEBUG
        Atlantis.start()
        #endif

        let projectId = InputConfig.projectId

        let metadata = AppMetadata(
            name: "Web3Modal Swift Dapp",
            description: "Web3Modal DApp sample",
            url: "www.web3modal.com",
            icons: ["https://avatars.githubusercontent.com/u/37784886"],
            redirect: .init(native: "w3mdapp://", universal: nil)
        )

        Networking.configure(
            groupIdentifier: "group.com.metablox.app1",
            projectId: projectId,
            socketFactory: DefaultSocketFactory()
        )

        Web3Modal.configure(
            projectId: projectId,
            metadata: metadata,
            includeWebWallets: false,
            recommendedWalletIds: ["971e689d0a5be527bac79629b4ee9b925e82208e5168b733496a09c0faed0709"]
        ) { error in
            print(error)
        }
        
        setup()

    }

    func setup() {
        Web3Modal.instance.socketConnectionStatusPublisher.receive(on: DispatchQueue.main).sink { [unowned self] status in
            print("Socket connection status: \(status)")
            self.socketConnectionManager.socketConnected = (status == .connected)

        }.store(in: &disposeBag)
        Web3Modal.instance.logger.setLogging(level: .debug)
    }

    var body: some Scene {
        WindowGroup { [unowned self] in
            ContentView()
                .environmentObject(socketConnectionManager)
                .onOpenURL { url in
                    Web3Modal.instance.handleDeeplink(url)
                }
                .alert(
                    "Response",
                    isPresented: .init(
                        get: { !self.alertMessage.isEmpty },
                        set: { _ in self.alertMessage = "" }
                    )
                ) {
                    Button("Dismiss", role: .cancel) {}
                } message: {
                    Text(alertMessage)
                }
                .onReceive(Web3Modal.instance.sessionResponsePublisher, perform: { response in
                    switch response.result {
                    case let .response(value):
                        self.alertMessage = "Session response: \(value.stringRepresentation)"
                    case let .error(error):
                        self.alertMessage = "Session error: \(error)"
                    }
                })
        }
    }
}
