//  Swish
//
//  Created by James Gillman on 6/21/20.
//  Copyright © 2020 SafetyPanda. All rights reserved.
//

import Foundation

let home = NSHomeDirectory()
let userName = NSUserName()
let fileManager = FileManager.default //NEEDED for file management
let historyFile = "\(home)/.swish_history"

class swish {

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
            if input == "quit" {
                exit(0)
            }
            
            let output = handleCommand(command: input)
            
            print(output, terminator:"")
        }
    }

    /*
     todo: make a better way to determine path.
     */
    @discardableResult func findPath(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/usr/bin/which" //Gotta get multiple paths
        task.arguments = [command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

        return output
    }

    @discardableResult func _shell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "\(command)" //Gotta get multiple paths
        //task.arguments = []

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

        return output
    }
    
    @discardableResult func handleCommand(command: String) -> String{
        let path = findPath("\(command)")
        print("DEBUG:",path, terminator:"")
        let result = path.filter { !$0.isWhitespace }
        let output = _shell("\(result)")
        return output
    }
    
    func swishShell() {
        startup()
        shellPrompt()
    }
}


