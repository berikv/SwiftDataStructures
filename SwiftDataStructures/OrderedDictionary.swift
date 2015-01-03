//
//  OrderedDictionary.swift
//
//  Created by Berik Visschers,  on 2015-01-03.
//  Copyright (c) 2015 Berik Visschers. All rights reserved.
//

struct OrderedDictionary<Key: Hashable, Value>: CollectionType, DictionaryLiteralConvertible {
    typealias Index = Int
    typealias Element = (key: Key, value: Value)
    
    private var _keys = [Key]()
    var keys: [Key] { return _keys }

    private var _values = [Value]()
    var values: [Value] { return _values }
    
    var startIndex: Index { return 0 }
    var endIndex: Index { return self.keys.endIndex }
    
    var count: Int { return self.keys.count }
    var isEmpty: Bool { return self.keys.isEmpty }
    
    var first: Element? {
        if let key = keys.first {
            if let value = values.first {
                return (key, value)
            }
        }
        return nil
    }
    
    var last: Element? {
        if let key = keys.last {
            if let value = values.last {
                return (key, value)
            }
        }
        return nil
    }

    func indexForKey(key: Key) -> Index? { return find(keys, key) }

    init() {}
    init(dictionaryLiteral elements: (Key, Value)...) {
        for element in elements {
            _keys.append(element.0)
            _values.append(element.1)
        }
    }
    
    func generate() -> GeneratorOf<Element> {
        var keysGenerator = keys.generate()
        var valuesGenerator = values.generate()
        return GeneratorOf {
            if let key = keysGenerator.next() {
                if let value = valuesGenerator.next() {
                    return (key, value)
                }
            }
            return nil
        }
    }
    
    mutating func append(#key: Key, value: Value) {
        _keys.append(key)
        _values.append(value)
    }
    
    mutating func removeLast() -> Element {
        let key = _keys.removeLast()
        let value = _values.removeLast()
        return (key, value)
    }
    
    mutating func insert(newElement: Element, atIndex index: Int) {
        let (key, value) = newElement
        _keys.insert(key, atIndex: index)
        _values.insert(value, atIndex: index)
    }
    
    mutating func updateValue(value: Value, forKey key: Key) -> Value? {
        if let position = find(keys, key) {
            let result = values[position]
            _values[position] = value
            return result
        } else {
            _keys.append(key)
            _values.append(value)
            return nil
        }
    }
    
    mutating func removeAtIndex(index: Index) {
        _keys.removeAtIndex(index)
        _values.removeAtIndex(index)
    }
    
    mutating func removeValueForKey(key: Key) -> Value? {
        if let position = find(keys, key) {
            let result = values[position]
            _keys.removeAtIndex(position)
            _values.removeAtIndex(position)
            return result
        } else {
            return nil
        }
    }
    
    mutating func removeAll(keepCapacity: Bool = false) {
        _keys.removeAll(keepCapacity: keepCapacity)
        _values.removeAll(keepCapacity: keepCapacity)
    }
    
    subscript(position: Index) -> Element {
        get {
            return (keys[position], values[position])
        }
        set(newValue) {
            let (key, value) = newValue
            if let position = find(keys, key) {
                _values[position] = value
            } else {
                _keys.append(key)
                _values.append(value)
            }
        }
    }
    
    subscript(key: Key) -> Value? {
        get {
            if let index = find(self.keys, key) {
                return values[index]
            }
            return nil
        }
        set(newValue) {
            if let value = newValue {
                if let index = find(self.keys, key) {
                    _values[index] = value
                } else {
                    _keys.append(key)
                    _values.append(value)
                }
            } else {
                if let index = find(self.keys, key) {
                    _keys.removeAtIndex(index)
                    _values.removeAtIndex(index)
                }
            }
        }
    }
    
    mutating func sort(isOrderedBefore: (Element, Element) -> Bool) {
        abort() // Exercise for the reader
    }
    
    func map<U>(transform: (Element) -> U) -> [U] {
        abort() // Exercise for the reader
    }
    
    func filter(includeElement: (Element) -> Bool) -> [Element] {
        abort() // Exercise for the reader
    }
    
    func reverse() -> OrderedDictionary {
        var result = OrderedDictionary<Key, Value>()
        result._keys = keys.reverse()
        result._values = values.reverse()
        return result
    }
}

extension OrderedDictionary: Printable, DebugPrintable {
    var debugDescription: String {
        return description
    }

    var description: String {
        var result = "{\n"
        for (index, (key, value)) in enumerate(self) {
            result += "[\(index)]: \(key) => \(value)\n"
        }
        result += "}"
        return result
    }
}
