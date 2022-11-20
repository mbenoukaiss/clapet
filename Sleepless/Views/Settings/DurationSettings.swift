import SwiftUI
import KeyboardShortcuts

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

struct TimesSettings: View {
    
    @AppStorage(StorageKeys.sleepDurations)
    private var times: [SleepDuration] = StorageKeys.initial(StorageKeys.sleepDurations)
    
    var body: some View {
        VStack(alignment: .trailing) {
            Button(action: { self.addDuration() }) {
                Label("Add row", systemImage: "plus").labelStyle(.titleAndIcon)
            }
            
            Table($times) {
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
                
                TableColumn("Shortcut") { item in
                    KeyboardShortcuts.Recorder("", name: KeyboardShortcuts.Name(item.id.uuidString))
                }
                
                TableColumn("") { item in
                    Button(action: { self.removeDuration(item.wrappedValue) }) {
                        Label("Delete row", systemImage: "trash").labelStyle(.iconOnly)
                    }.buttonStyle(PlainButtonStyle())
                }.width(20)
            }
        }.padding(10)
    }
    
    func addDuration() {
        times.append(SleepDuration(id: UUID(), time: 0))
    }
    
    func removeDuration(_ duration: SleepDuration) {
        times = times.filter {
            $0.id != duration.id
        }
    }
    
}
