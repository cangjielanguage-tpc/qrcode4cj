/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned.rss.expanded.decoders

from std import collection.*
from std import math.*
import zxing.code.tools.UTF32String

class DataLength {
    var variable: Bool = false;
    var length: Int64 = 0
    init(variable: Bool, length: Int64) {
        this.variable = variable
        this.length = length
    }

    static func fixed(length: Int64): DataLength {
        return DataLength(false, length);
    }

    static func variableInit(length: Int64): DataLength {
        return DataLength(true, length);
    }
}

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
public class FieldParser {
    private static var TWO_DIGIT_DATA_LENGTH: HashMap<UTF32String, DataLength> = HashMap<UTF32String, DataLength>(
        [
            (UTF32String("00"), DataLength.fixed(18)),
            (UTF32String("01"), DataLength.fixed(14)),
            (UTF32String("02"), DataLength.fixed(14)),
            (UTF32String("10"), DataLength.variableInit(20)),
            (UTF32String("11"), DataLength.fixed(6)),
            (UTF32String("12"), DataLength.fixed(6)),
            (UTF32String("13"), DataLength.fixed(6)),
            (UTF32String("15"), DataLength.fixed(6)),
            (UTF32String("17"), DataLength.fixed(6)),
            (UTF32String("20"), DataLength.fixed(2)),
            (UTF32String("21"), DataLength.variableInit(20)),
            (UTF32String("22"), DataLength.variableInit(29)),
            (UTF32String("30"), DataLength.variableInit(8)),
            (UTF32String("37"), DataLength.variableInit(8)),
            (UTF32String("90"), DataLength.variableInit(30)),
            (UTF32String("91"), DataLength.variableInit(30)),
            (UTF32String("92"), DataLength.variableInit(30)),
            (UTF32String("93"), DataLength.variableInit(30)),
            (UTF32String("94"), DataLength.variableInit(30)),
            (UTF32String("95"), DataLength.variableInit(30)),
            (UTF32String("96"), DataLength.variableInit(30)),
            (UTF32String("97"), DataLength.variableInit(30)),
            (UTF32String("98"), DataLength.variableInit(30)),
            (UTF32String("99"), DataLength.variableInit(30))
        ]
    );

    private static var THREE_DIGIT_DATA_LENGTH: HashMap<UTF32String, DataLength> = HashMap<UTF32String, DataLength>(
        [
            (UTF32String("240"), DataLength.variableInit(30)),
            (UTF32String("241"), DataLength.variableInit(30)),
            (UTF32String("242"), DataLength.variableInit(6)),
            (UTF32String("250"), DataLength.variableInit(30)),
            (UTF32String("251"), DataLength.variableInit(30)),
            (UTF32String("253"), DataLength.variableInit(17)),
            (UTF32String("254"), DataLength.variableInit(20)),
            (UTF32String("400"), DataLength.variableInit(30)),
            (UTF32String("401"), DataLength.variableInit(30)),
            (UTF32String("402"), DataLength.fixed(17)),
            (UTF32String("403"), DataLength.variableInit(30)),
            (UTF32String("410"), DataLength.fixed(13)),
            (UTF32String("411"), DataLength.fixed(13)),
            (UTF32String("412"), DataLength.fixed(13)),
            (UTF32String("413"), DataLength.fixed(13)),
            (UTF32String("414"), DataLength.fixed(13)),
            (UTF32String("420"), DataLength.variableInit(20)),
            (UTF32String("421"), DataLength.variableInit(15)),
            (UTF32String("422"), DataLength.fixed(3)),
            (UTF32String("423"), DataLength.variableInit(15)),
            (UTF32String("424"), DataLength.fixed(3)),
            (UTF32String("425"), DataLength.fixed(3)),
            (UTF32String("426"), DataLength.fixed(3))
        ]
    );

    private static var THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH: HashMap<UTF32String, DataLength> = HashMap<UTF32String, DataLength>(
        [
            (UTF32String("310"), DataLength.fixed(6)),
            (UTF32String("311"), DataLength.fixed(6)),
            (UTF32String("312"), DataLength.fixed(6)),
            (UTF32String("313"), DataLength.fixed(6)),
            (UTF32String("314"), DataLength.fixed(6)),
            (UTF32String("315"), DataLength.fixed(6)),
            (UTF32String("316"), DataLength.fixed(6)),
            (UTF32String("320"), DataLength.fixed(6)),
            (UTF32String("321"), DataLength.fixed(6)),
            (UTF32String("322"), DataLength.fixed(6)),
            (UTF32String("323"), DataLength.fixed(6)),
            (UTF32String("324"), DataLength.fixed(6)),
            (UTF32String("325"), DataLength.fixed(6)),
            (UTF32String("326"), DataLength.fixed(6)),
            (UTF32String("327"), DataLength.fixed(6)),
            (UTF32String("328"), DataLength.fixed(6)),
            (UTF32String("329"), DataLength.fixed(6)),
            (UTF32String("330"), DataLength.fixed(6)),
            (UTF32String("331"), DataLength.fixed(6)),
            (UTF32String("332"), DataLength.fixed(6)),
            (UTF32String("333"), DataLength.fixed(6)),
            (UTF32String("334"), DataLength.fixed(6)),
            (UTF32String("335"), DataLength.fixed(6)),
            (UTF32String("336"), DataLength.fixed(6)),
            (UTF32String("340"), DataLength.fixed(6)),
            (UTF32String("341"), DataLength.fixed(6)),
            (UTF32String("342"), DataLength.fixed(6)),
            (UTF32String("343"), DataLength.fixed(6)),
            (UTF32String("344"), DataLength.fixed(6)),
            (UTF32String("345"), DataLength.fixed(6)),
            (UTF32String("346"), DataLength.fixed(6)),
            (UTF32String("347"), DataLength.fixed(6)),
            (UTF32String("348"), DataLength.fixed(6)),
            (UTF32String("349"), DataLength.fixed(6)),
            (UTF32String("350"), DataLength.fixed(6)),
            (UTF32String("351"), DataLength.fixed(6)),
            (UTF32String("352"), DataLength.fixed(6)),
            (UTF32String("353"), DataLength.fixed(6)),
            (UTF32String("354"), DataLength.fixed(6)),
            (UTF32String("355"), DataLength.fixed(6)),
            (UTF32String("356"), DataLength.fixed(6)),
            (UTF32String("357"), DataLength.fixed(6)),
            (UTF32String("360"), DataLength.fixed(6)),
            (UTF32String("361"), DataLength.fixed(6)),
            (UTF32String("362"), DataLength.fixed(6)),
            (UTF32String("363"), DataLength.fixed(6)),
            (UTF32String("364"), DataLength.fixed(6)),
            (UTF32String("365"), DataLength.fixed(6)),
            (UTF32String("366"), DataLength.fixed(6)),
            (UTF32String("367"), DataLength.fixed(6)),
            (UTF32String("368"), DataLength.fixed(6)),
            (UTF32String("369"), DataLength.fixed(6)),
            (UTF32String("390"), DataLength.variableInit(15)),
            (UTF32String("391"), DataLength.variableInit(18)),
            (UTF32String("392"), DataLength.variableInit(15)),
            (UTF32String("393"), DataLength.variableInit(18)),
            (UTF32String("703"), DataLength.variableInit(30))
        ]
    );

    private static var FOUR_DIGIT_DATA_LENGTH: HashMap<UTF32String, DataLength> = HashMap<UTF32String, DataLength>(
        [
            (UTF32String("7001"), DataLength.fixed(13)),
            (UTF32String("7002"), DataLength.variableInit(30)),
            (UTF32String("7003"), DataLength.fixed(10)),
            (UTF32String("8001"), DataLength.fixed(14)),
            (UTF32String("8002"), DataLength.variableInit(20)),
            (UTF32String("8003"), DataLength.variableInit(30)),
            (UTF32String("8004"), DataLength.variableInit(30)),
            (UTF32String("8005"), DataLength.fixed(6)),
            (UTF32String("8006"), DataLength.fixed(18)),
            (UTF32String("8007"), DataLength.variableInit(30)),
            (UTF32String("8008"), DataLength.variableInit(12)),
            (UTF32String("8018"), DataLength.fixed(18)),
            (UTF32String("8020"), DataLength.variableInit(25)),
            (UTF32String("8100"), DataLength.fixed(6)),
            (UTF32String("8101"), DataLength.fixed(10)),
            (UTF32String("8102"), DataLength.fixed(2)),
            (UTF32String("8110"), DataLength.variableInit(70)),
            (UTF32String("8200"), DataLength.variableInit(70))
        ]
    );

    private init() {}

    public static func parseFieldsInGeneralPurpose(rawInformation: UTF32String): UTF32String {
        if (rawInformation.isEmpty()) {
            return UTF32String();
        }

        // Processing 2-digit AIs
        if (rawInformation.size < 2) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        if (TWO_DIGIT_DATA_LENGTH.contains(rawInformation.substring(0, 2))) {
            var twoDigitDataLength: DataLength = TWO_DIGIT_DATA_LENGTH[rawInformation.substring(0, 2)]
            if (twoDigitDataLength.variable) {
                return processVariableAI(2, twoDigitDataLength.length, rawInformation);
            }
            return processFixedAI(2, twoDigitDataLength.length, rawInformation);
        }

        if (rawInformation.size < 3) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        var firstThreeDigits: UTF32String = rawInformation.substring(0, 3);
        if (THREE_DIGIT_DATA_LENGTH.contains(firstThreeDigits)) {
            var threeDigitDataLength: DataLength = THREE_DIGIT_DATA_LENGTH[firstThreeDigits]
            if (threeDigitDataLength.variable) {
                return processVariableAI(3, threeDigitDataLength.length, rawInformation);
            }
            return processFixedAI(3, threeDigitDataLength.length, rawInformation);
        }

        if (rawInformation.size < 4) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        if (THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH.contains(firstThreeDigits)) {
            var threeDigitPlusDigitDataLength: DataLength = THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH[firstThreeDigits]
            if (threeDigitPlusDigitDataLength.variable) {
                return processVariableAI(4, threeDigitPlusDigitDataLength.length, rawInformation);
            }
            return processFixedAI(4, threeDigitPlusDigitDataLength.length, rawInformation);
        }

        if (FOUR_DIGIT_DATA_LENGTH.contains(rawInformation.substring(0, 4))) {
            var firstFourDigitLength: DataLength = FOUR_DIGIT_DATA_LENGTH[rawInformation.substring(0, 4)]
            if (firstFourDigitLength.variable) {
                return processVariableAI(4, firstFourDigitLength.length, rawInformation);
            }
            return processFixedAI(4, firstFourDigitLength.length, rawInformation);
        }

        throw Qrcoder4cjNotFoundException.getNotFoundInstance();
    }

    private static func processFixedAI(aiSize: Int64, fieldSize: Int64, rawInformation: UTF32String): UTF32String {
        if (rawInformation.size < aiSize) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        var ai: UTF32String = rawInformation.substring(0, aiSize);

        if (rawInformation.size < aiSize + fieldSize) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        var field: UTF32String = rawInformation.substring(aiSize, fieldSize);
        var remaining: UTF32String = rawInformation.substring(aiSize + fieldSize);
        var result: UTF32String = UTF32String("(") + ai + UTF32String(")") + field
        var parsedAI: UTF32String = parseFieldsInGeneralPurpose(remaining);
        return if (parsedAI == UTF32String()) {
            result
        } else {
            result + parsedAI
        }
    }

    private static func processVariableAI(aiSize: Int64, variableFieldSize: Int64, rawInformation: UTF32String): UTF32String {
        var ai: UTF32String = rawInformation.substring(0, aiSize);
        var maxSize: Int64 = min(rawInformation.size, aiSize + variableFieldSize);
        var field: UTF32String = rawInformation.substring(aiSize, maxSize - aiSize);
        var remaining: UTF32String = rawInformation.substring(maxSize);
        var result: UTF32String = UTF32String("(") + ai + UTF32String(")") + field
        var parsedAI: UTF32String = parseFieldsInGeneralPurpose(remaining);
        return if (parsedAI == UTF32String()) {
            result
        } else {
            result + parsedAI
        }
    }
}
