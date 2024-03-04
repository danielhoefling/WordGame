struct StatisticsState: Equatable {
    var correctAttemptsCounter = 0
    var wrongAttemptsCounter = 0
    
    var attemptsCounter: Int {
        return correctAttemptsCounter + wrongAttemptsCounter
    }
}
