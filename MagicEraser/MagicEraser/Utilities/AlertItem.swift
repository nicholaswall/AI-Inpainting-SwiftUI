//
//  AlertItem.swift
//  MagicEraser
//
//  Created by Nick Wall on 12/7/22.
//

import Foundation
import SwiftUI

struct AlertItem: Identifiable {
    var id: UUID = UUID()
    var title: Text
    var message: Text
    var dismissButton: Alert.Button?
}

enum AlertContext {
    static let invalidURL = AlertItem(title: Text("Server Error"),
                                      message: Text("An error occured on the server. Check server logs for more information."),
                                      dismissButton: .default(Text("Ok"))
    )
    static let unableToComplete = AlertItem(title: Text("Server Error"),
                                            message: Text("Unable to complete network request."),
                                            dismissButton: .default(Text("Ok"))
    )
    static let invalidResponse = AlertItem(title: Text("Server Error"),
                                           message: Text("Invalid response from the server."),
                                           dismissButton: .default(Text("Ok"))
    )
    static let invalidData = AlertItem(title: Text("Server Error"),
                                       message: Text("The data recieved from the server was invalid."),
                                       dismissButton: .default(Text("Ok"))
    )
}
