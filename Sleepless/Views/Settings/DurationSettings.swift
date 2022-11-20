import SwiftUI
import KeyboardShortcuts

struct TimesSettings: View {
    
    @EnvironmentObject
    private var sleepService: SleepService
    
    @AppStorage(StorageKeys.sleepDurations)
    private var times: [SleepDuration] = StorageDefaults.sleepDurations
    
    var body: some View {
        VStack {
            HStack {
                Text("Double click on a cell to edit")
                    .asHint()
                    .frame(alignment: .leading)
                
                Spacer()
                
                Button(action: { self.addDuration() }) {
                    Label("Add row", systemImage: "plus").labelStyle(.titleAndIcon)
                }.frame(alignment: .trailing)
            }
            
            Table($times) {
                TableColumn("Label") { $item in
                    EditableText($item.label)
                }
                
                TableColumn("Duration") { $item in
                    EditableNumber(
                        $item.time,
                        formatter: { "\($0) minutes" },
                        validator: { time in
                            if time == 0 {
                                return "Duration must be at least one minute"
                            } else if times.filter({ $0.id != item.id }).contains(where: { $0.time == time }) {
                                return "Duration \(time.unsafelyUnwrapped) minutes already exists"
                            } else {
                                return nil
                            }
                        }
                    )
                }
                
                TableColumn("") { item in
                    Button(action: { self.removeDuration(item.wrappedValue) }) {
                        Label("Delete row", systemImage: "trash").labelStyle(.iconOnly)
                    }.buttonStyle(PlainButtonStyle())
                }.width(20)
            }
        }
        .frame(width: 390, height: 250)
        .padding(10)
    }
    
    func addDuration() {
        let duration = SleepDuration(id: UUID(), label: nil, time: nil, notify: true)
        KeyboardShortcuts.onKeyUp(for: .init(duration.id.uuidString)) {
            if let time = duration.time {
                sleepService.disableFor(time)
            }
        }
        
        times.append(duration)
    }
    
    func removeDuration(_ duration: SleepDuration) {
        KeyboardShortcuts.reset(.init(duration.id.uuidString))
        
        times = times.filter {
            $0.id != duration.id
        }
    }
    
}
