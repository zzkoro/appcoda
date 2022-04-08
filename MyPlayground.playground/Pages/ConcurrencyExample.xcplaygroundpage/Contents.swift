//: [Previous](@previous)

import Foundation
import _Concurrency
import PlaygroundSupport

let page = PlaygroundPage.current
page.needsIndefiniteExecution = true

var greeting = "Hello, playground"

//: [Next](@next)
func listPhotos(inGallery name: String) async -> [String] {
    do {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
    } catch {}
    return ["IMG001", "IMG99", "IMG404"]
}

func downloadPhoto(named photoName: String) async -> String {
    do {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
    } catch {}
    return "Download Completed: \(photoName)"
}

Task.init {
    let handle = FileHandle.standardInput
    print("handle: \(handle)")
    for try await line in handle.bytes.lines {
        print(line)
    }
    
    let photoNames = await listPhotos(inGallery: "sample")
    
    /*
     * downloadPhoto가 return 될때까지 대기
     * 결과적으로 print가 수행되는 시점은 downloadPhoto 3번이 순차적으로
     * 수행이 완료된 후 수행이 됨
     */
//    let firstPhoto = await downloadPhoto(named: photoNames[0])
//    let secondPhoto = await downloadPhoto(named: photoNames[1])
//    let thirdPhoto = await downloadPhoto(named: photoNames[2])
//
//    print(firstPhoto, secondPhoto, thirdPhoto)
    
    /**
     * downloadPhoto를 동시에 수행하기 (concurrency)
     *
     */
    // 1) async let을 이용하여 동시에 수행하기 (async let에서 대기하지 않고 이후 await에서 대기한다.)
//    async let firstPhoto2 = downloadPhoto(named: photoNames[0])
//    async let secondPhoto2 = downloadPhoto(named: photoNames[1])
//    async let thirdPhoto2 = downloadPhoto(named: photoNames[2])
//
//    let photos = await [firstPhoto2, secondPhoto2, thirdPhoto2]
//
//    print(photos)
    
    // 2) taskGroup을 이용하여 동시에 수행하기 -> structured concurrency
    print("start: \(Thread.current), \(Date())")
    let photos = await withTaskGroup(of: String.self) { taskGroup -> [String] in
//        let photoNames = await listPhotos(inGallery: "sample")
        for name in photoNames {
            taskGroup.addTask {
                let photo = await downloadPhoto(named: name)
                return photo
            }
        }
        return await taskGroup.reduce(into: [String]()) { $0.append($1) }
    }
    print(photos)
    print("end: \(Thread.current), \(Date())")
    
    // unstructured concurrency
    // Task.init: 현재 actor에서 실행
    // Taks.detached: 현재 actor의 일부가 아닌 detached task
}

// Actors
// class와 같이 actor는 reference type
// class 와 달리 actor는 오직 한번에 하나의 task가 mutable state에 접근할 수 있도록 허락하며,
// 이로 인해 multiple task가 같은 actor instance와 interact 하는 것이 안전합니다.
actor TemperatureLogger {
    let label: String
    var measurements: [Int]
    private(set) var max: Int
    
    init(label: String, measurement: Int) {
        self.label = label
        self.measurements = [measurement]
        self.max = measurement
    }
}

extension TemperatureLogger {
    func update(with measurement: Int) {
        measurements.append(measurement)
        if measurement > max {
            max = measurement
        }
    }
}

let taskHandle = Task {
    let logger = TemperatureLogger(label: "Outdoors", measurement: 25)
    print(await logger.max)
    
}
print(taskHandle.isCancelled)



