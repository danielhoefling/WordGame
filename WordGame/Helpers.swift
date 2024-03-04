func trueWithProbability(percentage: Double) -> Bool {
    let randomNumber = Double.random(in: 0.0..<1.0)
    return randomNumber < (percentage / 100)
}

func getRandomElements<T>(from array: [T]) -> (T, T)? {
    guard array.count >= 2 else { return nil }
    
    let firstIndex = Int.random(in: 0..<array.count)
    var secondIndex = Int.random(in: 0..<array.count)
    
    while secondIndex == firstIndex {
        secondIndex = Int.random(in: 0..<array.count)
    }
    
    let firstElement = array[firstIndex]
    let secondElement = array[secondIndex]
    
    return (firstElement, secondElement)
}
