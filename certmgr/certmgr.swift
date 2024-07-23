//
//  main.swift
//  cgcertmgr
//
//  Created by Alfred Eisenberg on 7/9/24.
//

import Foundation
import Security
import OpenSSL

// Example usage

let pemCertificate = """
-----BEGIN CERTIFICATE-----
MIIEAjCCAuqgAwIBAgIQZwBinnGe0eANbPsdiAW1ZDANBgkqhkiG9w0BAQsFADBM
MQswCQYDVQQGEwJVUzEMMAoGA1UECgwDUFlBMS8wLQYDVQQDDCZCbHVlQXJtb3It
UG9ydGFibGUgU3ViIENBIHY0LjAgZm9yIFRBQzAeFw0yNDA3MjMxNzAxMjNaFw0y
NTA3MjMxNzAxMjNaMFkxCzAJBgNVBAYTAlVTMQswCQYDVQQIDAJOSDESMBAGA1UE
CgwJSW52aXNpbmV0MQwwCgYDVQQLDANlcGMxGzAZBgNVBAMMEmFsZjIuaW52aXNp
bmV0LmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALauVYHdKy6N
misY3qTCp3EDa+fOYhsqzkAC6qYkkqn+A122It71Lq0BuiA/9S9DiTkRO8Ll2co4
ffAKRkvI6QjoOgIQZIdgbW/V51UTG5vkXjoso+kEjUefy9Z6Y2du0Pxz/mWNZMQT
5decTTh5Bp4qpRqv/n2TWOTwuuZmcIaJO/R0lR64mV2rVwFEeQc6N6wfIlXGjyzu
ULD85ntCRrq1pwqjFKSiUgP+3VKD/vBUuF42Yd3bzX6VMIV+xB97ai2lUO3hV1jy
85IpJ5l6l6yyvq6V+FF+L+sDKbzrhr7G77OHReG9eBXRqhexRGGvwmtCLzXhBA3N
D26KkK/uzDsCAwEAAaOB0jCBzzAJBgNVHRMEAjAAMAsGA1UdDwQEAwIFoDAdBgNV
HSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwVgYDVR0RBE8wTYISYWxmMi5pbnZp
c2luZXQuY29thjdibHVlYXJtb3I6Ly9hbGYyLmludmlzaW5ldC5jb20vQWdlbnQv
aWRlbnRpdHlBY3RpdmF0aW9uMB0GA1UdDgQWBBQgiWm6TJYU9KQH7sob4mm65jUS
pzAfBgNVHSMEGDAWgBSJWYXB8Kj3AXsnSvieggSaDrdyOzANBgkqhkiG9w0BAQsF
AAOCAQEAYh1yr1jy4It+OTxMjGNeYcEFysgeBKOUwknPW+X5/foPhDHLDLo5aZe0
db1giGQMSmcYxwYgl7MqRiNJqdAIuXSHP1oN1h6nSOZm8a9XbZS1zCUbHRIEFLGr
yH4jAoHd+Zf6FAW1qAL1hzzgvmmxscUr/SamScJFyOdwiUobowVBqgW5DPrUgbt2
d4CQBIYxpjDPluctKQuhW3ZQXB4RcANedsiBQcftITf4l2mMxLTdA2nJQIvolHHt
r6ZCzIgNOeJon8WKevXe4u8zhnHOC0SyKAnjOfaT53oyTBd9CkHnhoyPgvRMMxoS
a9Hj/PzNXpxzSsaw6bBg+fib3iSkwg==
-----END CERTIFICATE-----
"""

let pemKey = """
-----BEGIN PRIVATE KEY-----
MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC2rlWB3SsujZor
GN6kwqdxA2vnzmIbKs5AAuqmJJKp/gNdtiLe9S6tAbogP/UvQ4k5ETvC5dnKOH3w
CkZLyOkI6DoCEGSHYG1v1edVExub5F46LKPpBI1Hn8vWemNnbtD8c/5ljWTEE+XX
nE04eQaeKqUar/59k1jk8LrmZnCGiTv0dJUeuJldq1cBRHkHOjesHyJVxo8s7lCw
/OZ7Qka6tacKoxSkolID/t1Sg/7wVLheNmHd281+lTCFfsQfe2otpVDt4VdY8vOS
KSeZepessr6ulfhRfi/rAym864a+xu+zh0XhvXgV0aoXsURhr8JrQi814QQNzQ9u
ipCv7sw7AgMBAAECggEACEBBoo0cl8yFZXkI6/8n2CUQXI+rgwlkhjItTjmlb0yx
ZMiN7aX1Nuhvj73jyJxTWEnlsvB1+2S9B3FueGGyaNGGkvugAW2J7LzPLkx1I9Ue
ORJR3nu6NEuTxbsCogl/sJ2TeeKiLP6SMIeTk02uTnNOh6LFquKpIHoLrwazkIKg
0iM9fgsuK2swwbYKBXk5XT6fLEPwR5GhhaJrGIo0VF5PDNuVt3nZQL5GisjtrOV2
dQD5Yo4aZ0cEAPmYxDbNVIU52fHJvtzwtKUNOGWBSyydcKPuypT1cndKG0ldQUwG
X4iUaqvsDh155V/rGtvV9X+brIeCklqP+eKf7la3VQKBgQDnc0eZek2dP0OROFqq
odANYd2DSVxYr6f0RrBqssTisb8QQEqdc8D+shD1x1+Bq7i7GwY1Mc7SjHEjzSnZ
3NYYTfKeIUXyXxUJuOjXtBpiYfaGveYzQzhe0GQsEa1NOOqmNDh6jq+x/oLenXhV
AkhPYfRdLylHtS2jAyUu8mMgtwKBgQDKDsoV/aQUfURwHtbZyrXjGe/AU3s8o4S8
0DPKmTgVnaNSHKEIzB/c8XGBQ+ByyidvT1/D5KRD3Ok1+pvdWOK8EsgejKia+kJZ
n3spjJvCtT/OEfrYMkvKlyrpjfrlvlluLlj9RY/LNau+8foMQ3NaHAH7eCy8d+2j
x3cAjcYknQKBgQCPL2I8MM2TWnAShyqQJUrw/HptnhTjSMg+9vxtBeuH0y7AfwWq
ItJivwZ/BrivH+1I048jmYy59OiJnYMmpNhOcOqHqU38g5YgTaS+zU0FUFWTRigD
zrIw9fsCyGzOOUfxSp0mNN+83hdYYVLwRFk3wwHKJEMFebCiCHAYexuYQQKBgQCa
k+/kHPPevOqTf/RMD7lQcPIqx3LbNBmDPSCyGL+AQeXFFqPXkBm8NHXqN1xJVQAQ
NsADpDJKvIEpS3zcPHjQ+ulf/amrTlNeLxTQ94Hd1j1mz/iAVxIGfdlVbcoI4rOW
CB0KPaJBCuFGJeZuZVelExItKIXI9VK23gzbPprcPQKBgQC6CTcBQBibwdTDoOcb
u0RVygoT2sNYyGTtipTx0a99rlJkfb+WYAQHgZJe1fQZhXTfJfvn/EUWH/WubAqk
miUEAQ9z4UrTKIotYtNvshSd2OHHT4KagvTseqS9aEBt5sjo4NTudcDhTAS51DF3
BWOVG1VzaVofYc4Acs9tqdJ1Cg==
-----END PRIVATE KEY-----
"""

enum MyError: Error {
	case invalidPEM(String) // Example case with associated value
	case pemConversion(String)
	case pkcs12Conversion(String)
}

func getPrivateKeyDerFromPem(pemString: String) -> (Data?, Error?) {
	guard !pemString.isEmpty else {
		return (nil, MyError.invalidPEM("Null PEM") )
	}
	
	// Initialize OpenSSL library
	SSL_library_init()
	SSL_load_error_strings()
	OpenSSL_add_all_algorithms()
	
	// Convert PEM string to a BIO
	guard let bio = BIO_new(BIO_s_mem()) else {
		return (nil, MyError.pemConversion("Memory Allocation failed"))
	}
	// Free the BIO
	defer { BIO_free(bio) }

	guard let pemData = pemString.data(using: .utf8) else {
		return (nil, MyError.pemConversion("Failed to convert PEM string to data"))
	}
	
	let pemBytes = [UInt8](pemData)
	if BIO_write(bio, pemBytes, Int32(pemBytes.count)) <= 0 {
		return (nil, MyError.pemConversion("\(#function): Failure writing data (length: \(pemData.count))"))
	}
	
	// Read private key from BIO
	guard let privateKey = PEM_read_bio_PrivateKey(bio, nil, nil, nil) else {
		return (nil, MyError.pemConversion("Could not read PrivateKey from pem"))
	}
	
	// privateKey is an EVP_PKEY
	
	// Get the key data from EVP_PKEY
	var keyData: UnsafeMutablePointer<UInt8>?
	let keyLength = i2d_PrivateKey(privateKey, &keyData)
	defer { free(keyData) } // Free the key data

	// Check for errors
	guard keyLength > 0 else {
		return (nil, MyError.pemConversion("Invalid Key Length"))
	}
	
	// Create a Data object from the key data
	let data = Data(bytes: keyData!, count: Int(keyLength))
	
	return (data, nil)
}

/// This function will get the SecCertificate and X509 object from a pem-encoded certificate.  If the x509 object is returned successfully,
/// the caller will have to clean it up when done:
/// X509_free(certificate)
///
/// - Parameters:
///    - pemData: Data representation of pem-encoded cert string
///
/// - Returns: The SecCertificate and X509 if found, otherwise an error
func getCertificateDerFromPem(pemData: Data) -> (cert: Data?, x509: OpaquePointer?, error: Error?) {
	// Initialize OpenSSL library
	SSL_library_init()
	SSL_load_error_strings()
	OpenSSL_add_all_algorithms()
	
	// Load the X.509 certificate
	guard let bio = BIO_new(BIO_s_mem()) else {
		return (nil, nil, MyError.pemConversion("Memory Allocation failed"))
	}
	defer { BIO_free(bio) }
	
	let pemBytes = [UInt8](pemData)
	if BIO_write(bio, pemBytes, Int32(pemBytes.count)) <= 0 {
		return (nil, nil, MyError.pemConversion("\(#function): Failure writing data (length: \(pemData.count))"))
	}
	
	guard let certificate = PEM_read_bio_X509(bio, nil, nil, nil) else {
		return (nil, nil, MyError.pemConversion("Could not read Certificate from pem"))
	}
	// Caller will have to clean up the x509:
	//defer { X509_free(certificate) }
	
	// Convert X.509 certificate to DER format
	var derCertificate: UnsafeMutablePointer<UInt8>?
	let derLength = i2d_X509(certificate, &derCertificate)
	
	guard derLength > 0 else {
		return (nil, nil, MyError.pemConversion("Invalid Key Length"))
	}
	let derData = Data(bytes: derCertificate!, count: Int(derLength))
	
	return (derData, certificate, nil)
}


func convertPEMToSecCertificate(_ pemContent: String) -> SecCertificate? {
	let (data, _, err) = getCertificateDerFromPem(pemData: Data(pemContent.utf8))
	
	guard let data = data else {
		print(err.debugDescription)
		return nil
	}
	if let secCert = SecCertificateCreateWithData(nil, data as CFData) {
		dumpCertFromSecCertificate(cert: secCert)
		return secCert
	}
	return nil
}

func convertPEMToSecKey(_ pemContent: String) -> SecKey? {
	let (data, err) = getPrivateKeyDerFromPem(pemString: pemContent)
	guard let data = data else {
		print(err.debugDescription)
		return nil
	}
	return createPrivateKey(from: data)
}

func createPrivateKey(from data: Data) -> SecKey? {
	let options: [NSString: Any] = [
		kSecAttrKeyType: kSecAttrKeyTypeRSA,
		kSecAttrKeyClass: kSecAttrKeyClassPrivate
	]

	return SecKeyCreateWithData(data as CFData, options as CFDictionary, nil)
}

func addCertificateToKeychain(certificate: SecCertificate, tag: String) -> Bool {
	let addQuery: [NSString: Any] = [
		kSecUseDataProtectionKeychain: true,
		kSecClass: kSecClassCertificate,
		kSecValueRef: certificate
	]

	let status = SecItemAdd(addQuery as CFDictionary, nil)
	if status != errSecSuccess {
		print("\(#function): \(#line), status: \(status) \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error")")
	}
	return status == errSecSuccess
}

func findCertificateInKeychain(tag: String) -> SecCertificate? {
	let query: [NSString: Any] = [
		kSecUseDataProtectionKeychain: true,
		kSecClass: kSecClassCertificate,
		kSecAttrLabel: tag,
		kSecReturnRef: kCFBooleanTrue!,
		kSecMatchLimit: kSecMatchLimitOne
	]

	var item: CFTypeRef?
	let status = SecItemCopyMatching(query as CFDictionary, &item)
	print("\(#function): \(#line), status: \(status)")
	if status != errSecSuccess {
		print("\(#function): \(#line), status: \(status) \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error")")
	}
	guard status == errSecSuccess, let certificate = item else {
		print("\(#function): \(#line), Certificate not found")
		return nil
	}
	return (certificate as! SecCertificate)
}

func deleteCertificateFromKeychain(tag: String) -> Bool {
	let deleteQuery: [NSString: Any] = [
		kSecUseDataProtectionKeychain: true,
		kSecClass: kSecClassCertificate,
		kSecAttrLabel: tag
	]

	let status = SecItemDelete(deleteQuery as CFDictionary)
	if status != errSecSuccess {
		print("\(#function): \(#line), status: \(status) \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error")")
	}
	return status == errSecSuccess
}

func addPrivateKeyToKeychain(privateKey: SecKey, tag: String) -> Bool {
	let addQuery: [NSString: Any] = [
		kSecUseDataProtectionKeychain: true,
		kSecClass: kSecClassKey,
		kSecAttrKeyClass: kSecAttrKeyClassPrivate,
		kSecAttrApplicationTag: tag,
		kSecValueRef: privateKey
	]

	let status = SecItemAdd(addQuery as CFDictionary, nil)
	if status != errSecSuccess {
		if status == errSecDuplicateItem {
			print("\(#function): \(#line), Key already exists: errSecDuplicateItem")
		}
		print("\(#function): \(#line), status: \(status) \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error")")
	}
	return status == errSecSuccess
}

func findPrivateKeyInKeychain(tag: String) -> SecKey? {
	let query: [NSString: Any] = [
		kSecUseDataProtectionKeychain: true,
		kSecClass: kSecClassKey,
		kSecAttrApplicationTag: tag,
		kSecAttrKeyClass: kSecAttrKeyClassPrivate,
		kSecReturnRef: kCFBooleanTrue!,
		kSecMatchLimit: kSecMatchLimitOne
	]

	var item: CFTypeRef?
	let status = SecItemCopyMatching(query as CFDictionary, &item)
	print("\(#function): \(#line), findPrivateKeyInKeychain status: \(status)")
	if status != errSecSuccess {
		print("\(#function): \(#line), status: \(status) \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error")")
	}
	guard status == errSecSuccess, let privateKey = item else {
		print("\(#function): \(#line), Private key not found")
		return nil
	}
	return (privateKey as! SecKey)
}

func deletePrivateKeyFromKeychain(tag: String) -> Bool {
	let deleteQuery: [NSString: Any] = [
		kSecUseDataProtectionKeychain: true,
		kSecClass: kSecClassKey,
		kSecAttrKeyClass: kSecAttrKeyClassPrivate,
		kSecAttrApplicationTag: tag,
	]

	let status = SecItemDelete(deleteQuery as CFDictionary)
	if status != errSecSuccess {
		print("\(#function): \(#line), status: \(status) \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error")")
	}
	return status == errSecSuccess
}

func findCertificatesFromKey(key: SecKey) -> [SecCertificate]? {
	let certQuery: [String: Any] = [
		kSecUseDataProtectionKeychain as String: true,
		kSecClass as String: kSecClassCertificate,
//		kSecAttrKeyType as String: kSecAttrKeyTypeRSA,  // or other key type as required
		kSecReturnRef as String: true,
		kSecMatchLimit as String: kSecMatchLimitAll
	]

	var certItems: CFTypeRef?
	let certStatus = SecItemCopyMatching(certQuery as CFDictionary, &certItems)

	if certStatus == errSecSuccess {
		if let certArray = certItems as? [SecCertificate] {
			for certificate in certArray {
				// Here you can check if the certificate is associated with the key
				print("Certificate found: \(certificate)")
				// You can use SecCertificateCopyValues to get more info about the certificate
			}
			return certArray
		} else {
			print("No certificates found")
		}
	} else {
		print("\(#function): \(#line), certStatus: \(certStatus) \(SecCopyErrorMessageString(certStatus, nil) as String? ?? "Unknown error")")
	}
	return nil
}

func findIdentity() {
	let (secIdentity, secCertificate) = findIdentityAndCertificate(forKeyTag: "com.example.mykey")

}

func findIdentityAndCertificate(forKeyTag tag: String) -> (SecIdentity?, SecCertificate?) {
	if let key = findPrivateKeyInKeychain(tag: tag) {
		print("Key found: \(key)")
		// Use the key to find associated certificates
		if let certArray = findCertificatesFromKey(key: key) {
			print("certs found: \(certArray)")

		}
	}
	return (nil, nil)
}

/*
func findIdentityAndCertificate(forKeyTag tag: String) -> (SecIdentity?, SecCertificate?) {
  var query = [String: Any]()
  query[kSecClass as String] = kSecClassIdentity
  query[kSecAttrApplicationTag as String] = tag.data(using: .utf8)
  query[kSecReturnRef as String] = kCFBooleanTrue!
  query[kSecUseDataProtectionKeychain as String] = true
  
  return findItems(query: query)
}

func findItems(query: [String: Any]) -> (SecIdentity?, SecCertificate?) {
  var result: AnyObject?
  let status = SecItemCopyMatching(query as CFDictionary, &result)
  
  if status == errSecSuccess, let itemRef = result as? SecCFTypeRef {
	let identity = itemRef as? SecIdentity
	let certificate = extractCertificate(from: identity)
	return (identity, certificate)
  } else if let dictionary = result as? [String: Any] {
	   // Handle potential dictionary result (less likely)
	   print("Found dictionary result: \(dictionary)")
   } else {
	   // Handle unexpected result type
	   print("Unexpected result type: \(type(of: result))")
   }
  return (nil, nil) // Handle no successful search result
}

func extractCertificate(from identity: SecIdentity?) -> SecCertificate? {
  guard let identityRef = identity else { return nil }
  var certificate: SecCertificate?
  let status = SecIdentityCopyCertificate(identityRef, &certificate)
  if status != errSecSuccess {
	print("Error extracting certificate: \(status)")
  }
  return certificate
}
*/
func addCert() {
	if let certificate = convertPEMToSecCertificate(pemCertificate)  {
		let certificateAdded = addCertificateToKeychain(certificate: certificate, tag: "testdeletejune27.invisinet.com")
		if certificateAdded {
			print("\(#function): \(#line), Certificate added: \(certificateAdded)")
		}
	}
}

func findCert() {
	if let foundCertificate = findCertificateInKeychain(tag: "testdeletejune27.invisinet.com") {
		print("\(#function): \(#line), Certificate found: \(String(describing: foundCertificate))")
	}
}

func deleteCert() {
	let certificateDeleted = deleteCertificateFromKeychain(tag: "testdeletejune27.invisinet.com")
	print("\(#function): \(#line), Certificate deleted: \(certificateDeleted)")
}

func addKey() {
	if let privateKey = convertPEMToSecKey(pemKey) {
		let keyAdded = addPrivateKeyToKeychain(privateKey: privateKey, tag: "com.example.mykey")
		if keyAdded {
			print("\(#function): \(#line), Key added: \(keyAdded)")
		}
	}
}

func findKey() {
	if let foundPrivateKey = findPrivateKeyInKeychain(tag: "com.example.mykey") {
		print("\(#function): \(#line), Private key found: \(foundPrivateKey)")
	} 
}

func deleteKey() {
	let keyDeleted = deletePrivateKeyFromKeychain(tag: "com.example.mykey")
	print("\(#function): \(#line), Private key deleted: \(keyDeleted)")
}

func tryCerts() {
	print("===Trying Certs===")
	if let certificate = convertPEMToSecCertificate(pemCertificate)  {
		let certificateAdded = addCertificateToKeychain(certificate: certificate, tag: "com.example.mycert")
		if certificateAdded {
			print("\(#function): \(#line), Certificate added: \(certificateAdded)")
			if let foundCertificate = findCertificateInKeychain(tag: "com.example.mycert") {
				print("\(#function): \(#line), Certificate found: \(String(describing: foundCertificate))")
				let certificateDeleted = deleteCertificateFromKeychain(tag: "com.example.mycert")
				print("\(#function): \(#line), Certificate deleted: \(certificateDeleted)")
			}
		}
	}
}

func tryKeys() {
	print("===Trying Keys===")
	if let privateKey = convertPEMToSecKey(pemKey) {
		let keyAdded = addPrivateKeyToKeychain(privateKey: privateKey, tag: "com.example.mykey")
		if keyAdded {
			print("\(#function): \(#line), Key added: \(keyAdded)")
			if let foundPrivateKey = findPrivateKeyInKeychain(tag: "com.example.mykey") {
				print("\(#function): \(#line), Private key found: \(foundPrivateKey)")
				let keyDeleted = deletePrivateKeyFromKeychain(tag: "com.example.mykey")
				print("\(#function): \(#line), Private key deleted: \(keyDeleted)")
			}
		}
	}
}

	


