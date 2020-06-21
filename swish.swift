#!/usr/bin/env swift

// swish: Swift Shell: Unix Shell Written in Swift
// Copyright (c) James Gillman [jronaldgillman@gmail.com], gitlab: @safetypanda


import Foundation


let userName = NSUserName()
let home = NSHomeDirectory()

let fileManager = FileManager.default //NEEDED for file management

let historyFile = "\(home)/.swish_history"

func greeting(user: String) -> String {
    let start = """
    Greetings, \(user). Welcome to Swish.
    Home Directory: \(home)
    Current Folder: \(fileManager.currentDirectoryPath)
    ---------------------------------------------------
    
    """
    return start
}

func createHistory() {
    let dataToWrite = "SWISH HISTORY".data(using: .utf8)
    if !fileManager.fileExists(atPath: historyFile) {
        fileManager.createFile(atPath: historyFile,
        contents: dataToWrite)
    }
}

func startup() {
    print(greeting(user: userName))
    createHistory()
}

func shellPrompt() {
    while true {
        let curDir = fileManager.currentDirectoryPath

        print("[\(curDir)]~> ", terminator:"")
        let input = readLine() ?? ""

        let output = shell("\(input)")
        print(output, terminator:"")
    }
}

@discardableResult func shell(_ command: String) -> String {
    let task = Process()
    task.launchPath = "/usr/bin/\(command)" //Gotta get multiple paths
    //task.arguments = [command]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

    return output
}



startup()
shellPrompt()
