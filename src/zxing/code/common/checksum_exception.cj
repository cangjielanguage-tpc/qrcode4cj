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
public open class Qrcoder4cjChecksumException <: Qrcoder4cjReaderException {
    private init() {
        super("Qrcoder4cjChecksumException")
    }

    private init(msg: String) {
        super("Qrcoder4cjChecksumException: ${msg}")
    }

    public static func getChecksumInstance(): Qrcoder4cjChecksumException {
        return Qrcoder4cjChecksumException()
    }
}
