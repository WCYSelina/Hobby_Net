//
//  ViewHobbyPage.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 24/4/2023.
//

import SwiftUI

struct ViewControllerWrapper: UIViewControllerRepresentable{
    
    var currentHobby:Hobby?
    weak var databaseController:DatabaseProtocol?
    var listenerType = ListenerType.record
    
    func makeUIViewController(context: Context) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddRecordViewController") as! AddRecordViewController
        viewController.currentHobby = currentHobby
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller
    }
}

class viewHobbyPageListener: NSObject, DatabaseListener {
    var listenerType = ListenerType.record
    @Published var notesList:[Notes] = []
    
    func onUserChange(change: DatabaseChange, hobbies: [Hobby]) {
    }
    
    func onHobbyChange(change: DatabaseChange, record: [Records]) {
    }
    
    func onRecordChange(change: DatabaseChange, notes: [Notes]) {
        notesList = notes
    }
    
    
    // Implement the required functions and properties of the protocol
    // ...
}

class DatabaseControllerModel: ObservableObject {
    weak var databaseController: DatabaseProtocol?
}

struct ViewHobbyPage: View{
    @State private var selectedDate = Date() //@State triggers update in the view when its value is changed
    @State private var navigateToAddRecord = false
    @State private var notesList:[Notes] = []
    @StateObject var databaseModel = DatabaseControllerModel()
    let listener = viewHobbyPageListener()
    var hobbyRecords:Hobby
    var body: some View {
        NavigationView{
            VStack {
                Text("").navigationBarTitle(hobbyRecords.name ?? "",displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                // Handle action
                                self.navigateToAddRecord = true
                                
                            }) {
                                Label("Add", systemImage: "plus")
                            }.sheet(isPresented: $navigateToAddRecord){
                                ViewControllerWrapper(currentHobby :hobbyRecords)
                            }
                        }
                    }
                DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical).offset(x:0,y:-20)
                ScrollView(.vertical,showsIndicators: true){
                    VStack{
                        Text("Selected date: \(selectedDate, formatter: dateFormatter)")
                        Text(hobbyRecords.name!)
                        ScrollView(.horizontal,showsIndicators: false){
                            HStack{
                                ForEach(notesList.indices) { index in
                                    Text(notesList[index].noteDetails!)
                                }
                            }
                        }
                    }
                }
            }
        }.onAppear{
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            databaseModel.databaseController = appDelegate?.databaseController
            databaseModel.databaseController?.addListener(listener: listener)
        }.onDisappear{
            databaseModel.databaseController?.removeListener(listener: listener)
        }.onReceive(listener.$notesList) { notes in //subcribe to the publisher variable
            // Update the notesList
            self.notesList = notes
        }
    }
    
    private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return formatter
        }()
}

struct ViewHobbyPage_Previews: PreviewProvider {
    static var previews: some View {
        ViewHobbyPage(hobbyRecords: Hobby())
    }
}
