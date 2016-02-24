// RealmDefaults.swift
//
// Copyright (c) 2015 muukii
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import RealmSwift

#if os(iOS)
    private let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
#elseif os(OSX)
    private let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
#endif

public protocol RealmDefaultsType: class {
    
    static func write(@noescape block: (Self) -> Void)
    static func configuration() -> RealmSwift.Realm.Configuration
}

extension RealmDefaultsType where Self: RealmDefaults {
    
    public static func write(@noescape block: (Self) -> Void) {
        self.init()
        do {
            let realm = try Realm(configuration: self.configuration())
            var object = realm.objectForPrimaryKey(self, key: primaryKeyValue)
            if object == nil {
                object = try self.create(realm)
            }
            try realm.write {
                block(object!)
            }
        } catch {
            // TODO:
        }
    }
    
    public static var instance: Self {
        do {
            let realm = try Realm(configuration: self.configuration())
            if let object = realm.objectForPrimaryKey(self, key: primaryKeyValue) {
                return object
            }
            
            return try self.create(realm)
        } catch {
            // TODO:
            fatalError("RealmDefaults Fatal Error: Failed to create Realm \(error)")
        }
    }
    
    private static func create(realm: Realm) throws -> Self {
        let object = self.init()
        try realm.write {
            realm.add(object, update: true)
        }
        return object
    }
}

private let primaryKeyValue = "RealmDefaults"

public class RealmDefaults: RealmSwift.Object, RealmDefaultsType {
    
    public class func purge() {
        do {
            let realm = try Realm(configuration: self.configuration())
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            // TODO:
        }
    }
    
    public class func schemaVersion() -> UInt64 {
        
        preconditionFailure("Required override this method.")
    }
    
    public class func defaultsName() -> String {
        
        return NSStringFromClass(self)
    }
    
    public class func filePath() -> String {
        
        return documentsPath + "/RealmDefaults_\(self.defaultsName()).realm"
    }
    
    public class func configuration() -> RealmSwift.Realm.Configuration {
        
        return RealmSwift.Realm.Configuration(
            path: self.filePath(),
            inMemoryIdentifier: nil,
            encryptionKey: nil,
            readOnly: false,
            schemaVersion: self.schemaVersion(),
            migrationBlock: { (migration, oldSchemaVersion) -> Void in
            
            },
            objectTypes: [self])
    }
    
    
    // MARK: Object
    public final override class func primaryKey() -> String? {
        return "__identifier"
    }
    
    // MARK: Internal
    internal dynamic var __identifier: String = primaryKeyValue

}
