//
//  main.m
//  XcodeUpdatesService
//
//  Created by Ruslan Alikhamov on 03.01.2021.
//  Copyright © 2021 Ruslan Alikhamov. All rights reserved.
//

import Foundation

let delegate = XcodeUpdatesServiceDelegate()
let listener = NSXPCListener.service()
listener.delegate = delegate
listener.resume()
