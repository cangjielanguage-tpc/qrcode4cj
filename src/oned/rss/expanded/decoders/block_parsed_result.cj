/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned.rss.expanded.decoders

class BlockParsedResult {
    private var decodedInformation: DecodedInformation
    private var finished: Bool = false;

    init() {
        this(DecodedInformation(0, "", Option<Int64>.None), false);
    }

    init(information: DecodedInformation, finished: Bool) {
        this.finished = finished
        this.decodedInformation = information
    }

    func getDecodedInformation(): DecodedInformation {
        return this.decodedInformation;
    }

    func isFinished(): Bool {
        return this.finished;
    }
}
