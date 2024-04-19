/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned.rss.expanded.decoders

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
class AnyAIDecoder <: AbstractExpandedDecoder {
    private static var HEADER_SIZE: Int64 = 2 + 1 + 2

    init(information: BitArray) {
        super(information);
    }

    public func parseInformation(): String {
        var buf: ArrayList<Char> = ArrayList<Char>();
        return this.getGeneralDecoder().decodeAllCodes(buf, HEADER_SIZE);
    }
}
