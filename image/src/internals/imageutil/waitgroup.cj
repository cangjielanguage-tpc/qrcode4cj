package image.internals.imageutil

import std.sync.*

public class WaitGroup {
    var state: AtomicUInt32

    public init() {
        this.state = AtomicUInt32(0)
    }

    public func add(value: UInt32): WaitGroup {
        this.state.fetchAdd(value)
        this
    }

    public func done(): WaitGroup {
        this.state.fetchSub(1)
        this
    }

    public func wait() {
        while (true) {
            if (this.state.load() == 0) {
                return
            }
        }
    }
}
