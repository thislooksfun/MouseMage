//
//  Shell.swift
//  MouseMage
//
//  Created by thislooksfun on 12/10/19.
//  Copyright © 2019 thislooksfun. All rights reserved.
//

import Foundation

// Generate:
//   openssl req -x509 -newkey rsa:4096 -passout pass:"MouseMage" -keyout key.pem -out cert.pem -days 365 -subj "/"
// Convert:
//   openssl pkcs12 -export -in cert.pem -inkey key.pem -passin pass:"MouseMage" -out Cert.p12 -passout pass:"MouseMage"


/// Run a shell command
///
/// - Attention:
///   This is run **synchronously** and thus will block until completed.
///   If you need it to run asynchronously, use `shell(_:arguments:cb:)` instead
///
/// - Parameters:
///   - launchPath: The command to launch
///   - arguments: The arguments to pass to the command
///
/// - Returns: The output of the command
@discardableResult
func shell(_ launchPath: String, arguments args: [String] = []) -> String? {
  print("Running shell command '\(launchPath)'")
  
  let task = Process()
  task.launchPath = launchPath
  task.arguments = args
  
  let pipe = Pipe()
  task.standardOutput = pipe
  task.launch()
  
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  let output = String(data: data, encoding: .utf8)
  
  return output
}

/// Run a shell command
///
/// This is the asynchronous form of `shell(_:arguments:)`
///
/// - Note:
///   This will run the command on a background queue,
///   and will call the callback on the main queue.
///
/// - Parameters:
///   - launchPath: The command to launch
///   - arguments: The arguments to pass to the command
///   - cb: The callback to execute when the command is finished
func shell(_ launchPath: String, arguments args: [String] = [], cb: @escaping (String?) -> Void) {
  DispatchQueue.global(qos: .background).async {
    let out = shell(launchPath, arguments: args)
    DispatchQueue.main.async { cb(out) }
  }
}

/// Run a bash command
///
/// - Attention:
///   This is run **synchronously** and thus will block until completed.
///   If you need it to run asynchronously, use `bash(_:cb:)` instead
///
/// - Parameters:
///   - launchPath: The command to run
///
/// - Returns: The output of the command
@discardableResult
func bash(_ command: String) -> String? {
  return shell("/bin/bash", arguments: ["-c", command])
}

/// Run a bash command
///
/// This is the asynchronous form of `bash(_:arguments:)`
///
/// - Note:
///   This will run the command on a background queue,
///   and will call the callback on the main queue.
///
/// - Parameters:
///   - command: The command to run
///   - cb: The callback to execute when the command is finished
func bash(_ command: String, cb: @escaping (String?) -> Void) {
  DispatchQueue.global(qos: .background).async {
    let out = bash(command)
    DispatchQueue.main.async { cb(out) }
  }
}
