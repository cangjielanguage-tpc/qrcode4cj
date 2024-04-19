/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package client.result

public open class SMTPResultParser <: ResultParser {
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);
        if (!(rawText.startsWith(UTF32String("smtp:")) || rawText.startsWith(UTF32String("SMTP:")))) {
            return None
        }
        var emailAddress: UTF32String = rawText.substring(5);
        var subject: UTF32String = UTF32String()
        var body: UTF32String = UTF32String()
        var colon = emailAddress.indexOf(':'.toString());
        if (colon != None) {
            subject = emailAddress.substring(colon.getOrThrow() + 1)
            emailAddress = emailAddress.substring(0, colon.getOrThrow())
            colon = subject.indexOf(':'.toString())
            if (colon != None) {
                body = subject.substring(colon.getOrThrow() + 1)
                subject = subject.substring(0, colon.getOrThrow())
            }
        }
        return EmailAddressParsedResult(
            Array<String>([emailAddress.toString()]),
            Array<String>(),
            Array<String>(),
            subject.toString(),
            body.toString()
        );
    }
}
