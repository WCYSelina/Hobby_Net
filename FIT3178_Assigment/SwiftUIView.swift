import SwiftUI

struct WeekPicker: View {
    @State private var currentDate = Date()
    
    var body: some View {
        HStack {
            Button(action: {
                updateCurrentDate(byAddingWeeks: -1)
            }) {
                Image(systemName: "arrow.left")
                    .font(.title)
            }
            .padding(.horizontal)
            
            Text(weekRange(for: currentDate))
                .font(.system(size: 20))
            
            Button(action: {
                updateCurrentDate(byAddingWeeks: 1)
            }) {
                Image(systemName: "arrow.right")
                    .font(.title)
            }
            .padding(.horizontal)
        }
    }
    
    private func updateCurrentDate(byAddingWeeks weeks: Int) {
        let newDate = Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: currentDate)!
        currentDate = newDate
    }
    
    private func weekRange(for date: Date) -> String {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        return "\(dateFormatter.string(from: startOfWeek)) - \(dateFormatter.string(from: endOfWeek))"
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            WeekPicker()
                .padding(.top)
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
