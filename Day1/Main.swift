import Foundation

func deviceFrequency(applying changes: [Int]) -> Int {
    return changes.reduce(0, +)
}

func firstFrequencyReachedTwice(for changes: [Int]) -> Int {
    var sum = 0
    var seenFrequencies = Set<Int>()
    while true {
        for change in changes {
            sum += change
            let (inserted, _) = seenFrequencies.insert(sum)
            if !inserted { return sum }
        }
    }
}

do {
    let url = URL(fileURLWithPath: "input.txt")
    let input = try String(contentsOf: url)
    let changes = input.split(separator: "\n").map(String.init).compactMap(Int.init)
    print(deviceFrequency(applying: changes))
    print(firstFrequencyReachedTwice(for: changes))
} catch {
    print(error)
}

