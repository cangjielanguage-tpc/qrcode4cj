/*
 * Copyright 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * Encapsulates the result of one test over a batch of black-box images.
 */
public class TestResult {
    private let mustPassCount: Int64
    private let tryHarderCount: Int64
    private let maxMisreads: Int64
    private let maxTryHarderMisreads: Int64
    private let rotation: Float32

    public init(
        mustPassCount: Int64,
        tryHarderCount: Int64,
        maxMisreads: Int64,
        maxTryHarderMisreads: Int64,
        rotation: Float32
    ) {
        this.mustPassCount = mustPassCount
        this.tryHarderCount = tryHarderCount
        this.maxMisreads = maxMisreads
        this.maxTryHarderMisreads = maxTryHarderMisreads
        this.rotation = rotation
    }

    public func getMustPassCount(): Int64 {
        return mustPassCount
    }

    public func getTryHarderCount(): Int64 {
        return tryHarderCount
    }

    public func getMaxMisreads(): Int64 {
        return maxMisreads
    }

    public func getMaxTryHarderMisreads(): Int64 {
        return maxTryHarderMisreads
    }

    public func getRotation(): Float32 {
        return rotation
    }
}
