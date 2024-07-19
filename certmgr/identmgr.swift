
import Foundation
import Security
import OpenSSL

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

func addIdentityToKeychain(certificatePEM: String, privateKeyPEM: String, tag: String) -> OSStatus {
	guard let certificateData = certificatePEM.data(using: .utf8) else {
		print("Error converting certificate PEM to data")
		return errSecParam
	}
	guard let privateKeyData = privateKeyPEM.data(using: .utf8) else {
		print("Error converting private key PEM to data")
		return errSecParam
	}
	guard let secCertificate = convertPEMToSecCertificate(certificatePEM) else {
		print("Error converting PEM TO SecCertificate")
		return errSecParam
	}
	guard let secKey = convertPEMToSecKey(privateKeyPEM) else {
		print("Error converting PEM TO SecKey")
		return errSecParam
	}

	let (pkcs12Data, err) = createPKCS12Data(certificate: secCertificate, key: secKey, p12Name: "p12Name", p12Password: "")
	
	guard let pkcs12Data = pkcs12Data else {
		return errSecParam
	}

	var importResult: CFArray? = nil
	let status = SecPKCS12Import(pkcs12Data as NSData, [kSecImportExportPassphrase as String: ""] as CFDictionary, &importResult)
	if status != errSecSuccess {
		print("\(#function): \(#line), SecPKCS12Import failed, status: \(status) \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error")")
		return status
	}

	var items = [String: Any]()
	items[kSecClass as String] = kSecClassIdentity
	items[kSecAttrApplicationTag as String] = tag.data(using: .utf8)
	items[kSecImportExportPassphrase as String] = kCFNull // Optional passphrase (or your CFString passphrase)
	items[kSecValueRef as String] = importResult
	items[kSecUseDataProtectionKeychain as String] = true
	
	let stat = SecItemAdd(items as CFDictionary, nil)
	
	if stat != errSecSuccess {
		print("\(#function): \(#line), SecItemAdd of identity failed, status: \(stat) \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error")")
		return stat
	}
	
	return stat
}

func findIdentity(forKeyTag tag: String) -> SecIdentity? {
	var query = [String: Any]()
	query[kSecClass as String] = kSecClassIdentity
	query[kSecAttrApplicationTag as String] = tag.data(using: .utf8)
	query[kSecReturnRef as String] = kCFBooleanTrue!
	query[kSecUseDataProtectionKeychain as String] = true
	
	var result: AnyObject?
	let status = SecItemCopyMatching(query as CFDictionary, &result)
	
	if status == errSecSuccess, let item = result {
		return item as! SecIdentity // Forced cast (use with caution)
	} else {
		// Handle error (e.g., no item found)
		print("\(#function): \(#line), Can't find identity with tag: \(tag), status: \(status) \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error")")
	}
	return nil
}

func deleteIdentity(forKeyTag tag: String) -> OSStatus {
  var query = [String: Any]()
  query[kSecClass as String] = kSecClassIdentity
  query[kSecAttrApplicationTag as String] = tag.data(using: .utf8)
  
  let status = SecItemDelete(query as CFDictionary)
  return status
}
