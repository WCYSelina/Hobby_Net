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
    var listenerType = ListenerType.note
    
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
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {

    }
    
    func onRecordChange(change: DatabaseChange, record: [Notes]) {
        Task{
            DispatchQueue.main.async{
                print("onRecordChange")
                self.notesList = record
            }
        }
    }
    
    func onNoteChange(change: DatabaseChange, notes: [Notes]) {
    }
    
    
    
    // Implement the required functions and properties of the protocol
    // ...
}

class DatabaseControllerModel: ObservableObject {
    weak var databaseController: DatabaseProtocol?
}

struct ViewHobbyPage: View{
    @State private var selectedDate = Date() //@State triggers update in the view when its value is changed
    private let dateToString: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
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
                DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical).offset(x:0,y:-20).onChange(of: selectedDate){ date in
                        databaseModel.databaseController?.showCorrespondingRecord(hobby: hobbyRecords,date: dateToString.string(from: date)){() in
                            //
                        }
                    }
                Text("Records on \(selectedDate, formatter: dateFormatter)").font(.title3.bold())
                ScrollView(.vertical,showsIndicators: true){
                    VStack{
                        Text("")
                        ForEach(notesList.indices, id: \.self) { index in
                            Text(notesList[index].noteDetails ?? "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 5).fill(Color.gray.opacity(0.2)))
                            Text("")
                        }
                    }
                }
            }
        }.onAppear{
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            databaseModel.databaseController = appDelegate?.databaseController
            databaseModel.databaseController?.addListener(listener: listener)
//            databaseModel.databaseController?.showCorrespondingRecord(hobby: hobbyRecords)
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
