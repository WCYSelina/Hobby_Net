//
//  ViewHobbyPage.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 24/4/2023.
//

import SwiftUI
import Combine

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
    @Published var hobby:Hobby?
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {

    }
    
    func onRecordChange(change: DatabaseChange, record: [Notes]) {
        Task{
            DispatchQueue.main.async{
                self.notesList = record
            }
        }
    }
    
    func onNoteChange(change: DatabaseChange, notes: [Notes]) {
    }
    
    func onHobbyRecordFirstChange(change:DatabaseChange, hobby:Hobby){
        self.hobby = hobby
    }
}

class weeklyViewHobbyNSObject:NSObject, DatabaseListener {
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {
    }
    
    func onRecordChange(change: DatabaseChange, record: [Notes]) {
    }
    
    func onNoteChange(change: DatabaseChange, notes: [Notes]) {
    }
    
    func onHobbyRecordFirstChange(change: DatabaseChange, hobby: Hobby) {
    }
    
    var listenerType = ListenerType.record
}

class DatabaseControllerModel: ObservableObject {
    weak var databaseController: DatabaseProtocol?
}

struct ViewHobbyPage: View{
    var dateString:String
    var startOfWeek:Date
    var endOfWeek:Date
    @State private var navigateToAddRecord = false
    @State private var notesList:[Notes] = []
    @StateObject private var databaseModel = DatabaseControllerModel() //@StateObject ensures that the object is only created once during the view's lifecycle and is not destroyed and recreated during updates.
    let listener = viewHobbyPageListener()
//    var hobbyRecords:Hobby
    @State var hobby:Hobby
    @State private var selectedSegmentedIndex = 0
    private let segments = ["Daily","Weekly"]
    var body: some View {
        NavigationView{
            ZStack{
                VStack {
                    Text("").navigationBarTitle(hobby.name ?? "",displayMode: .inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    // Handle action
                                    self.navigateToAddRecord = true
                                    
                                }) {
                                    Label("Add", systemImage: "plus")
                                }.sheet(isPresented: $navigateToAddRecord){
                                    ViewControllerWrapper(currentHobby :hobby)
                                }
                            }
                        }
                    Picker(selection: $selectedSegmentedIndex, label: Text("Select a segment")){
                        ForEach(0..<segments.count) { index in
                            Text(segments[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    VStack{
                        switch selectedSegmentedIndex{
                        case 0:
                            DailyPage(hobby: hobby, databaseModel: databaseModel, notesList: $notesList).onAppear{
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "dd MMM yyyy"
                                databaseModel.databaseController?.showCorrespondingRecord(hobby: hobby,date: dateFormatter.string(from: Date())){() in
                                    //
                                }
                            }
                            
                        case 1:
                            WeeklyPage(hobby: hobby,weekToAssign: (endOfWeek,startOfWeek,dateString))
                        default:
                            Text("none")
                        }
                        Spacer()
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
        }.onReceive(listener.$hobby) { hobby in
            if let hobby = hobby{
                self.hobby = hobby
            }
        }
    }
}

struct DailyPage:View{
    private let dateToString: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    @State var hobby:Hobby
    @State private var selectedDate = Date() //@State triggers update in the view when its value is changed
    @StateObject var databaseModel:DatabaseControllerModel
    @Binding var notesList:[Notes]
    var body: some View{
        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
            .datePickerStyle(.graphical).offset(x:0,y:-20).onChange(of: selectedDate){ date in
                databaseModel.databaseController?.showCorrespondingRecord(hobby: hobby,date: dateToString.string(from: date)){() in
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
    private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return formatter
        }()
}


struct WeeklyPage:View{
    @State var hobby:Hobby
    @State private var currentDate = Date()
    @StateObject var databaseModel = DatabaseControllerModel()
    @State var weekToAssign:(startWeek:Date,endWeek:Date,dateString:String)
    let listener = viewHobbyPageListener()

    var body: some View{
        NavigationView{
            VStack{
                HStack {
                    Button(action: {
                        updateCurrentDate(byAddingWeeks: -1)
                        weekToAssign = weekRange(for: currentDate)
                        databaseModel.databaseController?.showRecordWeekly(hobby: hobby, startWeek: weekToAssign.startWeek, endWeek: weekToAssign.endWeek) {
                            // completion handler code
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title)
                    }
                    .padding(.horizontal)
                    Text(weekToAssign.dateString)
                    
                    Button(action: {
                        updateCurrentDate(byAddingWeeks: 1)
                        weekToAssign = weekRange(for: currentDate)
                        databaseModel.databaseController?.showRecordWeekly(hobby: hobby, startWeek: weekToAssign.startWeek, endWeek: weekToAssign.endWeek) {
                            // completion handler code 
                        }
                    }) {
                        Image(systemName: "arrow.right")
                            .font(.title)
                    }
                    .padding(.horizontal)
                }
                Spacer()
                
            }
        }.onAppear{
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            databaseModel.databaseController = appDelegate?.databaseController
            databaseModel.databaseController?.addListener(listener: listener)
            weekToAssign = weekRange(for: Date())
            databaseModel.databaseController?.showRecordWeekly(hobby: hobby, startWeek: weekToAssign.startWeek, endWeek: weekToAssign.endWeek) {() in
                // completion handler code
                print("000")
                
            }
        }.onDisappear{
                databaseModel.databaseController?.removeListener(listener: listener)
        }
    }
    private func updateCurrentDate(byAddingWeeks weeks: Int) {
        let newDate = Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: currentDate)!
        currentDate = newDate
    }
    
    private func weekRange(for date: Date) -> (startWeek:Date,endWeek:Date,dateString:String) {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        print("startOfWeek\(startOfWeek)")
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let dateString = "\(dateFormatter.string(from: startOfWeek)) - \(dateFormatter.string(from: endOfWeek))"

        return (startOfWeek,endOfWeek,dateString)
    }
}
//struct ViewHobbyPage_Previews: PreviewProvider {
//    static var previews: some View {
//        ViewHobbyPage(hobby: Hobby(),startWeek: ,endWeek: )
//    }
//}
