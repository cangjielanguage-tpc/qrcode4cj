/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.qrcode.encoder

import QRCode4cj.qrcode.decoder.ErrorCorrectionLevel
import QRCode4cj.qrcode.decoder.Mode
import QRCode4cj.qrcode.decoder.Version
import std.collection.*

public class QRCode {
    public static let NUM_MASK_PATTERNS: Int64 = 8;

    private var mode: Mode = TERMINATOR([0, 0, 0], 0x00);
    private var ecLevel: ErrorCorrectionLevel = ErrorCorrectionLevel.M(0x00);
    private var version: ?Version = None
    private var maskPattern: Int64 = 0;
    private var matrix: ?ByteMatrix = None

    public init() {
        maskPattern = -1
    }

    /**
     * @return the mode. Not relevant if {@link com.google.zxing.EncodeHintType#QR_COMPACT} is selected.
     */
    public func getMode(): Mode {
        return mode
    }

    public func getECLevel(): ErrorCorrectionLevel {
        return ecLevel
    }

    public func getVersion(): Version {
        return version.getOrThrow();
    }

    public func getMaskPattern(): Int64 {
        return maskPattern
    }

    public func getMatrix(): ByteMatrix {
        return matrix.getOrThrow();
    }

    public func toString(): String {
        var result: ArrayList<Rune> = ArrayList<Rune>();
        result.add(all:"<<\n".toRuneArray());
        result.add(all:" mode: ".toRuneArray());
        if (mode == Mode.TERMINATOR([0, 0, 0], 0x00)) {
            result.add(all:"null".toRuneArray());
        } else {
            result.add(all:mode.toString().toRuneArray());
        }
        result.add(all:"\n ecLevel: ".toRuneArray());
        result.add(all:ecLevel.toString().toRuneArray());
        if (let Some(v) <- version) {
            result.add(all:"\n version: ".toRuneArray());
            result.add(all:v.toString().toRuneArray());
        } else {
            result.add(all:"\n version: null".toRuneArray());
        }

        result.add(all:"\n maskPattern: ".toRuneArray());
        result.add(all:maskPattern.toString().toRuneArray());
        if (let Some(m) <- matrix) {
            result.add(all:"\n matrix:\n".toRuneArray());
            result.add(all:m.toString().toRuneArray());
        } else {
            result.add(all:"\n matrix: null\n".toRuneArray());
        }
        result.add(all:">>\n".toRuneArray());
        return String(result);
    }

    public func setMode(value: Mode) {
        mode = value
    }

    public func setECLevel(value: ErrorCorrectionLevel) {
        ecLevel = value
    }

    public func setVersion(version: Version) {
        this.version = version
    }

    public func setMaskPattern(value: Int64) {
        maskPattern = value
    }

    public func setMatrix(value: ByteMatrix) {
        matrix = value
    }

    // Check if "mask_pattern" is valid.
    public static func isValidMaskPattern(maskPattern: Int64): Bool {
        return maskPattern >= 0 && maskPattern < NUM_MASK_PATTERNS
    }
}
