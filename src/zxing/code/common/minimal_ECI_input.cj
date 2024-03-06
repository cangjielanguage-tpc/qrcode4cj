/*
 * Copyright 2021 ZXing authors
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

package zxing.code.common

/**
 * Class that converts a character string into a sequence of ECIs and bytes
 *
 * The implementation uses the Dijkstra algorithm to produce minimal encodings
 *
 * @author Alex Geller
 */
public open class MinimalECIInput <: ECIInput {
    private static let COST_PER_ECI: Int64 = 3; // approximated (latch + 2 codewords)
    private let bytes: Array<Int64>
    private let fnc1: Int64

    /**
     * Constructs a minimal input
     *
     * @param stringToEncode the character string to encode
     * @param priorityCharset The preferred {@link MyCharset}. When the value of the argument is null, the algorithm
     * chooses charsets that leads to a minimal representation. Otherwise the algorithm will use the priority
     * charset to encode any character in the input that can be encoded by it if the charset is among the
     * supported charsets.
     * @param fnc1 denotes the character in the input that represents the FNC1 character or -1 if this is not GS1
     * input.
     */
    public init(stringToEncode: UTF32String, priorityCharset: MyCharset, fnc1: Int64) {
        this.fnc1 = fnc1
        var encoderSet: ECIEncoderSet = ECIEncoderSet(stringToEncode, priorityCharset, fnc1);
        if (encoderSet.length() == 1) { //optimization for the case when all can be encoded without ECI in ISO-8859-1
            bytes = Array<Int64>(stringToEncode.charSize, item: 0)
            for (i in 0..bytes.size) {
                var c: Char = stringToEncode[i];
                if (c.hashCode() == fnc1) {
                    bytes[i] = 1000
                } else {
                    bytes[i] = c.hashCode()
                }
            }
        } else {
            bytes = encodeMinimally(stringToEncode, encoderSet, fnc1)
        }
    }

    public func getFNC1Character(): Int64 {
        return fnc1
    }

    /**
     * Returns the length of this input.  The length is the number
     * of {@code byte}s, FNC1 characters or ECIs in the sequence.
     *
     * @return  the number of {@code char}s in this sequence
     */
    public func length(): Int64 {
        return bytes.size;
    }

    public func haveNCharacters(index: Int64, n: Int64): Bool {
        if (index + n - 1 >= bytes.size) {
            return false;
        }

        for (i in 0..n) {
            if (isECI(index + i)) {
                return false;
            }
        }
        return true;
    }

    /**
     * Returns the {@code byte} value at the specified index.  An index ranges from zero
     * to {@code length() - 1}.  The first {@code byte} value of the sequence is at
     * index zero, the next at index one, and so on, as for array
     * indexing.
     *
     * @param   index the index of the {@code byte} value to be returned
     *
     * @return  the specified {@code byte} value as character or the FNC1 character
     *
     * @throws  IndexOutOfBoundsException
     * if the {@code index} argument is negative or not less than
     * {@code length()}
     * @throws  IllegalArgumentException
     * if the value at the {@code index} argument is an ECI (@see #isECI)
     */
    public func charAt(index: Int64): Char {
        if (index < 0 || index >= length()) {
            throw IndexOutOfBoundsException(index.toString());
        }
        if (isECI(index)) {
            throw IllegalArgumentException("value at ${index} is not a character but an ECI");
        }
        if (isFNC1(index)) {
            return Char(fnc1)
        } else {
            return Char(bytes[index])
        }
    }

    /**
     * Returns a {@code CharSequence} that is a subsequence of this sequence.
     * The subsequence starts with the {@code char} value at the specified index and
     * ends with the {@code char} value at index {@code end - 1}.  The length
     * (in {@code char}s) of the
     * returned sequence is {@code end - start}, so if {@code start == end}
     * then an empty sequence is returned.
     *
     * @param   start   the start index, inclusive
     * @param   end     the end index, exclusive
     *
     * @return  the specified subsequence
     *
     * @throws  IndexOutOfBoundsException
     * if {@code start} or {@code end} are negative,
     * if {@code end} is greater than {@code length()},
     * or if {@code start} is greater than {@code end}
     * @throws  IllegalArgumentException
     * if a value in the range {@code start}-{@code end} is an ECI (@see #isECI)
     */
    public func subSequence(start: Int64, end: Int64): UTF32String {
        if (start < 0 || start > end || end > length()) {
            throw IndexOutOfBoundsException(start.toString());
        }
        var result: ArrayList<Char> = ArrayList<Char>();

        for (i in start..end) {
            if (isECI(i)) {
                throw IllegalArgumentException("value at ${i} is not a character but an ECI");
            }
            result.append(charAt(i));
        }
        return UTF32String(result)
    }

    /**
     * Determines if a value is an ECI
     *
     * @param   index the index of the value
     *
     * @return  true if the value at position {@code index} is an ECI
     *
     * @throws  IndexOutOfBoundsException
     * if the {@code index} argument is negative or not less than
     * {@code length()}
     */
    public func isECI(index: Int64): Bool {
        if (index < 0 || index >= length()) {
            throw IndexOutOfBoundsException(index.toString());
        }
        return bytes[index] > 255 && bytes[index] <= 999
    }

    /**
     * Determines if a value is the FNC1 character
     *
     * @param   index the index of the value
     *
     * @return  true if the value at position {@code index} is the FNC1 character
     *
     * @throws  IndexOutOfBoundsException
     * if the {@code index} argument is negative or not less than
     * {@code length()}
     */
    public func isFNC1(index: Int64): Bool {
        if (index < 0 || index >= length()) {
            throw IndexOutOfBoundsException(index.toString());
        }
        return bytes[index] == 1000
    }

    /**
     * Returns the {@code int} ECI value at the specified index.  An index ranges from zero
     * to {@code length() - 1}.  The first {@code byte} value of the sequence is at
     * index zero, the next at index one, and so on, as for array
     * indexing.
     *
     * @param   index the index of the {@code int} value to be returned
     *
     * @return  the specified {@code int} ECI value.
     * The ECI specified the encoding of all bytes with a higher index until the
     * next ECI or until the end of the input if no other ECI follows.
     *
     * @throws  IndexOutOfBoundsException
     * if the {@code index} argument is negative or not less than
     * {@code length()}
     * @throws  IllegalArgumentException
     * if the value at the {@code index} argument is not an ECI (@see #isECI)
     */
    public func getECIValue(index: Int64): Int64 {
        if (index < 0 || index >= length()) {
            throw IndexOutOfBoundsException(index.toString());
        }
        if (!isECI(index)) {
            throw IllegalArgumentException("value at ${index} is not an ECI but a character");
        }
        return bytes[index] - 256
    }

    public func toString(): String {
        var result: ArrayList<Char> = ArrayList<Char>();
        for (i in 0..length()) {
            if (i > 0) {
                result.appendAll(", ".toRuneArray());
            }
            if (isECI(i)) {
                result.appendAll("ECI(".toRuneArray());
                result.appendAll(getECIValue(i).toString().toRuneArray());
                result.append(')');
            } else if (charAt(i).hashCode() < 128) {
                result.append('\'');
                result.append(charAt(i));
                result.append('\'');
            } else {
                result.appendAll(charAt(i).hashCode().toString().toRuneArray())
            }
        }
        return String(result);
    }
    static func addEdge(edges: Array<Array<?InputEdge>>, to: Int64, edge: InputEdge) {
        var flag = false;
        if (let Some(i) <- edges[to][edge.encoderIndex]) {
            flag = true
        }
        if (flag == false || edges[to][edge.encoderIndex].getOrThrow().cachedTotalSize > edge.cachedTotalSize) {
            edges[to][edge.encoderIndex] = edge
        }
    }

    static func addEdges(
        stringToEncode: UTF32String,
        encoderSet: ECIEncoderSet,
        edges: Array<Array<?InputEdge>>,
        froms: Int64,
        previous: ?InputEdge,
        fnc1: Int64
    ) {
        var ch: Char = stringToEncode.toRuneArray()[froms];
        var start: Int64 = 0;
        var end: Int64 = encoderSet.length();
        if (encoderSet.getPriorityEncoderIndex() >= 0 && (ch.hashCode() == fnc1 || encoderSet.canEncode(
            ch,
            encoderSet.getPriorityEncoderIndex()
        ))) {
            start = encoderSet.getPriorityEncoderIndex()
            end = start + 1
        }

        for (i in start..end) {
            if (ch.hashCode() == fnc1 || encoderSet.canEncode(ch, i)) {
                addEdge(edges, froms + 1, InputEdge(ch, encoderSet, i, previous, fnc1));
            }
        }
    }

    static func encodeMinimally(stringToEncode: UTF32String, encoderSet: ECIEncoderSet, fnc1: Int64): Array<Int64> {
        var inputLength: Int64 = stringToEncode.charSize;

        // Array that represents vertices. There is a vertex for every character and encoding.
        var edges: Array<Array<?InputEdge>> = Array<Array<?InputEdge>>(
            inputLength + 1,
            {int: Int64 => Array<?InputEdge>(encoderSet.length(), item: None)}
        )

        addEdges(stringToEncode, encoderSet, edges, 0, None, fnc1);

        for (i in 1..=inputLength) {
            for (j in 0..encoderSet.length()) {
                if (let Some(e) <- edges[i][j]) {
                    if (i < inputLength) {
                        addEdges(stringToEncode, encoderSet, edges, i, e, fnc1);
                    }
                }
            }

            //optimize memory by removing edges that have been passed.
            for (j in 0..encoderSet.length()) {
                edges[i - 1][j] = None
            }
        }
        var minimalJ: Int64 = -1;
        var minimalSize: Int64 = Int64.Max;
        for (j in 0..encoderSet.length()) {
            if (let Some(e) <- edges[inputLength][j]) {
                if (e.cachedTotalSize < minimalSize) {
                    minimalSize = e.cachedTotalSize
                    minimalJ = j
                }
            }
        }
        if (minimalJ < 0) {
            throw Exception("Failed to encode \"${stringToEncode}\"");
        }
        var intsAL: ArrayList<Int64> = ArrayList<Int64>();
        var current: ?InputEdge = edges[inputLength][minimalJ]
        var currentFlag = false
        if (let Some(c) <- current) {
            currentFlag = true
        }
        while (currentFlag) {
            if (current.getOrThrow().isFNC1()) {
                intsAL.insert(0, 1000);
            } else {
                var bytes: Array<UInt8> = encoderSet.encode(current.getOrThrow().c, current.getOrThrow().encoderIndex);
                for (i in bytes.size - 1..=0 : -1) {
                    intsAL.insert(0, Int64(bytes[i] & 0xFF));
                }
            }
            var previousEncoderIndex: Int64 = 0
            if (let Some(p) <- current.getOrThrow().previous) {
                previousEncoderIndex = p.encoderIndex
            }

            if (previousEncoderIndex != current.getOrThrow().encoderIndex) {
                intsAL.insert(0, 256 + encoderSet.getECIValue(current.getOrThrow().encoderIndex));
            }
            current = current.getOrThrow().previous
            if (let Some(c) <- current) {
                currentFlag = true
            } else {
                currentFlag = false
            }
        }
        var ints: Array<Int64> = Array<Int64>(intsAL.size, item: 0)
        for (i in 0..ints.size) {
            ints[i] = intsAL.get(i).getOrThrow()
        }

        return ints
    }
}

open class InputEdge {
    private static let COST_PER_ECI: Int64 = 3; // approximated (latch + 2 codewords)
    public var c: Char
    public var encoderIndex: Int64 //the encoding of this edge
    public var previous: ?InputEdge = None
    public var cachedTotalSize: Int64
    public var flag = false
    init() {
        this.c = ' '
        this.encoderIndex = 0 //the encoding of this edge
        this.cachedTotalSize = 0
    }
    init(c: Char, encoderSet: ECIEncoderSet, encoderIndex: Int64, previous: ?InputEdge, fnc1: Int64) {
        if (c.hashCode() == fnc1) {
            this.c = Char(1000)
        } else {
            this.c = c
        }
        this.encoderIndex = encoderIndex
        this.previous = previous

        var size: Int64 = 1
        if (this.c.hashCode() != 1000) {
            size = encoderSet.encode(c, encoderIndex).size
        }

        var previousEncoderIndex: Int64 = 0
        if (let Some(p) <- previous) {
            previousEncoderIndex = p.encoderIndex
        }

        if (previousEncoderIndex != encoderIndex) {
            size += COST_PER_ECI
        }
        if (let Some(p) <- previous) {
            size += p.cachedTotalSize
        }
        this.cachedTotalSize = size
    }

    func isFNC1(): Bool {
        return c.hashCode() == 1000
    }
}
