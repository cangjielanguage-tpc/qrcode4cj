/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned

import std.collection.*
import QRCode4cj.tools.*
import QRCode4cj.common.*
import std.math.*

open class UPCEANExtensionSupport {
    private static let EXTENSION_START_PATTERN: Array<Int64> = [1, 1, 2]

    private let twoSupport: UPCEANExtension2Support = UPCEANExtension2Support();
    private let fiveSupport: UPCEANExtension5Support = UPCEANExtension5Support();

    public func decodeRow(rowNumber: Int64, row: BitArray, rowOffset: Int64): ?Result {
        try {
            var extensionStartRange: Array<Int64> = UPCEANReader.findGuardPattern(
                row,
                rowOffset,
                false,
                EXTENSION_START_PATTERN
            );

            try {
                return fiveSupport.decodeRow(rowNumber, row, extensionStartRange);
            } catch (ignored: Qrcoder4cjReaderException) {
                return twoSupport.decodeRow(rowNumber, row, extensionStartRange);
            }
        } catch (ignored: Qrcoder4cjReaderException) {
            return None
        }
    }
}
