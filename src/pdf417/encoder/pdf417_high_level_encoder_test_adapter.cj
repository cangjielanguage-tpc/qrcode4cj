/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.pdf417.encoder

import QRCode4cj.tools.*
import QRCode4cj.common.*

// import java.nio.charset.Charset

/**
 * Test adapter for PDF417HighLevelEncoder to be called solely from unit tests.
 */
public open class PDF417HighLevelEncoderTestAdapter {
    private init() {}

    public static func encodeHighLevel(
        msg: String,
        compaction: Compaction,
        encoding: MyCharset,
        autoECI: Bool
    ): UTF32String {
        return PDF417HighLevelEncoder.encodeHighLevel(UTF32String(msg), compaction, encoding, autoECI)
    }
}
