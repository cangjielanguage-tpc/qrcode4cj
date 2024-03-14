/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.common

/**
 * Thrown when a barcode was successfully detected and decoded, but
 * was not returned because its checksum feature failed.
 *
 * @author Sean Owen
 */
public open class ChecksumException <: ReaderException {
    private init() {
        super("ChecksumException")
    }

    private init(msg: String) {
        super("ChecksumException: ${msg}")
    }

    public static func getChecksumInstance(): ChecksumException {
        return ChecksumException()
    }
}
