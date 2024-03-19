/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.client.result

public open class AddressBookParsedResult <: ParsedResult {
    private var names: Array<String> = Array<String>()
    private var nicknames: Array<String> = Array<String>()
    private var pronunciation: String = String()
    private var phoneNumbers: Array<String> = Array<String>()
    private var phoneTypes: Array<String> = Array<String>()
    private var emails: Array<String> = Array<String>()
    private var emailTypes: Array<String> = Array<String>()
    private var instantMessenger: String = String()
    private var note: String = String()
    private var addresses: Array<String> = Array<String>()
    private var addressTypes: Array<String> = Array<String>()
    private var org: String = String()
    private var birthday: String = String()
    private var title: String = String()
    private var urls: Array<String> = Array<String>()
    private var geo: Array<String> = Array<String>()
    public var flag: Bool = false

    public func AddressBookParsedResult(
        names: Array<String>,
        phoneNumbers: Array<String>,
        phoneTypes: Array<String>,
        emails: Array<String>,
        emailTypes: Array<String>,
        addresses: Array<String>,
        addressTypes: Array<String>
    ) {
        var initData: Array<String> = Array<String>()

        (names, initData, "", phoneNumbers, phoneTypes, emails, emailTypes, "", "", addresses, addressTypes, "", "", "",
            initData, initData)
        this.flag = true
    }
    init() {
        super(ParsedResultType.ADDRESSBOOK)
    }
    public init(
        names_: Array<String>,
        nicknames_: Array<String>,
        pronunciation_: String,
        phoneNumbers: Array<String>,
        phoneTypes: Array<String>,
        emails: Array<String>,
        emailTypes_: Array<String>,
        instantMessenger_: String,
        note_: String,
        addresses: Array<String>,
        addressTypes: Array<String>,
        org_: String,
        birthday_: String,
        title: String,
        urls: Array<String>,
        geo_: Array<String>
    ) {
        super(ParsedResultType.ADDRESSBOOK)
        if (!phoneNumbers.isEmpty() && !phoneTypes.isEmpty() && phoneNumbers.size != phoneTypes.size) {
            throw IllegalArgumentException("Phone numbers and types lengths differ")
        }
        if (!emails.isEmpty() && !emailTypes_.isEmpty() && emails.size != emailTypes_.size) {
            throw IllegalArgumentException("Emails and types lengths differ")
        }
        if (!addresses.isEmpty() && !addressTypes.isEmpty() && addresses.size != addressTypes.size) {
            throw IllegalArgumentException("Addresses and types lengths differ")
        }
        this.names = names_
        this.nicknames = nicknames_
        this.pronunciation = pronunciation_
        this.phoneNumbers = phoneNumbers
        this.phoneTypes = phoneTypes
        this.emails = emails
        this.emailTypes = emailTypes_
        this.instantMessenger = instantMessenger_
        this.note = note_
        this.addresses = addresses
        this.addressTypes = addressTypes
        this.org = org_
        this.birthday = birthday_
        this.title = title
        this.urls = urls
        this.geo = geo_
        this.flag = true
    }

    public func getNames(): Array<String> {
        return names
    }

    public func getNicknames(): Array<String> {
        return nicknames
    }

    /**
     * In Japanese, the name is written in kanji, which can have multiple readings. Therefore a hint
     * is often provided, called furigana, which spells the name phonetically.
     *
     * @return The pronunciation of the getNames() field, often in hiragana or katakana.
     */
    public func getPronunciation(): String {
        return pronunciation
    }

    public func getPhoneNumbers(): Array<String> {
        return phoneNumbers
    }

    /**
     * @return optional descriptions of the type of each phone number. It could be like "HOME", but,
     * there is no guaranteed or standard format.
     */
    public func getPhoneTypes(): Array<String> {
        return phoneTypes
    }

    public func getEmails(): Array<String> {
        return emails
    }

    /**
     * @return optional descriptions of the type of each e-mail. It could be like "WORK", but,
     * there is no guaranteed or standard format.
     */
    public func getEmailTypes(): Array<String> {
        return emailTypes
    }

    public func getInstantMessenger(): String {
        return instantMessenger
    }

    public func getNote(): String {
        return note
    }

    public func getAddresses(): Array<String> {
        return addresses
    }

    /**
     * @return optional descriptions of the type of each e-mail. It could be like "WORK", but,
     * there is no guaranteed or standard format.
     */
    public func getAddressTypes(): Array<String> {
        return addressTypes
    }

    public func getTitle(): String {
        return title
    }

    public func getOrg(): String {
        return org
    }

    public func getURLs(): Array<String> {
        return urls
    }

    /**
     * @return birthday formatted as yyyyMMdd (e.g. 19780917)
     */
    public func getBirthday(): String {
        return birthday
    }

    /**
     * @return a location as a latitude/longitude pair
     */
    public func getGeo(): Array<String> {
        return geo
    }

    public override func getDisplayResult(): String {
        var result_: ArrayList<Char> = ArrayList<Char>()
        maybeAppend(names, result_)
        maybeAppend(nicknames, result_)
        maybeAppend(pronunciation, result_)
        maybeAppend(title, result_)
        maybeAppend(org, result_)
        maybeAppend(addresses, result_)
        maybeAppend(phoneNumbers, result_)
        maybeAppend(emails, result_)
        maybeAppend(instantMessenger, result_)
        maybeAppend(urls, result_)
        maybeAppend(birthday, result_)
        maybeAppend(geo, result_)
        maybeAppend(note, result_)
        return String(result_)
    }
}
