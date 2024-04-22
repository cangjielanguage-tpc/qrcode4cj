/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned.rss

/** Adapted from listings in ISO/IEC 24724 Appendix B and Appendix G. */
public class RSSUtils {
    private init() {}

    public static func getRSSvalue(widths: Array<Int64>, maxWidth: Int64, noNarrow: Bool): Int64 {
        var n: Int64 = 0;

        for (i in 0..widths.size) {
            n += widths[i]
        }
        var val: Int64 = 0;
        var narrowMask: Int64 = 0;
        var elements: Int64 = widths.size;
        for (bar in 0..elements - 1) {
            var elmWidth: Int64 = 1;
            narrowMask |= 1 << bar
            while (elmWidth < widths[bar]) {
                var subVal: Int64 = combins(n - elmWidth - 1, elements - bar - 2);
                if (noNarrow && (narrowMask == 0) && (n - elmWidth - (elements - bar - 1) >= elements - bar - 1)) {
                    subVal -= combins(
                        n - elmWidth - (elements - bar),
                        elements - bar - 2
                    )
                }
                if (elements - bar - 1 > 1) {
                    var lessVal: Int64 = 0;
                    var mxwElement: Int64 = n - elmWidth - (elements - bar - 2)
                    while (mxwElement > maxWidth) {
                        lessVal += combins(
                            n - elmWidth - mxwElement - 1,
                            elements - bar - 3
                        )

                        mxwElement--
                    }
                    subVal -= lessVal * (elements - 1 - bar)
                } else if (n - elmWidth > maxWidth) {
                    subVal--
                }
                val += subVal
                elmWidth++
                narrowMask &= !(1 << bar)
            }
            n -= elmWidth
        }
        return val
    }

    private static func combins(n: Int64, r: Int64): Int64 {
        var maxDenom: Int64
        var minDenom: Int64
        if (n - r > r) {
            minDenom = r
            maxDenom = n - r
        } else {
            minDenom = n - r
            maxDenom = r
        }
        var val: Int64 = 1;
        var j: Int64 = 1;

        var i: Int64 = n
        while (i > maxDenom) {
            val *= i
            if (j <= minDenom) {
                val /= j
                j++
            }
            i--
        }
        while (j <= minDenom) {
            val /= j
            j++
        }
        return val
    }
}
