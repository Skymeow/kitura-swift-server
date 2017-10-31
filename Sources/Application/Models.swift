//
//  Models.swift
//  ToDoServerPackageDescription
//
//  Created by Sky Xu on 10/31/17.
//

import Foundation
//creates a struct for the ToDo items
public struct ToDo : Codable {
    public var user: String?
    public var title: String?
    public var order: Int?
    public var completed: Bool?
    public var url: String?
}
