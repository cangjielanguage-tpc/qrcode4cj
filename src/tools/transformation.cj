package tools

foreign func malloc(size: UIntNative): CPointer<Unit>
foreign func sprintf_s(ptr: CString, fmt: CString, ...): Int32
foreign func free(ptr: CPointer<Float32>): Unit

@OverflowWrapping
public func numberOfTrailingZeros(inData: Int64): Int64 {
    var data: Int64 = inData
    var length: Int64 = 0
    var count: Int64 = 0
    var array: Array<Int64> = Array<Int64>(32, item: 0)

    while (data / 2 != 0) {
        array[length] = data % 2
        length++
        data = data / 2
    }

    array[length] = data % 2
    length++

    for (i in 0..length) {
        if (array[i] == 0) {
            count++
        } else {
            break
        }
    }
    return count
}

@OverflowWrapping
public func intArraysHashCode(inData: Array<Int32>): Int64 {
    if (inData.size == 0) {
        return 0;
    }

    var result: Int64 = 1
    for (i in 0..inData.size) {
        result = 31 * result + Int64(inData[i])
    }

    return result
}

public func floatToIntBits(indata: Float32): Int64 {
    let sizeofFloat32: UIntNative = 4
    var pf2 = unsafe { malloc(sizeofFloat32) }
    var pfloat32 = unsafe { CPointer<Float32>(pf2) }
    unsafe { pfloat32.write(Float32(indata)) }
    var pInt64 = CPointer<Int64>(pfloat32)
    let outdata: Int64 = unsafe { pInt64.read() }
    unsafe { free(pfloat32) }
    return outdata
}

public func intToHexString(indata: Int64): String {
    let outdata: String
    unsafe {
        var fmt = LibC.mallocCString("%x")
        var ptr = LibC.mallocCString("")
        sprintf_s(ptr, fmt, indata)
        outdata = ptr.toString()
    }

    return outdata
}
