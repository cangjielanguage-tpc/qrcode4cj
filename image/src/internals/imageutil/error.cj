/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * THis file is about Exception
 */
package image.internals.imageutil

/**
 * The class is EOF inherited from Exception
 * @author changeden
 */
public class EOF <: Exception {
    /**
     * The Function is init constructor
     *
     */
    public init() {
        super("EOF")
    }
}

/**
 * The class is ErrUnexpectedEOF inherited from Exception
 * @author changeden
 */
public class ErrUnexpectedEOF <: Exception {
    /**
     * The Function is init constructor
     *
     */
    public init() {
        super("unexpected EOF")
    }
}

/**
 * The class is ErrShortBuffer inherited from Exception
 * @author changeden
 */
public class ErrShortBuffer <: Exception {
    /**
     * The Function is init constructor
     *
     */
    public init() {
        super("short buffer")
    }
}

/**
 * The class is ErrNoProgress inherited from Exception
 * @author changeden
 */
public class ErrNoProgress <: Exception {
    /**
     * The Function is init constructor
     *
     */
    public init() {
        super("multiple Read calls return no data or error")
    }
}
