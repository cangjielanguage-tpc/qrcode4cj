package aztec.encoder

import common.CharacterSetECI
from std import collection.*

/**
 * This produces nearly optimal encodings of text into the first-level of encoding
 * used by Aztec code.
 *
 * It uses a dynamic algorithm.  For each prefix of the string, it determines
 * a set of encodings that could lead to this prefix.  We repeatedly add a character
 * and generate a new set of optimal encodings until we have read
 * through the entire input.
 */
public class HighLevelEncoder {
    static var MODE_NAMES: Array<String> = ["UPPER", "LOWER", "DIGIT", "MIXED", "PUNCT"]

    static var MODE_UPPER: Int64 = 0 // 5 bits
    static var MODE_LOWER: Int64 = 1 // 5 bits
    static var MODE_DIGIT: Int64 = 2 // 4 bits
    static var MODE_MIXED: Int64 = 3 // 5 bits
    static var MODE_PUNCT: Int64 = 4 // 5 bits

    // The Latch Table shows, for each pair of Modes, the optimal method for getting
    // from one mode to another.  In the worst possible case, this can
    // be up to 14 bits.  In the best possible case, we are already there!
    // The high half-word of each entry gives the number of bits.
    // The low half-word of each entry are the actual bits necessary to change
    static var LATCH_TABLE: Array<Array<Int64>> = [
        [
            0,
            (5 << 16) + 28, // UPPER -> LOWER
            (5 << 16) + 30, // UPPER -> DIGIT
            (5 << 16) + 29, // UPPER -> MIXED
            (10 << 16) + (29 << 5) + 30 // UPPER -> MIXED -> PUNCT
        ],
        [
            (9 << 16) + (30 << 4) + 14, // LOWER -> DIGIT -> UPPER
            0,
            (5 << 16) + 30, // LOWER -> DIGIT
            (5 << 16) + 29, // LOWER -> MIXED
            (10 << 16) + (29 << 5) + 30 // LOWER -> MIXED -> PUNCT
        ],
        [
            (4 << 16) + 14, // DIGIT -> UPPER
            (9 << 16) + (14 << 5) + 28, // DIGIT -> UPPER -> LOWER
            0,
            (9 << 16) + (14 << 5) + 29, // DIGIT -> UPPER -> MIXED
            (14 << 16) + (14 << 10) + (29 << 5) + 30
        // DIGIT -> UPPER -> MIXED -> PUNCT
        ],
        [
            (5 << 16) + 29, // MIXED -> UPPER
            (5 << 16) + 28, // MIXED -> LOWER
            (10 << 16) + (29 << 5) + 30, // MIXED -> UPPER -> DIGIT
            0,
            (5 << 16) + 30 // MIXED -> PUNCT
        ],
        [
            (5 << 16) + 31, /* PUNCT -> UPPER */ 
            (10 << 16) + (31 << 5) + 28, /* PUNCT -> UPPER -> LOWER */
            (10 << 16) + (31 << 5) + 30, /* PUNCT -> UPPER -> DIGIT */ 
            (10 << 16) + (31 << 5) + 29, /* PUNCT -> UPPER -> MIXED */ 
            0
        ]
    ]

    // A reverse mapping from [mode][char] to the encoding for that character in that mode. 
    // An entry of 0 indicates no mapping exists.
    private static var CHAR_MAP: Array<Array<Int64>> = Array<Array<Int64>>(5, {int: Int64 => Array<Int64>(256, item: 0)}
    )
    private static var mixedTable: Array<Int64> = [
        '\0'.hashCode(),
        ' '.hashCode(),
        Char(0x01).hashCode(),
        Char(0x02).hashCode(),
        Char(0x03).hashCode(),
        Char(0x04).hashCode(),
        Char(0x05).hashCode(),
        Char(0x06).hashCode(),
        Char(0x07).hashCode(),
        '\b'.hashCode(),
        '\t'.hashCode(),
        '\n'.hashCode(),
        '\v'.hashCode().hashCode(),
        '\f'.hashCode(),
        '\r'.hashCode(),
        '!'.hashCode(),
        '"'.hashCode(),
        '#'.hashCode(),
        '$'.hashCode(),
        '%'.hashCode(),
        '@'.hashCode(),
        '\\'.hashCode(),
        '^'.hashCode(),
        '_'.hashCode(),
        '`'.hashCode(),
        '|'.hashCode(),
        '~'.hashCode(),
        Char(0x7F).hashCode()
    ]
    private static var punctTable: Array<Int64> = [
        '\0'.hashCode(),
        '\r'.hashCode(),
        '\0'.hashCode(),
        '\0'.hashCode(),
        '\0'.hashCode(),
        '\0'.hashCode(),
        '!'.hashCode(),
        '\''.hashCode(),
        '#'.hashCode(),
        '$'.hashCode(),
        '%'.hashCode(),
        '&'.hashCode(),
        '\''.hashCode(),
        '('.hashCode(),
        ')'.hashCode(),
        '*'.hashCode(),
        '+'.hashCode(),
        ','.hashCode(),
        '-'.hashCode(),
        '.'.hashCode(),
        '/'.hashCode(),
        ':'.hashCode(),
        ';'.hashCode(),
        '<'.hashCode(),
        '='.hashCode(),
        '>'.hashCode(),
        '?'.hashCode(),
        '['.hashCode(),
        ']'.hashCode(),
        '{'.hashCode(),
        '}'.hashCode()
    ]

    public static var SHIFT_TABLE_: Array<Array<Int64>> = Array<Array<Int64>>(6, {int: Int64 => Array<Int64>(6, item: -1)}
    )

    private func initSomeTables() {
        CHAR_MAP[MODE_UPPER][Int64(UInt32(' '))] = 1
        for (c in Int64(UInt32('A'))..=(Int64(UInt32('Z')))) {
            CHAR_MAP[MODE_UPPER][c] = c - Int64(UInt32('A')) + 2
        }
        CHAR_MAP[MODE_LOWER][Int64(UInt32(' '))] = 1
        for (c in Int64(UInt32('a'))..=(Int64(UInt32('z')))) {
            CHAR_MAP[MODE_LOWER][c] = c - Int64(UInt32('a')) + 2
        }
        CHAR_MAP[MODE_DIGIT][Int64(UInt32(' '))] = 1
        for (c in Int64(UInt32('0'))..=(Int64(UInt32('9')))) {
            CHAR_MAP[MODE_DIGIT][c] = c - Int64(UInt32('0')) + 2
        }
        CHAR_MAP[MODE_DIGIT][Int64(UInt32(','))] = 12
        CHAR_MAP[MODE_DIGIT][Int64(UInt32('.'))] = 13

        for (i in 0..mixedTable.size) {
            CHAR_MAP[MODE_MIXED][mixedTable[i]] = i
        }
        for (i in 0..punctTable.size) {
            if (punctTable[i] > 0) {
                CHAR_MAP[MODE_PUNCT][punctTable[i]] = i
            }
        }

        // A map showing the available shift codes.  (The shifts to BINARY are not
        // shown
        SHIFT_TABLE_[MODE_UPPER][MODE_PUNCT] = 0

        SHIFT_TABLE_[MODE_LOWER][MODE_PUNCT] = 0
        SHIFT_TABLE_[MODE_LOWER][MODE_UPPER] = 28

        SHIFT_TABLE_[MODE_MIXED][MODE_PUNCT] = 0

        SHIFT_TABLE_[MODE_DIGIT][MODE_PUNCT] = 0
        SHIFT_TABLE_[MODE_DIGIT][MODE_UPPER] = 15
    }

    private var text: Array<UInt8> = Array<UInt8>()
    private var charset: MyCharset = MyCharset()

    public init(text: Array<UInt8>) {
        initSomeTables()
        this.text = text
        this.charset = MyCharset()
    }

    public init(text: Array<UInt8>, charset: MyCharset) {
        initSomeTables()
        this.text = text
        this.charset = charset
    }

    /**
     * @return text represented by this encoder encoded as a {@link BitArray}
     */
    public func encode(): BitArray {
        var initialState: State = State.INITIAL_STATE
        if (charset != MyCharset()) {
            var eci: Int64 = CharacterSetECI.getCharacterSetECI(charset)
            if (CharacterSetECI.NO == eci) {
                throw IllegalArgumentException("No ECI code for character set ${charset.name()}")
            }
            initialState = initialState.appendFLGn(eci)
        }

        var states: ArrayList<State> = ArrayList<State>()
        states.append(initialState)

        var index = 0;
        while (index < text.size) {
            var pairCode: Int64
            var nextChar: UInt8 = 0
            if (index + 1 < text.size) {
                nextChar = text[index + 1]
            }
            match (Char(text[index])) {
                case '\r' => pairCode = getpairCode1(nextChar)
                case '.' => pairCode = getpairCode2(nextChar)
                case ',' => pairCode = getpairCode3(nextChar)
                case ':' =>
                    pairCode = 0
                    if (Char(nextChar) == ' ') {
                        pairCode = 5
                    }
                case _ => pairCode = 0
            }
            if (pairCode > 0) {
                /*
                 * We have one of the four special PUNCT pairs.  Treat them specially.
                 * Get a new set of states for the two new characters.
                 */
                states = updateStateListForPair(states, index, pairCode)
                index++
            } else {
                // Get a new set of states for the new character.
                states = updateStateListForChar(states, index)
            }

            index++
        }
        var minIdx: Int64 = 0
        for (i in 1..states.size) {
            if (states[i].getBitCount() < states[minIdx].getBitCount()) {
                minIdx = i
            }
        }
        var minState: State = states[minIdx]

        // Convert it to a bit array, and return.
        return minState.toBitArray(text)
    }

    static private func getpairCode1(nextChar: UInt8): Int64 {
        if (Char(nextChar) == '\n') {
            return 2
        }
        return 0
    }

    static private func getpairCode2(nextChar: UInt8): Int64 {
        if (Char(nextChar) == ' ') {
            return 3
        }
        return 0
    }

    static private func getpairCode3(nextChar: UInt8): Int64 {
        if (Char(nextChar) == ' ') {
            return 4
        }
        return 0
    }

    // We update a set of states for a new character by updating each state
    // for the new character, merging the results, and then removing the
    // non-optimal states.
    private func updateStateListForChar(states: Iterable<State>, index: Int64): ArrayList<State> {
        var result: ArrayList<State> = ArrayList<State>();
        var a: Int64 = 0
        for (state in states) {
            updateStateForChar(state, index, result);
            a++
        }
        return simplifyStates(result);
    }

    // Return a set of states that represent the possible ways of updcating this
    // state for the next character.  The resulting set of states are added to
    // the "result" list.
    private func updateStateForChar(state: State, index: Int64, result: ArrayList<State>) {
        if (text[index] == 0x1a) {
            text[index] = 128
        }
        var ch: Char = Char(text[index] & 0xFF)
        var charInCurrentTable: Bool = CHAR_MAP[state.getMode()][Int64(UInt32(ch))] > 0 &&
            CHAR_MAP[state.getMode()][Int64(UInt32(ch))] != 128
        var stateNoBinary: ?State = None
        for (mode in 0..(MODE_PUNCT + 1)) {
            var charInMode: Int64 = CHAR_MAP[mode][Int64(UInt32(ch))]
            if (charInMode > 0) {
                if (let Some(s) <- stateNoBinary) {}
                else {
                    /* Only create stateNoBinary the first time it's required. */
                    stateNoBinary = state.endBinaryShift(index)
                }

                // Try generating the character by latching to its mode
                if (!charInCurrentTable || mode == state.getMode() || mode == MODE_DIGIT) {
                    // If the character is in the current table, we don't want to latch to
                    // any other mode except possibly digit (which uses only 4 bits).  Any
                    // other latch would be equally successful *after* this character, and
                    // so wouldn't save any bits.
                    var latchState: State = stateNoBinary.getOrThrow().latchAndAppend(mode, charInMode)
                    result.append(latchState)
                }

                // Try generating the character by switching to its mode.
                if (!charInCurrentTable && SHIFT_TABLE_[state.getMode()][mode] >= 0) {
                    // It never makes sense to temporarily shift to another mode if the
                    // character exists in the current mode.  That can never save bits.
                    var shiftState: State = stateNoBinary.getOrThrow().shiftAndAppend(mode, charInMode)
                    result.append(shiftState)
                }
            }
        }
        if (state.getBinaryShiftByteCount() > 0 || CHAR_MAP[state.getMode()][Int64(UInt32(ch))] == 0) {
            // It's never worthwhile to go into binary shift mode if you're not already
            // in binary shift mode, and the character exists in your current mode.
            // That can never save bits over just outputting the char in the current mode.
            var binaryState: State = state.addBinaryShiftChar(index)
            result.append(binaryState)
        }
    }

    private static func updateStateListForPair(states: ArrayList<State>, index: Int64, pairCode: Int64): ArrayList<State> {
        var result: ArrayList<State> = ArrayList<State>();
        for (stateN in 0..states.size) {
            var state = states[stateN]
            updateStateForPair(state, index, pairCode, result)
        }
        return simplifyStates(result)
    }

    private static func updateStateForPair(state: State, index: Int64, pairCode: Int64, result: ArrayList<State>) {
        var stateNoBinary: State = state.endBinaryShift(index)

        /* Possibility 1.  Latch to MODE_PUNCT, and then append this code */
        result.append(stateNoBinary.latchAndAppend(MODE_PUNCT, pairCode))
        if (state.getMode() != MODE_PUNCT) {
            // Possibility 2.  Shift to MODE_PUNCT, and then append this code.
            // Every state except MODE_PUNCT (handled above) can shift
            result.append(stateNoBinary.shiftAndAppend(MODE_PUNCT, pairCode))
        }
        if (pairCode == 3 || pairCode == 4) {
            /* both characters are in DIGITS.  Sometimes better to just add two digits */
            var digitState: State = stateNoBinary.latchAndAppend(MODE_DIGIT, 16 - pairCode).latchAndAppend(MODE_DIGIT, 1
            )
            result.append(digitState)
        }
        if (state.getBinaryShiftByteCount() > 0) {
            // It only makes sense to do the characters as binary if we're already
            // in binary mode.
            var binaryState: State = state.addBinaryShiftChar(index).addBinaryShiftChar(index + 1)
            result.append(binaryState)
        }
    }

    private static func simplifyStates(states: ArrayList<State>): ArrayList<State> {
        var result: ArrayList<State> = ArrayList<State>()
        for (newStateN in 0..states.size) {
            var newState: State = states[newStateN]
            var add: Bool = true
            var idx: Int64 = 0
            while (idx < result.size) {
                var oldState: State = result[idx]
                if (oldState.isBetterThanOrEqualTo(newState)) {
                    add = false
                    break
                } else {}
                if (newState.isBetterThanOrEqualTo(oldState)) {
                    result.remove(idx)
                } else {
                    idx++
                }
            }
            if (add) {
                result.insert(0, newState)
            }
        }
        return result
    }
}
