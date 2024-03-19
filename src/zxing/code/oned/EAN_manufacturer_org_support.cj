/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

from std import sync.*

/**
 * Records EAN prefix to GS1 Member Organization, where the member organization
 * correlates strongly with a country. This is an imperfect means of identifying
 * a country of origin by EAN-13 barcode value. See
 * "http://en.wikipedia.org/wiki/List_of_GS1_country_codes"
 * "http://en.wikipedia.org/wiki/List_of_GS1_country_codes".
 */
public open class EANManufacturerOrgSupport {
    private let ranges: ArrayList<Array<Int64>> = ArrayList<Array<Int64>>()
    private let countryIdentifiers: ArrayList<String> = ArrayList<String>()

    public func lookupCountryIdentifier(productCode: UTF32String): String {
        initIfNeeded()
        var prefix: Int64 = Int64.parse(productCode.substring(0, 3).toString())
        var max: Int64 = ranges.size

        for (i in 0..max) {
            var range: Array<Int64> = ranges.get(i).getOrThrow()
            var start: Int64 = range[0]
            if (prefix < start) {
                return String()
            }

            var end: Int64 = 0
            if (range.size == 1) {
                end = start
            } else {
                end = range[1]
            }
            if (prefix <= end) {
                return countryIdentifiers.get(i).getOrThrow()
            }
        }
        return ""
    }

    private func add(range: Array<Int64>, id: String) {
        ranges.append(range)
        var reentrantMutex: ReentrantMutex = ReentrantMutex()
        reentrantMutex.lock()
        synchronized(reentrantMutex) {
            countryIdentifiers.append(id)
        }
        reentrantMutex.unlock()
    }

    private func initIfNeeded() {
        if (!ranges.isEmpty()) {
            return
        }
        var reentrantMutex: ReentrantMutex = ReentrantMutex()
        reentrantMutex.lock()
        synchronized(reentrantMutex) {
            add([0, 19], "US/CA")
            add([30, 39], "US")
            add([60, 139], "US/CA")
            add([300, 379], "FR")
            add([380], "BG")
            add([383], "SI")
            add([385], "HR")
            add([387], "BA")
            add([400, 440], "DE")
            add([450, 459], "JP")
            add([460, 469], "RU")
            add([471], "TW")
            add([474], "EE")
            add([475], "LV")
            add([476], "AZ")
            add([477], "LT")
            add([478], "UZ")
            add([479], "LK")
            add([480], "PH")
            add([481], "BY")
            add([482], "UA")
            add([484], "MD")
            add([485], "AM")
            add([486], "GE")
            add([487], "KZ")
            add([489], "HK")
            add([490, 499], "JP")
            add([500, 509], "GB")
            add([520], "GR")
            add([528], "LB")
            add([529], "CY")
            add([531], "MK")
            add([535], "MT")
            add([539], "IE")
            add([540, 549], "BE/LU")
            add([560], "PT")
            add([569], "IS")
            add([570, 579], "DK")
            add([590], "PL")
            add([594], "RO")
            add([599], "HU")
            add([600, 601], "ZA")
            add([603], "GH")
            add([608], "BH")
            add([609], "MU")
            add([611], "MA")
            add([613], "DZ")
            add([616], "KE")
            add([618], "CI")
            add([619], "TN")
            add([621], "SY")
            add([622], "EG")
            add([624], "LY")
            add([625], "JO")
            add([626], "IR")
            add([627], "KW")
            add([628], "SA")
            add([629], "AE")
            add([640, 649], "FI")
            add([690, 695], "CN")
            add([700, 709], "NO")
            add([729], "IL")
            add([730, 739], "SE")
            add([740], "GT")
            add([741], "SV")
            add([742], "HN")
            add([743], "NI")
            add([744], "CR")
            add([745], "PA")
            add([746], "DO")
            add([750], "MX")
            add([754, 755], "CA")
            add([759], "VE")
            add([760, 769], "CH")
            add([770], "CO")
            add([773], "UY")
            add([775], "PE")
            add([777], "BO")
            add([779], "AR")
            add([780], "CL")
            add([784], "PY")
            add([785], "PE")
            add([786], "EC")
            add([789, 790], "BR")
            add([800, 839], "IT")
            add([840, 849], "ES")
            add([850], "CU")
            add([858], "SK")
            add([859], "CZ")
            add([860], "YU")
            add([865], "MN")
            add([867], "KP")
            add([868, 869], "TR")
            add([870, 879], "NL")
            add([880], "KR")
            add([885], "TH")
            add([888], "SG")
            add([890], "IN")
            add([893], "VN")
            add([896], "PK")
            add([899], "ID")
            add([900, 919], "AT")
            add([930, 939], "AU")
            add([940, 949], "AZ")
            add([955], "MY")
            add([958], "MO")
        }
        reentrantMutex.unlock()
    }
}
