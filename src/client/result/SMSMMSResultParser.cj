/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package client.result

/**
 * Parses an "sms:" URI result, which specifies a number to SMS.
 * See RFC 5724 on this.
 *
 * This class supports "via" syntax for numbers, which is not part of the spec.
 * For example "+12125551212;via=+12124440101" may appear as a number.
 * It also supports a "subject" query parameter, which is not mentioned in the spec.
 * These are included since they were mentioned in earlier IETF drafts and might be
 * used.
 *
 * This actually also parses URIs starting with "mms:" and treats them all the same way,
 * and effectively converts them to an "sms:" URI for purposes of forwarding to the platform.
 */
public open class SMSMMSResultParser <: ResultParser {
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);
        if (!(rawText.startsWith(UTF32String("sms:")) || rawText.startsWith(UTF32String("SMS:")) || rawText.startsWith(
            UTF32String("mms:")) || rawText.startsWith(UTF32String("MMS:")))) {
            return None
        }

        // Check up front if this is a URI syntax string with query arguments
        var nameValuePairs: Map<String, String> = parseNameValuePairs(rawText);
        var subject: String = "";
        var body: String = "";
        var querySyntax: Bool = false;
        if (nameValuePairs.size != 0 && !nameValuePairs.isEmpty()) {
            subject = (nameValuePairs.get("subject").getOrThrow().toString())
            body = (nameValuePairs.get("body")).getOrThrow().toString()
            querySyntax = true
        }

        // Drop sms, query portion
        var obj = rawText.indexOf('?'.toString(), start: 4)
        var queryStart = 0
        if (let None <- obj) {
            queryStart = -1
        } else {
            queryStart = rawText.indexOf('?'.toString(), start: 4).getOrThrow()
        }
        var smsURIWithoutQuery: UTF32String

        // If it's not query syntax, the question mark is part of the subject or message
        if (queryStart < 0 || !querySyntax) {
            smsURIWithoutQuery = rawText.substring(4)
        } else {
            smsURIWithoutQuery = rawText.substring(4, queryStart - 4)
        }

        var lastComma: Int64 = -1;
        var numbers: ArrayList<String> = ArrayList<String>();
        var vias: ArrayList<String> = ArrayList<String>();
        for (i in 0..smsURIWithoutQuery.charSize) {
            if (smsURIWithoutQuery.get(i) == ',') {
                var numberPart: UTF32String = smsURIWithoutQuery.substring(lastComma + 1, i - (lastComma + 1));
                addNumberVia(numbers, vias, numberPart);
                lastComma = i
            }
        }
        addNumberVia(numbers, vias, smsURIWithoutQuery.substring(lastComma + 1));

        return SMSParsedResult(
            numbers.toArray(),
            vias.toArray(),
            subject,
            body
        );
    }

    private static func addNumberVia(numbers: ArrayList<String>, vias: ArrayList<String>, numberPart: UTF32String) {
        var u = numberPart.indexOf(';'.toString())
        var numberEnd = 0
        if (let Some(v) <- u) {
            numberEnd = v
        } else {
            numberEnd = -1
        }
        if (numberEnd < 0) {
            numbers.append(numberPart.toString());
            vias.append("");
        } else {
            numbers.append(numberPart.substring(0, numberEnd).toString());
            var maybeVia: UTF32String = numberPart.substring(numberEnd + 1);
            var via: UTF32String
            if (maybeVia.startsWith(UTF32String("via="))) {
                via = maybeVia.substring(4)
            } else {
                via = UTF32String("")
            }
            vias.append(via.toString());
        }
    }
}
