import SwiftUI
import KeyboardShortcuts

struct DurationSettings: View {
    
    @EnvironmentObject
    private var sleepService: SleepService
    
    @AppStorage(StorageKeys.sleepDurations)
    private var durations: [SleepDuration] = StorageDefaults.sleepDurations
    
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
            
            Table($durations) {
                TableColumn("") { $item in
                    Button(action: { durations.move(item, offset: -1) }) {
                        Label("move-up", systemImage: "chevron.up").labelStyle(.iconOnly)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(durations.firstIndex { $0.id == item.id } == 0)
                    
                    Button(action: { durations.move(item, offset: 1) }) {
                        Label("move-down", systemImage: "chevron.down").labelStyle(.iconOnly)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(durations.firstIndex { $0.id == item.id } == durations.count - 1)
                }.width(20)
                
                TableColumn("label") { $item in
                    EditableText(
                        $item.label,
                        placeholder: $item.display(),
                        validator: { label in
                            if let label = label {
                                if durations.filter({ $0.id != item.id }).contains(where: { $0.label?.lowercased() == label.lowercased() }) {
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
                            } else if durations.filter({ $0.id != item.id }).contains(where: { $0.time == time }) {
                                return "error-duration-already-exists".localize(SleepDuration.display(time: time!))
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
        .frame(width: 410, height: 250)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
    }
    
    func addDuration() {
        let duration = SleepDuration(id: UUID(), label: nil, time: nil, notify: true)
        KeyboardShortcuts.onKeyUp(for: .init(duration.id.uuidString)) {
            if let time = duration.time {
                sleepService.disableFor(time)
            }
        }
        
        durations.append(duration)
    }
    
    func removeDuration(_ duration: SleepDuration) {
        KeyboardShortcuts.reset(.init(duration.id.uuidString))
        
        durations = durations.filter {
            $0.id != duration.id
        }
    }
    
}
