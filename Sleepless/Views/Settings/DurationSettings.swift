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
                Text("double-click-edit")
                    .asHint()
                    .frame(alignment: .leading)
                
                Spacer()
                
                Button(action: { addDuration() }) {
                    Label("add-row", systemImage: "plus").labelStyle(.titleAndIcon)
                }.frame(alignment: .trailing)
            }
            
            Table($times) {
                TableColumn("label") { $item in
                    EditableText(
                        $item.label,
                        validator: { label in
                            if let label = label {
                                if times.filter({ $0.id != item.id }).contains(where: { $0.label?.lowercased() == label.lowercased() }) {
                                    return "error-label-already-exists".localize(label)
                                }
                            }
                            
                            return nil
                        })
                }
                
                TableColumn("duration") { $item in
                    EditableNumber(
                        $item.time,
                        formatter: { SleepDuration.display(time: $0) },
                        validator: { time in
                            if time == 0 {
                                return "error-one-minute".localize()
                            } else if times.filter({ $0.id != item.id }).contains(where: { $0.time == time }) {
                                return "error-duration-already-exists".localize(SleepDuration.display(time: time.unsafelyUnwrapped))
                            } else {
                                return nil
                            }
                        }
                    )
                }
                
                TableColumn("") { item in
                    Button(action: { removeDuration(item.wrappedValue) }) {
                        Label("remove-row", systemImage: "trash")
                            .labelStyle(.iconOnly)
                            .help("click-remove-row")
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
