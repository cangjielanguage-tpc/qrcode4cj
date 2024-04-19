/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package qrcode.encoder

import common.BitArray
import common.ECIEncoderSet
import common.Qrcoder4cjWriterException
import common.MyCharset
import tools.UTF32String

enum VersionSize {
    | SMALL(String) //("version 1-9")
    | MEDIUM(String) //("version 10-26")
    | LARGE(String) //("version 27-40");

    public func toString(): String {
        match (this) {
            case SMALL(str) => return str
            case MEDIUM(str) => return str
            case LARGE(str) => return str
        }
    }
}

var isGS1: Bool = true;

public class Edge {
    public var mode: Mode = Mode.TERMINATOR([0, 0, 0], 0x00);
    public var fromPosition: Int64 = 0;
    public var charsetEncoderIndex: Int64 = 0
    public var characterLength: Int64 = 0
    public var previous: ?Edge = None
    public var cachedTotalSize: Int64 = 0
    public var encoders: ECIEncoderSet
    public var stringToEncode: UTF32String

    init(mode: Mode, fromPosition: Int64, charsetEncoderIndex: Int64, characterLength: Int64, previous: ?Edge,
        version: Version, encoders: ECIEncoderSet, stringToEncode: UTF32String) {
        this.mode = mode
        this.fromPosition = fromPosition
        this.encoders = encoders
        this.stringToEncode = stringToEncode

        var hasPrevious: Bool = false
        if (let Some(p) <- previous) {
            hasPrevious = true
        }

        this.charsetEncoderIndex = if (mode == Mode.BYTE([8, 16, 16], 0x04) || hasPrevious == false) {
            charsetEncoderIndex
        } else {
            previous.getOrThrow().charsetEncoderIndex
        }

        // inherit the encoding if not of type BYTE
        this.characterLength = characterLength
        this.previous = previous

        var size: Int64 = exinit(previous)

        var needECI: Bool = (mode == Mode.BYTE([8, 16, 16], 0x04) && (!hasPrevious && this.charsetEncoderIndex != 0) || (hasPrevious &&
            this.charsetEncoderIndex != previous.getOrThrow().charsetEncoderIndex))

        if (!hasPrevious || mode != previous.getOrThrow().mode || needECI) {
            size += 4 + mode.getCharacterCountBits(version)
        }
        match (mode) {
            case KANJI(x, y) => size += 13
            case ALPHANUMERIC(x, y) => size += if (characterLength == 1) {
                6
            } else {
                11
            }
            case NUMERIC(x, y) => size += if (characterLength == 1) {
                4
            } else {
                if (characterLength == 2) {
                    7
                } else {
                    10
                }
            }
            case BYTE(x, y) =>
                size += 8 * encoders.encode(
                    stringToEncode.substring(fromPosition, characterLength),
                    charsetEncoderIndex
                ).size
                if (needECI) {
                    size += 4 + 8
                    // the ECI assignment numbers for ISO-8859-x, UTF-8 and UTF-16 are all 8 bit long
                }
            case _ => size += 0
        }
        cachedTotalSize = size
    }

    private static func exinit(previous: ?Edge): Int64 {
        if (let Some(p) <- previous) {
            p.cachedTotalSize
        } else {
            0
        }
    }
}

public class ResultList {
    private var resultnodelist: ArrayList<?ResultNode> = ArrayList<?ResultNode>();
    private var version: ?Version = Option<Version>.None
    public let encoders: ECIEncoderSet
    public let stringToEncode: UTF32String
    public let ecLevel: ErrorCorrectionLevel

    init(
        version: Version,
        solution: ?Edge,
        encoders: ECIEncoderSet,
        stringToEncode: UTF32String,
        ecLevel: ErrorCorrectionLevel
    ) {
        var length: Int64 = 0;
        var current: ?Edge = solution
        var containsECI: Bool = false;
        this.encoders = encoders
        this.stringToEncode = stringToEncode
        this.ecLevel = ecLevel

        while (let Some(c) <- current) {
            length += c.characterLength
            var previous: ?Edge = c.previous

            var hasprevious = exinit(previous)

            let needECI: Bool = c.mode == Mode.BYTE([8, 16, 16], 0x04) && (!hasprevious && c.charsetEncoderIndex != 0) ||
                // at the beginning and charset is not ISO-8859-1
                (hasprevious && c.charsetEncoderIndex != previous.getOrThrow().charsetEncoderIndex)

            if (needECI) {
                containsECI = true
            }

            if (!hasprevious || previous.getOrThrow().mode != c.mode || needECI) {
                resultnodelist.insert(
                    0,
                    ResultNode(c.mode, c.fromPosition, c.charsetEncoderIndex, length, encoders, stringToEncode, version)
                );
                length = 0
            }

            if (needECI) {
                resultnodelist.insert(
                    0,
                    ResultNode(
                        Mode.ECI([0, 0, 0], 0x07),
                        c.fromPosition,
                        c.charsetEncoderIndex,
                        0,
                        encoders,
                        stringToEncode,
                        version
                    )
                );
            }
            current = previous
        }

        // prepend FNC1 if needed. If the bits contain an ECI then the FNC1 must be preceeded by an ECI.
        // If there is no ECI at the beginning then we put an ECI to the default charset (ISO-8859-1)
        if (isGS1) {
            var first: ?ResultNode = resultnodelist[0]
            var hasFirst = if (let Some(f) <- first) {
                true
            } else {
                false
            }
            if (hasFirst && first.getOrThrow().mode != Mode.ECI([0, 0, 0], 0x07) && containsECI) {
                // prepend a default character set ECI
                resultnodelist.insert(
                    0,
                    ResultNode(
                        Mode.ECI([0, 0, 0], 0x07),
                        0,
                        0,
                        0,
                        encoders,
                        stringToEncode,
                        version
                    )
                );
            }
            first = resultnodelist[0]

            // prepend or insert a FNC1_FIRST_POSITION after the ECI (if any)
            resultnodelist.insert(
                if (first.getOrThrow().mode != Mode.ECI([0, 0, 0], 0x07)) {
                    0
                } else {
                    1
                },
                ResultNode(Mode.FNC1_FIRST_POSITION([0, 0, 0], 0x05), 0, 0, 0, encoders, stringToEncode, version)
            );
        }

        // set version to smallest version into which the bits fit.
        var versionNumber: Int64 = version.getVersionNumber();
        var lowerLimit: Int64 = 0
        var upperLimit: Int64 = 0
        match (MinimalEncoder.getVersionSize(version)) {
            case SMALL("version 1-9") =>
                lowerLimit = 1
                upperLimit = 9
            case MEDIUM("version 10-26") =>
                lowerLimit = 10
                upperLimit = 26
            case LARGE("version 27-40") =>
                lowerLimit = 27
                upperLimit = 40
            case _ =>
                lowerLimit = 27
                upperLimit = 40
        }
        var size: Int64 = getSize(version);

        // increase version if needed
        while (versionNumber < upperLimit && !Encoder.willFit(
                size,
                Version.getVersionForNumber(versionNumber),
                ecLevel
            )) {
            versionNumber++
        }

        // shrink version if possible
        while (versionNumber > lowerLimit && Encoder.willFit(
                size,
                Version.getVersionForNumber(versionNumber - 1),
                ecLevel
            )) {
            versionNumber--
        }
        this.version = Version.getVersionForNumber(versionNumber)
    }

    func exinit(previous: ?Edge): Bool {
        if (let Some(p) <- previous) {
            true
        } else {
            false
        }
    }

    /**
     * returns the size in bits
     */
    func getSize(): Int64 {
        return getSize(version.getOrThrow());
    }

    public func getSize(version: Version): Int64 {
        var result: Int64 = 0;

        for (i in 0..resultnodelist.size) {
            if (let Some(t) <- resultnodelist[i]) {
                result += t.getSize(version)
            }
        }
        return result
    }

    /**
     * appends the bits
     */
    func getBits(bits: BitArray) {
        for (i in 0..resultnodelist.size) {
            resultnodelist[i].getOrThrow().getBits(bits);
        }
    }

    func getVersion(): Version {
        return version.getOrThrow()
    }

    public func toString(): String {
        var result: ArrayList<Char> = ArrayList<Char>();
        var previous: ?ResultNode = Option<ResultNode>.None;
        var flag: Bool = false;

        for (i in 0..resultnodelist.size) {
            if (let Some(p) <- previous) {
                result.append(',');
            }
            result.appendAll(resultnodelist[i].getOrThrow().toString().toRuneArray());
            previous = resultnodelist[i]
            flag = true
        }
        return String(result);
    }
}

public class ResultNode {
    public let mode: Mode
    public let fromPosition: Int64
    public let charsetEncoderIndex: Int64
    public let characterLength: Int64
    public let encoders: ECIEncoderSet
    public let stringToEncode: UTF32String
    public let version: Version

    init(
        mode: Mode,
        fromPosition: Int64,
        charsetEncoderIndex: Int64,
        characterLength: Int64,
        encoders: ECIEncoderSet,
        stringToEncode: UTF32String,
        version: Version
    ) {
        this.mode = mode
        this.fromPosition = fromPosition
        this.charsetEncoderIndex = charsetEncoderIndex
        this.characterLength = characterLength
        this.encoders = encoders
        this.stringToEncode = stringToEncode
        this.version = version
    }

    /**
     * returns the size in bits
     */
    public func getSize(version: Version): Int64 {
        var size: Int64 = 4 + mode.getCharacterCountBits(version)
        match (mode) {
            case KANJI(x, y) => size += 13 * characterLength
            case ALPHANUMERIC(x, y) =>
                size += (characterLength / 2) * 11
                size += if ((characterLength % 2) == 1) {
                    6
                } else {
                    0
                }
            case NUMERIC(x, y) =>
                size += (characterLength / 3) * 10
                var rest: Int64 = characterLength % 3
                size += if (rest == 1) {
                    4
                } else {
                    if (rest == 2) {
                        7
                    } else {
                        0
                    }
                }
            case BYTE(x, y) => size += 8 * getCharacterCountIndicator()
            case ECI(x, y) => size += 8 // the ECI assignment numbers for ISO-8859-x, UTF-8 and UTF-16 are all 8 bit long
            case _ => size += 0
        }
        return size
    }

    /**
     * returns the length in characters according to the specification (differs from getCharacterLength() in BYTE mode
     * for multi byte encoded characters)
     */
    private func getCharacterCountIndicator(): Int64 {
        return if (mode == Mode.BYTE([8, 16, 16], 0x04)) {
            encoders.encode(
                stringToEncode.substring(fromPosition, characterLength),
                charsetEncoderIndex
            ).size
        } else {
            characterLength
        }
    }

    /**
     * appends the bits
     */
    public func getBits(bits: BitArray) {
        bits.appendBits(mode.getBits(), 4);
        if (characterLength > 0) {
            var length: Int64 = getCharacterCountIndicator();
            bits.appendBits(length, mode.getCharacterCountBits(version));
        }
        if (mode == Mode.ECI([0, 0, 0], 0x07)) {
            bits.appendBits(encoders.getECIValue(charsetEncoderIndex), 8);
        } else if (characterLength > 0) {
            // append data
            Encoder.appendBytes(
                stringToEncode.substring(fromPosition, characterLength),
                mode,
                bits,
                encoders.getCharset(charsetEncoderIndex)
            );
        }
    }

    public func toString(): String {
        var result: ArrayList<Char> = ArrayList<Char>();
        result.appendAll(mode.toString().toRuneArray());
        result.append('(')
        if (mode == Mode.ECI([0, 0, 0], 0x07)) {
            result.appendAll(encoders.getCharset(charsetEncoderIndex).name().toString().toRuneArray());
        } else {
            result.appendAll(makePrintable(stringToEncode.substring(fromPosition, characterLength)).toRuneArray());
        }
        result.append(')');
        return String(result);
    }

    private func makePrintable(s: UTF32String): String {
        var result: ArrayList<Char> = ArrayList<Char>();
        for (i in 0..s.charSize) {
            if (s.get(i).hashCode() < 32 || s.get(i).hashCode() > 126) {
                result.append('.');
            } else {
                result.append(s.get(i));
            }
        }
        return String(result);
    }
}

public class MinimalEncoder {
    public let stringToEncode: UTF32String
    public let encoders: ECIEncoderSet
    public let ecLevel: ErrorCorrectionLevel

    /**
     * Creates a MinimalEncoder
     *
     * @param stringToEncode The string to encode
     * @param priorityCharset The preferred {@link Charset}. When the value of the argument is null, the algorithm
     * chooses charsets that leads to a minimal representation. Otherwise the algorithm will use the priority
     * charset to encode any character in the input that can be encoded by it if the charset is among the
     * supported charsets.
     * @param isGS1 {@code true} if a FNC1 is to be prepended; {@code false} otherwise
     * @param ecLevel The error correction level.
     * @see ResultList#getVersion
     */
    init(stringToEncode: UTF32String, priorityCharset: MyCharset, isGS1_: Bool, ecLevel: ErrorCorrectionLevel) {
        this.stringToEncode = stringToEncode
        isGS1 = isGS1_
        this.encoders = ECIEncoderSet(stringToEncode, priorityCharset, -1)
        this.ecLevel = ecLevel
    }

    /**
     * Encodes the string minimally
     *
     * @param stringToEncode The string to encode
     * @param version The preferred {@link Version}. A minimal version is computed (see
     * {@link ResultList#getVersion method} when the value of the argument is null
     * @param priorityCharset The preferred {@link Charset}. When the value of the argument is null, the algorithm
     * chooses charsets that leads to a minimal representation. Otherwise the algorithm will use the priority
     * charset to encode any character in the input that can be encoded by it if the charset is among the
     * supported charsets.
     * @param isGS1 {@code true} if a FNC1 is to be prepended; {@code false} otherwise
     * @param ecLevel The error correction level.
     * @return An instance of {@code ResultList} representing the minimal solution.
     * @see ResultList#getBits
     * @see ResultList#getVersion
     * @see ResultList#getSize
     */
    public static func encode(
        stringToEncode: UTF32String,
        version: ?Version,
        priorityCharset: MyCharset,
        isGS1: Bool,
        ecLevel: ErrorCorrectionLevel
    ): ResultList {
        return MinimalEncoder(stringToEncode, priorityCharset, isGS1, ecLevel).encodeVersion(version);
    }

    func encodeVersion(version: ?Version): ResultList {
        match (version) {
            case Some(ver) =>
                var result: ResultList = encodeSpecificVersion(ver);
                if (!Encoder.willFit(result.getSize(), getVersion(getVersionSize(result.getVersion())), ecLevel)) {
                    throw Qrcoder4cjWriterException("Data too big for version" + ver.toString());
                }
                return result

            case None =>
                var versions: Array<Version> = [
                    getVersion(VersionSize.SMALL("version 1-9")),
                    getVersion(VersionSize.MEDIUM("version 10-26")),
                    getVersion(VersionSize.LARGE("version 27-40"))
                ]
                var results: Array<ResultList> = [
                    encodeSpecificVersion(versions[0]),
                    encodeSpecificVersion(versions[1]),
                    encodeSpecificVersion(versions[2])
                ]
                var smallestSize: Int64 = Int64.Max;
                var smallestResult: Int64 = -1;

                for (i in 0..3) {
                    var size: Int64 = results[i].getSize();
                    if (Encoder.willFit(size, versions[i], ecLevel) && size < smallestSize) {
                        smallestSize = size
                        smallestResult = i
                    }
                }
                if (smallestResult < 0) {
                    throw Qrcoder4cjWriterException("Data too big for any version");
                }
                return results[smallestResult]
        }
    }

    static func getVersionSize(version: Version): VersionSize {
        return if (version.getVersionNumber() <= 9) {
            VersionSize.SMALL("version 1-9")
        } else {
            if (version.getVersionNumber() <= 26) {
                VersionSize.MEDIUM("version 10-26")
            } else {
                VersionSize.LARGE("version 27-40")
            }
        }
    }

    static func getVersion(versionSize: VersionSize): Version {
        match (versionSize) {
            case VersionSize.SMALL(str) => return Version.getVersionForNumber(9);
            case VersionSize.MEDIUM(str) => return Version.getVersionForNumber(26);
            case VersionSize.LARGE(str) => return Version.getVersionForNumber(40);
        }
    }

    static func isNumeric(c: Char): Bool {
        return c >= '0' && c <= '9'
    }

    static func isDoubleByteKanji(c: Char): Bool {
        return Encoder.isOnlyDoubleByteKanji(UTF32String(c));
    }

    static func isAlphanumeric(c: Char): Bool {
        return Encoder.getAlphanumericCode(c.hashCode()) != -1
    }

    func canEncode(mode: Mode, c: Char): Bool {
        match (mode) {
            case KANJI(x, y) => return isDoubleByteKanji(c);
            case ALPHANUMERIC(x, y) => return isAlphanumeric(c);
            case NUMERIC(x, y) => return isNumeric(c);
            case BYTE(x, y) => return true; // any character can be encoded as byte(s). Up to the caller to manage splitting into

            // multiple bytes when String.getBytes(Charset) return more than one byte.
            case _ => return false;
        }
    }

    static func getCompactedOrdinal(mode: Mode): Int64 {
        match (mode) {
            case KANJI(x, y) => return 0;
            case ALPHANUMERIC(x, y) => return 1;
            case NUMERIC(x, y) => return 2;
            case BYTE(x, y) => return 3;
            case _ => throw IllegalArgumentException("Illegal mode " + mode.toString());
        }
    }

    func addEdge(edges: Array<Array<Array<?Edge>>>, position: Int64, edge: Edge) {
        var vertexIndex: Int64 = position + edge.characterLength
        var modeEdges: Array<?Edge> = edges[vertexIndex][edge.charsetEncoderIndex]
        var modeOrdinal: Int64 = getCompactedOrdinal(edge.mode);

        var flag: Bool = false;
        if (let Some(e) <- modeEdges[modeOrdinal]) {
            flag = true
        }

        if (flag == false || modeEdges[modeOrdinal].getOrThrow().cachedTotalSize > edge.cachedTotalSize) {
            modeEdges[modeOrdinal] = edge
        }
    }

    func addEdges(version: Version, edges: Array<Array<Array<?Edge>>>, startNum: Int64, previous: ?Edge) {
        var start: Int64 = 0;
        var end: Int64 = encoders.length();
        var priorityEncoderIndex: Int64 = encoders.getPriorityEncoderIndex();
        if (priorityEncoderIndex >= 0 && encoders.canEncode(stringToEncode[startNum], priorityEncoderIndex)) {
            start = priorityEncoderIndex
            end = priorityEncoderIndex + 1
        }

        for (i in start..end) {
            if (encoders.canEncode(stringToEncode[startNum], i)) {
                addEdge(edges, startNum,
                    Edge(Mode.BYTE([8, 16, 16], 0x04), startNum, i, 1, previous, version, encoders, stringToEncode));
            }
        }

        if (canEncode(Mode.KANJI([8, 10, 12], 0x08), stringToEncode[startNum])) {
            addEdge(edges, startNum,
                Edge(Mode.KANJI([8, 10, 12], 0x08), startNum, 0, 1, previous, version, encoders, stringToEncode));
        }

        var inputLength: Int64 = stringToEncode.charSize;
        if (canEncode(Mode.ALPHANUMERIC([9, 11, 13], 0x02), stringToEncode[startNum])) {
            addEdge(edges, startNum,
                Edge(Mode.ALPHANUMERIC([9, 11, 13], 0x02), startNum, 0,
                if (startNum + 1 >= inputLength ||
                !canEncode(Mode.ALPHANUMERIC([9, 11, 13], 0x02), stringToEncode[startNum + 1])) {
                1
            } else {
                2
            }, previous, version, encoders, stringToEncode));
        }

        if (canEncode(Mode.NUMERIC([10, 12, 14], 0x01), stringToEncode[startNum])) {
            addEdge(edges, startNum,
                Edge(Mode.NUMERIC([10, 12, 14], 0x01), startNum, 0,
                if (startNum + 1 >= inputLength || !canEncode(
                Mode.NUMERIC([10, 12, 14], 0x01),
                stringToEncode[startNum + 1]
            )) {
                1
            } else {
                if (startNum + 2 >= inputLength || !canEncode(
                    Mode.NUMERIC([10, 12, 14], 0x01),
                    stringToEncode[startNum + 2]
                )) {
                    2
                } else {
                    3
                }
            }, previous, version, encoders, stringToEncode));
        }
    }
    func encodeSpecificVersion(version: Version): ResultList {
        /* A vertex represents a tuple of a position in the input, a mode and a character encoding where position 0
         * denotes the position left of the first character, 1 the position left of the second character and so on.
         * Likewise the end vertices are located after the last character at position stringToEncode.size.
         *
         * An edge leading to such a vertex encodes one or more of the characters left of the position that the vertex
         * represents and encodes it in the same encoding and mode as the vertex on which the edge ends. In other words,
         * all edges leading to a particular vertex encode the same characters in the same mode with the same character
         * encoding. They differ only by their source vertices who are all located at i+1 minus the number of encoded
         * characters.
         *
         * The edges leading to a vertex are stored in such a way that there is a fast way to enumerate the edges ending
         * on a particular vertex.
         *
         * The algorithm processes the vertices in order of their position thereby performing the following:
         *
         * For every vertex at position i the algorithm enumerates the edges ending on the vertex and removes all but the
         * shortest from that resultnodelist.
         * Then it processes the vertices for the position i+1. If i+1 == stringToEncode.size then the algorithm ends
         * and chooses the the edge with the smallest size from any of the edges leading to vertices at this position.
         * Otherwise the algorithm computes all possible outgoing edges for the vertices at the position i+1
         *
         * Examples:
         * The process is illustrated by showing the graph (edges) after each iteration from left to right over the input:
         * An edge is drawn as follows "(" + fromVertex + ") -- " + encodingMode + "(" + encodedInput + ") (" +
         * accumulatedSize + ") --> (" + toVertex + ")"
         *
         * Example 1 encoding the string "ABCDE":
         * Note: This example assumes that alphanumeric encoding is only possible in multiples of two characters so that
         * the example is both short and showing the principle. In reality this restriction does not exist.
         *
         * Initial situation
         * (initial) -- BYTE(A) (20) --> (1_BYTE)
         * (initial) -- ALPHANUMERIC(AB)                     (24) --> (2_ALPHANUMERIC)
         *
         * Situation after adding edges to vertices at position 1
         * (initial) -- BYTE(A) (20) --> (1_BYTE) -- BYTE(B) (28) --> (2_BYTE)
         * (1_BYTE) -- ALPHANUMERIC(BC)                             (44) --> (3_ALPHANUMERIC)
         * (initial) -- ALPHANUMERIC(AB)                     (24) --> (2_ALPHANUMERIC)
         *
         * Situation after adding edges to vertices at position 2
         * (initial) -- BYTE(A) (20) --> (1_BYTE)
         * (initial) -- ALPHANUMERIC(AB)                     (24) --> (2_ALPHANUMERIC)
         * (initial) -- BYTE(A) (20) --> (1_BYTE) -- BYTE(B) (28) --> (2_BYTE)
         * (1_BYTE) -- ALPHANUMERIC(BC)                             (44) --> (3_ALPHANUMERIC)
         * (initial) -- ALPHANUMERIC(AB)                     (24) --> (2_ALPHANUMERIC) -- BYTE(C) (44) --> (3_BYTE)
         * (2_ALPHANUMERIC) -- ALPHANUMERIC(CD)                             (35) --> (4_ALPHANUMERIC)
         *
         * Situation after adding edges to vertices at position 3
         * (initial) -- BYTE(A) (20) --> (1_BYTE) -- BYTE(B) (28) --> (2_BYTE) -- BYTE(C)         (36) --> (3_BYTE)
         * (1_BYTE) -- ALPHANUMERIC(BC)                             (44) --> (3_ALPHANUMERIC) -- BYTE(D) (64) --> (4_BYTE)
         * (3_ALPHANUMERIC) -- ALPHANUMERIC(DE)                             (55) --> (5_ALPHANUMERIC)
         * (initial) -- ALPHANUMERIC(AB)                     (24) --> (2_ALPHANUMERIC) -- ALPHANUMERIC(CD)                             (35) --> (4_ALPHANUMERIC)
         * (2_ALPHANUMERIC) -- ALPHANUMERIC(CD)                             (35) --> (4_ALPHANUMERIC)
         *
         * Situation after adding edges to vertices at position 4
         * (initial) -- BYTE(A) (20) --> (1_BYTE) -- BYTE(B) (28) --> (2_BYTE) -- BYTE(C)         (36) --> (3_BYTE) -- BYTE(D) (44) --> (4_BYTE)
         * (1_BYTE) -- ALPHANUMERIC(BC)                             (44) --> (3_ALPHANUMERIC) -- ALPHANUMERIC(DE)                             (55) --> (5_ALPHANUMERIC)
         * (initial) -- ALPHANUMERIC(AB)                     (24) --> (2_ALPHANUMERIC) -- ALPHANUMERIC(CD)                             (35) --> (4_ALPHANUMERIC) -- BYTE(E) (55) --> (5_BYTE)
         *
         * Situation after adding edges to vertices at position 5
         * (initial) -- BYTE(A) (20) --> (1_BYTE) -- BYTE(B) (28) --> (2_BYTE) -- BYTE(C)         (36) --> (3_BYTE) -- BYTE(D)         (44) --> (4_BYTE) -- BYTE(E)         (52) --> (5_BYTE)
         * (1_BYTE) -- ALPHANUMERIC(BC)                             (44) --> (3_ALPHANUMERIC) -- ALPHANUMERIC(DE)                             (55) --> (5_ALPHANUMERIC)
         * (initial) -- ALPHANUMERIC(AB)                     (24) --> (2_ALPHANUMERIC) -- ALPHANUMERIC(CD)                             (35) --> (4_ALPHANUMERIC)
         *
         * Encoding as BYTE(ABCDE) has the smallest size of 52 and is hence chosen. The encodation ALPHANUMERIC(ABCD),
         * BYTE(E) is longer with a size of 55.
         *
         * Example 2 encoding the string "XXYY" where X denotes a character unique to character set ISO-8859-2 and Y a
         * character unique to ISO-8859-3. Both characters encode as double byte in UTF-8:
         *
         * Initial situation
         * (initial) -- BYTE(X) (32) --> (1_BYTE_ISO-8859-2)
         * (initial) -- BYTE(X) (40) --> (1_BYTE_UTF-8)
         * (initial) -- BYTE(X) (40) --> (1_BYTE_UTF-16BE)
         *
         * Situation after adding edges to vertices at position 1
         * (initial) -- BYTE(X) (32) --> (1_BYTE_ISO-8859-2) -- BYTE(X) (40) --> (2_BYTE_ISO-8859-2)
         * (1_BYTE_ISO-8859-2) -- BYTE(X) (72) --> (2_BYTE_UTF-8)
         * (1_BYTE_ISO-8859-2) -- BYTE(X) (72) --> (2_BYTE_UTF-16BE)
         * (initial) -- BYTE(X) (40) --> (1_BYTE_UTF-8)
         * (initial) -- BYTE(X) (40) --> (1_BYTE_UTF-16BE)
         *
         * Situation after adding edges to vertices at position 2
         * (initial) -- BYTE(X) (32) --> (1_BYTE_ISO-8859-2) -- BYTE(X) (40) --> (2_BYTE_ISO-8859-2)
         * (2_BYTE_ISO-8859-2) -- BYTE(Y) (72) --> (3_BYTE_ISO-8859-3)
         * (2_BYTE_ISO-8859-2) -- BYTE(Y) (80) --> (3_BYTE_UTF-8)
         * (2_BYTE_ISO-8859-2) -- BYTE(Y) (80) --> (3_BYTE_UTF-16BE)
         * (initial) -- BYTE(X) (40) --> (1_BYTE_UTF-8) -- BYTE(X) (56) --> (2_BYTE_UTF-8)
         * (initial) -- BYTE(X) (40) --> (1_BYTE_UTF-16BE) -- BYTE(X) (56) --> (2_BYTE_UTF-16BE)
         *
         * Situation after adding edges to vertices at position 3
         * (initial) -- BYTE(X) (32) --> (1_BYTE_ISO-8859-2) -- BYTE(X) (40) --> (2_BYTE_ISO-8859-2) -- BYTE(Y) (72) --> (3_BYTE_ISO-8859-3)
         * (3_BYTE_ISO-8859-3) -- BYTE(Y) (80) --> (4_BYTE_ISO-8859-3)
         * (3_BYTE_ISO-8859-3) -- BYTE(Y) (112) --> (4_BYTE_UTF-8)
         * (3_BYTE_ISO-8859-3) -- BYTE(Y) (112) --> (4_BYTE_UTF-16BE)
         * (initial) -- BYTE(X) (40) --> (1_BYTE_UTF-8) -- BYTE(X) (56) --> (2_BYTE_UTF-8) -- BYTE(Y) (72) --> (3_BYTE_UTF-8)
         * (initial) -- BYTE(X) (40) --> (1_BYTE_UTF-16BE) -- BYTE(X) (56) --> (2_BYTE_UTF-16BE) -- BYTE(Y) (72) --> (3_BYTE_UTF-16BE)
         *
         * Situation after adding edges to vertices at position 4
         * (initial) -- BYTE(X) (32) --> (1_BYTE_ISO-8859-2) -- BYTE(X) (40) --> (2_BYTE_ISO-8859-2) -- BYTE(Y) (72) --> (3_BYTE_ISO-8859-3) -- BYTE(Y) (80) --> (4_BYTE_ISO-8859-3)
         * (3_BYTE_UTF-8) -- BYTE(Y) (88) --> (4_BYTE_UTF-8)
         * (3_BYTE_UTF-16BE) -- BYTE(Y) (88) --> (4_BYTE_UTF-16BE)
         * (initial) -- BYTE(X) (40) --> (1_BYTE_UTF-8) -- BYTE(X) (56) --> (2_BYTE_UTF-8) -- BYTE(Y) (72) --> (3_BYTE_UTF-8)
         * (initial) -- BYTE(X) (40) --> (1_BYTE_UTF-16BE) -- BYTE(X) (56) --> (2_BYTE_UTF-16BE) -- BYTE(Y) (72) --> (3_BYTE_UTF-16BE)
         *
         * Encoding as ECI(ISO-8859-2),BYTE(XX),ECI(ISO-8859-3),BYTE(YY) has the smallest size of 80 and is hence chosen.
         * The encodation ECI(UTF-8),BYTE(XXYY) is longer with a size of 88.
         */
        var inputLength: Int64 = stringToEncode.charSize;

        // Array that represents vertices. There is a vertex for every character, encoding and mode. The vertex contains
        // a resultnodelist of all edges that lead to it that have the same encoding and mode.
        // The lists are created lazily

        // The last dimension in the array below encodes the 4 modes KANJI, ALPHANUMERIC, NUMERIC and BYTE via the
        // function getCompactedOrdinal(Mode)
        var edges: Array<Array<Array<?Edge>>> = Array<Array<Array<?Edge>>>(
            inputLength + 1,
            {a: Int64 => Array<Array<?Edge>>(encoders.length(), {b: Int64 => Array<?Edge>(4, item: None)})}
        )

        addEdges(version, edges, 0, Option<Edge>.None);

        for (i in 1..=inputLength) {
            let edges_i = edges[i]
            for (j in 0..encoders.length()) {
                let edges_i_j = edges_i[j]
                for (k in 0..4) {
                    if (let Some(e) <- edges_i_j[k]) {
                        if (i < inputLength) {
                            addEdges(version, edges, i, edges_i_j[k]);
                        }
                    }
                }
            }
        }
        var minimalJ: Int64 = -1;
        var minimalK: Int64 = -1;
        var minimalSize: Int64 = Int64.Max;
        let edges_inputLength = edges[inputLength]
        for (j in 0..encoders.length()) {
            let edges_inputLength_j = edges_inputLength[j]
            for (k in 0..4) {
                var edge: ?Edge = edges_inputLength_j[k]
                if (let Some(e) <- edge) {
                    if (e.cachedTotalSize < minimalSize) {
                        minimalSize = e.cachedTotalSize
                        minimalJ = j
                        minimalK = k
                    }
                }
            }
        }
        if (minimalJ < 0) {
            throw Qrcoder4cjWriterException("Internal error: failed to encode \"" + stringToEncode.toString() + "\"");
        }
        return ResultList(version, edges[inputLength][minimalJ][minimalK], encoders, stringToEncode, ecLevel);
    }
}
