/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.qrcode.encoder

from std import collection.*

/**
 * JAVAPORT: The original code was a 2D array of ints, but since it only ever gets assigned
 * -1, 0, and 1, I'm going to use less memory and go with bytes.
 */
public class ByteMatrix <: ToString & Equatable<ByteMatrix> {
    private var bytes: Array<Array<Byte>>
    private var width: Int64
    private var height: Int64

    public init(width: Int64, height: Int64) {
        bytes = Array<Array<Byte>>(height, {a: Int64 => Array<Byte>(width, item: 255)})
        this.width = width
        this.height = height
    }

    public func getHeight(): Int64 {
        return height
    }

    public func getWidth(): Int64 {
        return width
    }

    public func get(x: Int64, y: Int64): Byte {
        return bytes[y][x]
    }

    /**
     * @return an internal representation as bytes, in row-major order. array[y][x] represents point (x,y)
     */
    public func getArray(): Array<Array<Byte>> {
        return bytes
    }

    public func set(x: Int64, y: Int64, value: Byte) {
        bytes[y][x] = value
    }

    @OverflowWrapping
    public func set(x: Int64, y: Int64, value: Int64) {
        bytes[y][x] = UInt8(value)
    }

    public func set(x: Int64, y: Int64, value: Bool) {
        bytes[y][x] = UInt8(if (value) {
                1
            } else {
                0
            })
    }

    public func clear(value: Byte) {
        for (i in 0..bytes.size) {
            for (item in 0..bytes[i].size) {
                bytes[i][item] = value
            }
        }
    }

    public func toString(): String {
        var result: ArrayList<Char> = ArrayList<Char>();
        for (y in 0..height) {
            let bytesY: Array<Byte> = bytes[y]
            for (x in 0..width) {
                match (bytesY[x]) {
                    case 0 => result.appendAll(" 0".toRuneArray());
                    case 1 => result.appendAll(" 1".toRuneArray());
                    case _ => result.appendAll("  ".toRuneArray());
                }
            }
            result.append('\n');
        }
        return String(result);
    }

    public operator func ==(rhs: ByteMatrix): Bool {
        if (this.width == rhs.width && this.height == rhs.height) {
            if (this.bytes.size != rhs.bytes.size) {
                return false;
            }
            for (i in 0..this.bytes.size) {
                if (this.bytes[i].size != rhs.bytes[i].size) {
                    return false;
                } else {
                    for (j in 0..this.bytes[i].size) {
                        if (this.bytes[i][j] != rhs.bytes[i][j]) {
                            return false;
                        }
                    }
                }
            }
            return true;
        } else {
            return false;
        }
    }

    public operator func !=(rhs: ByteMatrix): Bool {
        if (this.width == rhs.width && this.height == rhs.height) {
            if (this.bytes.size != rhs.bytes.size) {
                return true;
            }
            for (i in 0..this.bytes.size) {
                if (this.bytes[i].size != rhs.bytes[i].size) {
                    return true;
                } else {
                    for (j in 0..this.bytes[i].size) {
                        if (this.bytes[i][j] != rhs.bytes[i][j]) {
                            return true;
                        }
                    }
                }
            }
            return false;
        } else {
            return true;
        }
    }
}
