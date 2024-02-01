/*
 * Copyright 2013 ZXing authors
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

package zxing.code.pdf417.common

/**
 * @author Guenther Grau
 */
public open class PDF417ResultMetadata {
    private var segmentIndex: Int64 = 0
    private var fileId: String = ""
    private var lastSegment: Bool = false
    private var segmentCount: Int64 = -1
    private var sender: String = ""
    private var addressee: String = ""
    private var fileName: String = ""
    private var fileSize: Int64 = -1
    private var timestamp: Int64 = -1
    private var checksum: Int64 = -1
    private var optionalData: Array<Int64> = Array<Int64>()
    public var flag: Bool = false
    public init() {}

    /**
     * The Segment ID represents the segment of the whole file distributed over different symbols.
     *
     * @return File segment index
     */
    public func getSegmentIndex(): Int64 {
        return segmentIndex
    }

    public func setSegmentIndex(segmentIndex: Int64) {
        flag = true
        this.segmentIndex = segmentIndex
    }

    /**
     * Is the same for each related PDF417 symbol
     *
     * @return File ID
     */
    public func getFileId(): String {
        return fileId
    }

    public func setFileId(fileId: String) {
        flag = true
        this.fileId = fileId
    }

    /**
     * @return always null
     * @deprecated use dedicated already parsed fields
     */
    public func getOptionalData(): Array<Int64> {
        return optionalData
    }

    /**
     * @param optionalData old optional data format as int array
     * @deprecated parse and use new fields
     */
    public func setOptionalData(optionalData: Array<Int64>) {
        flag = true
        this.optionalData = optionalData
    }

    /**
     * @return true if it is the last segment
     */
    public func isLastSegment(): Bool {
        return lastSegment
    }

    public func setLastSegment(lastSegment: Bool) {
        flag = true
        this.lastSegment = lastSegment
    }

    /**
     * @return count of segments, -1 if not set
     */
    public func getSegmentCount(): Int64 {
        return segmentCount
    }

    public func setSegmentCount(segmentCount: Int64) {
        flag = true
        this.segmentCount = segmentCount
    }

    public func getSender(): String {
        return sender
    }

    public func setSender(sender: String) {
        flag = true
        this.sender = sender
    }

    public func getAddressee(): String {
        return addressee
    }

    public func setAddressee(addressee: String) {
        flag = true
        this.addressee = addressee
    }

    /**
     * Filename of the encoded file
     *
     * @return filename
     */
    public func getFileName(): String {
        return fileName
    }

    public func setFileName(fileName: String) {
        flag = true
        this.fileName = fileName
    }

    /**
     * filesize in bytes of the encoded file
     *
     * @return filesize in bytes, -1 if not set
     */
    public func getFileSize(): Int64 {
        return fileSize
    }

    public func setFileSize(fileSize: Int64) {
        flag = true
        this.fileSize = fileSize
    }

    /**
     * 16-bit CRC checksum using CCITT-16
     *
     * @return crc checksum, -1 if not set
     */
    public func getChecksum(): Int64 {
        return checksum
    }

    public func setChecksum(checksum: Int64) {
        flag = true
        this.checksum = checksum
    }

    /**
     * unix epock timestamp, elapsed seconds since 1970-01-01
     *
     * @return elapsed seconds, -1 if not set
     */
    public func getTimestamp(): Int64 {
        return timestamp
    }

    public func setTimestamp(timestamp: Int64) {
        flag = true
        this.timestamp = timestamp
    }
}
