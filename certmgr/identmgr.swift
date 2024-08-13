
import Foundation
import Security
import OpenSSL

func getSecKeyAndSecCertFromIdentity(_ identity: SecIdentity) -> (SecKey?, SecCertificate?) {
	var key: SecKey?
	let keyStatus = SecIdentityCopyPrivateKey(identity, &key)
	guard keyStatus == errSecSuccess else {
		print("Error extracting key: \(keyStatus)")
		return (nil, nil)
	}

	var certificate: SecCertificate?
	let certStatus = SecIdentityCopyCertificate(identity, &certificate)
	guard certStatus == errSecSuccess else {
		print("Error extracting certificate: \(certStatus)")
		return (key, nil) // Return the extracted key even if certificate extraction fails
	}

	return (key, certificate)
}

func separateSecKeysAndSecCertificates(from identities: [SecIdentity]) -> ([SecKey], [SecCertificate]) {
	var keys: [SecKey] = []
	var certs: [SecCertificate] = []

	for identity in identities {
		let (key, cert) = getSecKeyAndSecCertFromIdentity(identity)
		if let key {
			keys.append(key)
			if let cert {
				certs.append(cert)
			}
		}
	}

	return (keys, certs)
}

func getAllSecIdentitiesFromKeychain() -> [SecIdentity] {
	let query: [String: Any] = [
		kSecClass as String: kSecClassIdentity,
		kSecReturnRef as String: true,
		kSecMatchLimit as String: kSecMatchLimitAll
	]

	var result: AnyObject?
	let status = SecItemCopyMatching(query as CFDictionary, &result)

	if let dictionary = result as? NSDictionary {
		// Handle dictionary
		print("Dictionary")
	} else if let array = result as? NSArray {
		// Handle array
		print("NSArray")
	} else {
		print("Other")
		// Handle other possibilities
	}
	
	guard let array = result as? NSArray  else {
		// Handle array
		print("Error fetching identities, Not NSArray")
	    return []
	}

	return array as! [SecIdentity]

}

func getAllKeysFromKeychain() -> [NSDictionary] {
	
	return []
}
func getAllCertsFromKeychain() -> [NSDictionary] {
	
	return []
}

func getPEMFromIdentity(_ identity: SecIdentity) -> (keyPEM: String?, certPEM: String?) {
	var keyRef: SecKey?
	var certificate: SecCertificate?
	
	var keyPEM: String?
	
	let status = SecIdentityCopyPrivateKey(identity, &keyRef)
	if status == errSecSuccess {
		let keyData = SecKeyCopyExternalRepresentation(keyRef!, nil) as CFData?
		let swiftKeyData = Data(bytes: CFDataGetBytePtr(keyData), count: CFDataGetLength(keyData))
		let keyBase64String = swiftKeyData.base64EncodedString()
		keyPEM = """
		-----BEGIN PRIVATE KEY-----
		\(keyBase64String)
		-----END PRIVATE KEY-----
		"""
	} else {
		print("Error extracting key: \(status)")
	}
	
	var certPEM: String?
	
	let certStatus = SecIdentityCopyCertificate(identity, &certificate)
	if certStatus == errSecSuccess {
		let certData = SecCertificateCopyData(certificate!)
		let swiftCertData = Data(bytes: CFDataGetBytePtr(certData), count: CFDataGetLength(certData))
		let certBase64String = swiftCertData.base64EncodedString()
		certPEM = """
		-----BEGIN CERTIFICATE-----
		\(certBase64String)
		-----END CERTIFICATE-----
		"""
	} else {
		print("Error extracting certificate: \(certStatus)")
	}
	
	return (keyPEM, certPEM)
}

func getItemsInAccessGroup(accessGroup: String) -> [Dictionary<String, Any>] {
	var items: [Dictionary<String, Any>] = []
	
	let query = [
		kSecClass: kSecClassGenericPassword,
		kSecAttrAccessGroup: accessGroup,
		kSecMatchLimit: kSecMatchLimitAll,
		kSecReturnAttributes: true,
		kSecReturnData: false,
		kSecUseDataProtectionKeychain: true
	] as NSDictionary
	
	var result: AnyObject?
	let status = SecItemCopyMatching(query, &result)
	
	if status == errSecSuccess, let itemInfoList = result as? [[String: Any]] {
		items.append(contentsOf: itemInfoList)
	} else {
		print("\(#function): \(#line), Error: Could not get keychain items, status: \(status) \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error")")
	}
	
	return items
}

func getIdentitiesForKey(key: SecKey) -> [SecIdentity]? {
	let query: [String: Any] = [
		kSecClass as String: kSecClassIdentity,
		kSecMatchLimit as String: kSecMatchLimitAll,
		kSecUseDataProtectionKeychain as String: true
	]
	
	var identities: CFTypeRef?
	let identitiesPtr = withUnsafeMutablePointer(to: &identities) {
		$0
	}
	
	let status = SecItemCopyMatching(query as CFDictionary, identitiesPtr)
	guard status == errSecSuccess else {
		// Handle error
		return nil
	}
	
	// Handle the CFTypeRef, which might be a CFArray
	if CFGetTypeID(identities) == CFArrayGetTypeID() {
		let identitiesArray = identities as! CFArray
		// Convert CFArray to Swift array of SecCertificate
		let swiftIdentities = identitiesArray as! [SecIdentity]
		// Process the swiftCertificates array
	    // Only return identites that match the key
		
		var retIdentites : [SecIdentity] = []
		
		swiftIdentities.forEach { identity in
			var privateKey: SecKey?
			let statusKey = SecIdentityCopyPrivateKey(identity, &privateKey) 
			if statusKey == errSecSuccess {
				var certificate: SecCertificate?
				let statusCert = SecIdentityCopyCertificate(identity, &certificate)
				if statusCert == errSecSuccess {
					// add identity to return array
					retIdentites.append(identity)
				}
			}
		}

		return retIdentites
	}
	return nil
}

func getCertificatesForKey(key: SecKey) -> [SecCertificate]? {
	let query: [String: Any] = [
		kSecClass as String: kSecClassCertificate,
		kSecMatchLimit as String: kSecMatchLimitAll
	]
	
	var certificates: CFTypeRef?
	let certificatesPtr = withUnsafeMutablePointer(to: &certificates) {
		$0
	}
	
	let status = SecItemCopyMatching(query as CFDictionary, certificatesPtr)
	guard status == errSecSuccess else {
		// Handle error
		return nil
	}
	
	// Handle the CFTypeRef, which might be a CFArray
	if CFGetTypeID(certificates) == CFArrayGetTypeID() {
		let certificatesArray = certificates as! CFArray
		// Convert CFArray to Swift array of SecCertificate
		let swiftCertificates = certificatesArray as! [SecCertificate]
		// Process the swiftCertificates array
		return swiftCertificates
	}
	return nil
}

func writeDataToFilePath(data: Data, filePath: String) throws {
	let fileURL = URL(fileURLWithPath: filePath)
	try data.write(to: fileURL)
}


func createPKCS12Data(certificate: SecCertificate, key: SecKey, p12Name: String, p12Password: String) -> (data: Data?, error: Error?) {
	// Convert SecCertificate and SecKey to DER-encoded Data
	let certificateData = SecCertificateCopyData(certificate)
	var certificatePointer = CFDataGetBytePtr(certificateData)
	let certificateLength = CFDataGetLength(certificateData)
	guard let certificate = d2i_X509(nil, &certificatePointer, certificateLength) else {
		print("d2i_X509 failed: Couldn't get certificate")
		return (nil, MyError.pkcs12Conversion("d2i_X509 failed: Couldn't get certificate"))
	}
	// debugging
//	dumpCert(cert: certificate)

	// Convert SecKey to DER-encoded Data
	var error: Unmanaged<CFError>?
	guard let derKey = SecKeyCopyExternalRepresentation(key, &error) else {
		if let err: Error = error?.takeRetainedValue() {
			print(err.localizedDescription)
			return (nil, MyError.pkcs12Conversion(err.localizedDescription))
		} else {
			print("Error converting private key to DER data")
			return (nil, MyError.pkcs12Conversion("Error converting private key to DER data"))
		}
	}
	var keyPointer = CFDataGetBytePtr(derKey)
	let keyLength = CFDataGetLength(derKey)
	let privateKey = d2i_AutoPrivateKey(nil,&keyPointer, keyLength)
	// debugging
	//RSA_print_fp(stderr,privateKey,0)

	// Check if private key matches certificate
	guard X509_check_private_key(certificate, privateKey) == 1 else {
		print("Cert does not match key")
		return (nil, MyError.pkcs12Conversion("Cert does not match key"))
	}
			
	// Create P12 keystore
	let passPhrase = UnsafeMutablePointer(mutating: (p12Password as NSString).utf8String)
	let name = UnsafeMutablePointer(mutating: (p12Name as NSString).utf8String)
	guard let p12 = PKCS12_create(passPhrase, name, privateKey, certificate, nil, 0, 0, 0, 0, 0) else {
		let errorCode = ERR_get_error()
		if let errorString = ERR_error_string(errorCode, nil) {
			print("\(errorString)")
			return(nil, MyError.pkcs12Conversion("\(errorString)"))
		} else {
			print("PKCS12_create failed, error code: \(errorCode)")
			return(nil, MyError.pkcs12Conversion("PKCS12_create failed, error code: \(errorCode)"))
		}
	}
	var p12Data :UnsafeMutablePointer<UInt8>? = nil
	defer {
		p12Data?.deallocate()
	}
	let p12Length = i2d_PKCS12(p12, &p12Data)
	guard let data = p12Data else {
		print("Could not create pkcs12 data")
		return (nil, MyError.pkcs12Conversion("Could not create pkcs12 data"))
	}
	let out = Data(bytes: data, count: Int(p12Length))
	
	return (out, nil)
}

func dumpCertFromSecCertificate(cert: SecCertificate) {
	let certificateData = SecCertificateCopyData(cert)
	var certificatePointer = CFDataGetBytePtr(certificateData)
	let certificateLength = CFDataGetLength(certificateData)
	if let certificate = d2i_X509(nil, &certificatePointer, certificateLength) {
		X509_print_fp(stderr, certificate)
	} else {
		print("Failed to dump secCertificate")
	}
}

func createIdentity(certificatePEM: String, privateKeyPEM: String, tag: String) -> (SecCertificate?, SecKey?, SecIdentity?, OSStatus) {
	guard let certificateData = certificatePEM.data(using: .utf8) else {
		print("Error converting certificate PEM to data")
		return (nil, nil, nil, errSecParam)
	}
	guard let privateKeyData = privateKeyPEM.data(using: .utf8) else {
		print("Error converting private key PEM to data")
		return (nil, nil, nil, errSecParam)
	}
	guard let secCertificate = convertPEMToSecCertificate(certificatePEM) else {
		print("Error converting PEM TO SecCertificate")
		return (nil, nil, nil, errSecParam)
	}
	guard let secKey = convertPEMToSecKey(privateKeyPEM) else {
		print("Error converting PEM TO SecKey")
		return (secCertificate, nil, nil, errSecParam)
	}

	let (pkcs12Data, err) = createPKCS12Data(certificate: secCertificate, key: secKey, p12Name: "p12Name", p12Password: "p12pass")
	
	guard let pkcs12Data = pkcs12Data else {
		return (secCertificate, secKey, nil, errSecParam)
	}

	do {
		try writeDataToFilePath(data: pkcs12Data, filePath: "/Users/alfred_eisenberg/Downloads/pkcs12.p12")
	}
	catch {
		print("Error writing data to file: \(error)")
	}
	
	var items: CFArray?
	let status = SecPKCS12Import(pkcs12Data as NSData, [kSecImportExportPassphrase:  "p12pass"] as NSDictionary, &items)
	if status != errSecSuccess {
		print("\(#function): \(#line), SecPKCS12Import failed, status: \(status) \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error")")
		return (secCertificate, secKey, nil, status)
	}

	let dics = items! as! Array<Dictionary<String, Any>>
	let firstItem = dics[0]
	
	let identity = firstItem[kSecImportItemIdentity as String] as! SecIdentity?
#if false
	var privateKey: SecKey?
	let statusKey = SecIdentityCopyPrivateKey(identity!, &privateKey)
	guard statusKey == errSecSuccess else {
		return statusKey
	}
	var certificate: SecCertificate?
	let statuscert = SecIdentityCopyCertificate(identity!, &certificate)
	guard statuscert == errSecSuccess else {
		return statuscert
	}

//	dumpCertFromSecCertificate(cert: certificate!)
	
	let attrs = [
		kSecClass: kSecClassIdentity,
		kSecAttrLabel: tag.data(using: .utf8)!,
//		kSecAttrApplicationTag: tag.data(using: .utf8)!,
//		kSecAttrApplicationLabel: tag.data(using: .utf8)!,
//		kSecImportExportPassphrase: kCFNull!, // Optional passphrase (or your CFString passphrase)
		kSecValueRef: identity!,
		kSecUseDataProtectionKeychain: true
	] as NSDictionary
	
	let stat = SecItemAdd(attrs, nil)
	
	if stat != errSecSuccess {
		print("\(#function): \(#line), SecItemAdd of identity failed, status: \(stat) \(SecCopyErrorMessageString(stat, nil) as String? ?? "Unknown error")")
		return stat
	}

	print("\(#function): \(#line), SecItemAdd of identity Succeeded")
#endif
	dumpCertFromSecCertificate(cert: secCertificate)
	return (secCertificate, secKey, identity, errSecSuccess)
}

// This is no good as you can't add a tag to an identity that makes up identity uniqueness.
// the only tag that is part of uniqueness is kSecAttrApplicationTag
// kSecAttrLabel works fine on iOS for finding and deleting but find doesn't seem to work on macOS.
func findIdentity(forKeyTag tag: String) -> SecIdentity? {
	var query = [
		kSecClass: kSecClassIdentity,
		kSecAttrLabel: tag.data(using: .utf8)!,
//	kSecAttrApplicationLabel: tag.data(using: .utf8),
//	kSecAttrApplicationTag: = tag.data(using: .utf8),
		kSecReturnRef : kCFBooleanTrue!,
		kSecUseDataProtectionKeychain: true
	] as NSDictionary
	
	var result: AnyObject?
	let status = SecItemCopyMatching(query as CFDictionary, &result)
	
	if status == errSecSuccess, let item = result {
		print("\(#function): \(#line),  Find identity Succeeded")
		return item as! SecIdentity // Forced cast (use with caution)
	} else {
		// Handle error (e.g., no item found)
		print("\(#function): \(#line), Can't find identity with tag: \(tag), status: \(status) \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error")")
	}
	return nil
}

func deleteIdentity(forKeyTag tag: String) -> OSStatus {
	var query = [
		kSecClass: kSecClassIdentity,
		kSecAttrLabel: tag.data(using: .utf8)!,
//		kSecAttrApplicationLabel: tag.data(using: .utf8),
//		kSecAttrApplicationTag: tag.data(using: .utf8),
		kSecUseDataProtectionKeychain: true
	] as NSDictionary
	
	let status = SecItemDelete(query as CFDictionary)
	if status != errSecSuccess {
		// Handle error (e.g., no item found)
		print("\(#function): \(#line), Can't delete identity with tag: \(tag), status: \(status) \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error")")
	}
	
	print("\(#function): \(#line),  Delete identity Succeeded")
	return status
}
