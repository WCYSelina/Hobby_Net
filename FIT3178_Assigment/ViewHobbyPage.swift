//
//  ViewHobbyPage.swift
//  FIT3178_Assigment
//
//  Created by Ching Yee Selina Wong on 24/4/2023.
//

import SwiftUI

struct ViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "AddRecordViewController")
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller
    }
}

struct ViewHobbyPage: View {
    @State private var selectedDate = Date()
    @State private var navigateToAddRecord = false
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
                                ViewControllerWrapper()
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
                                Text("Horizontal Content 1")
                                Text("Horizontal Content 2")
                                Text("Horizontal Content 3")
                            }
                        }
                    }
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

struct ViewHobbyPage_Previews: PreviewProvider {
    static var previews: some View {
        ViewHobbyPage(hobbyRecords: Hobby())
    }
}
