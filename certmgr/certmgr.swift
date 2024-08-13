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
MIIECDCCAvCgAwIBAgIQZwBinnGe0eANbPsdiAW1ZTANBgkqhkiG9w0BAQsFADBM
MQswCQYDVQQGEwJVUzEMMAoGA1UECgwDUFlBMS8wLQYDVQQDDCZCbHVlQXJtb3It
UG9ydGFibGUgU3ViIENBIHY0LjAgZm9yIFRBQzAeFw0yNDA3MjQxOTE5MTVaFw0y
NTA3MjQxOTE5MTVaMFsxCzAJBgNVBAYTAlVTMQswCQYDVQQIDAJOSDESMBAGA1UE
CgwJSW52aXNpbmV0MQwwCgYDVQQLDANlcGMxHTAbBgNVBAMMFGFsZnJlZC5pbnZp
c2luZXQuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtwtXVj87
fgV2tOe4VB8UCPi4LA2H052b6jaWAYaB/moh8G2+bb1VSGwWzpOufjUfPlxuSQ9V
ksYMiLah+LMcM3JhUOS85XhrufgNyw/BPncxtUbVmbjRNF9DaORlhuZ6A6aHr6Ea
E2Ml+gTW2C4ZV6hL3Blb02WLZbWY610Yw+G6KzZLMdQtNxnbkLifuwAZ6wXn4Xns
5VczpSwb3E6wCygypQXjEW1+uaCACSM9KKmQysIIlhjJJqocgPxXUw1wmPPnVuB4
DOMTvmoIYdbVmc8ro5HBxziBluc6Z12FCbDPC6VoK6OCFnxOd5sl5NOlcPfyo7Ao
ZdqimM1zQ1ikywIDAQABo4HWMIHTMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgWgMB0G
A1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjBaBgNVHREEUzBRghRhbGZyZWQu
aW52aXNpbmV0LmNvbYY5Ymx1ZWFybW9yOi8vYWxmcmVkLmludmlzaW5ldC5jb20v
QWdlbnQvaWRlbnRpdHlBY3RpdmF0aW9uMB0GA1UdDgQWBBTA+W21KmElZJXJnDcg
ESkE5inQ3TAfBgNVHSMEGDAWgBSJWYXB8Kj3AXsnSvieggSaDrdyOzANBgkqhkiG
9w0BAQsFAAOCAQEAVHfpTPAe9qfLUWnCcrF5Ns5V5BfdH7f8n15KFcdGaChMCVGe
U6/a2Q3M6IWYHiJJJIe0HLUcWeg0vKlnmHG9hw0D1QtQ3DsznG8UNpuFguqN86WL
+p704Iw4xv8uTMW1yPt3cMnWy12dv6NCQ8bAOWpFPZwK8bUY0bSgxzG683KvEE6I
6R0RCP7ElvhkPM6xQt1JghPJ0hxKEWhPtVbcCHRvplJvA3WvuD19C9yeWFGPSwM7
5HCNb6yjx+O7AVZjawvOvcEhysBZiW/i/Dzcoxk6tq6HnvRYLUYqdaFGTbujYly7
ypaRp7Orpd2b1sa3ugVnEpRADrbtn2GzPBTd4Q==
-----END CERTIFICATE-----
"""

let pemKey = """
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC3C1dWPzt+BXa0
57hUHxQI+LgsDYfTnZvqNpYBhoH+aiHwbb5tvVVIbBbOk65+NR8+XG5JD1WSxgyI
tqH4sxwzcmFQ5LzleGu5+A3LD8E+dzG1RtWZuNE0X0No5GWG5noDpoevoRoTYyX6
BNbYLhlXqEvcGVvTZYtltZjrXRjD4borNksx1C03GduQuJ+7ABnrBefheezlVzOl
LBvcTrALKDKlBeMRbX65oIAJIz0oqZDKwgiWGMkmqhyA/FdTDXCY8+dW4HgM4xO+
aghh1tWZzyujkcHHOIGW5zpnXYUJsM8LpWgro4IWfE53myXk06Vw9/KjsChl2qKY
zXNDWKTLAgMBAAECggEANFI0k72dVsdfCBTYNotvoaTemBECCzYY9BjIRgVZsQxL
STtFXH7rGrlyx3elQAQVOzEWgSG19y9PM+DoaXthCz+dm47Wg80pFc5Wuv104lMV
zVhDBB61BgBY92mZr7a/l72JOWWWW4ZSu6WYd9Ctg8XicTZ6bfGvp9IBtP02b/7g
6/iUnsr8qB5L91bBdZYG5GJR8VnS2L/QJDgVglFqtSCXcGVXVCS9jex77Fueiesb
59mIJZIdkEQWC5TkhdTD5Nc5gR9+808vb++8/emEDG/66s9S7IjOCWJOWM5jkUIT
AynGCgbzkSolHfUff7llCQuD5ZBQYu1uG5tMWgxKUQKBgQDhJKGUzJQWKE6a+oYZ
enwaanZ6cfD9hjNDlTxbzcZiC8otv1KjMDnwgPbmWvgP7TuVfjwF15CkRy9puzCl
i/s3h4xTvmau33rknrttYoEe/YWe1uVgyENkeUYws6HPd7uvSimndfLQaO/vjKEG
CNvjU9FEvhgljSPs9wkwcQ4OCQKBgQDQIaHWUEPiDAi7tMj5HxUmGix7sYslbOgK
2LzSYIOd8r/tIfuSgnu6dj1esAUQfFw7dcY521JomFcfSHRa+gpXcEi6cUhNH2JT
L5moKYqSqBgWwgLDeRr8wLKMIE+fN8TFYZEOC/nIrP3xWD6xXDxZjSlYSy6RK/fC
AzYcWQNRMwKBgGYi+xaI9IlUwcw26Mz4LwLA13zW4e/xiKIZOqefI2dpV9AHIpMb
lr1PlDKOhEidY9F+0fYIg/qyvISnwfroFRBs8rEvCGA+y/6ZMAgAjvkjJBIaBTcx
wrj692eypi57b+6mo1zv+jan1GmFD6uwKyjm5mHcJxIqBGlE7KtILosZAoGBAK1G
IrcKsckiXa7v7pVAZFoJVllQUVjCF1jYYjL/OPQpYdGpBglOanWs9KC9CCpWbm7u
OS53wl7j3TxlFMGdAzkSeOoHX7sdUr2Qlmsi0oQQP6XKtYRJccdVIhB44fDa/A2b
kajRHY4NP4lK/z6nXHLti6s/RDCGG0lBZS4qiRFzAoGBANLrlST7ixXGVMo1++iB
7KeMc7q5SotR0S7LshWkeNY9cBpJh+bQIFJ9aVhU1AJS0ubd6c2197E8PZGrdf/U
0D7V7QE+RoSD6LT8lV9/ntLjei8XndImAltdNfe98y5eXOyLUumCR8sOGV5oKrPa
KHWzGeQ2mk7h2MnHp62DE5zA
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

func addPrivateKeyToKeychain(privateKey: SecKey, tag: String) -> Bool? {
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

func addSecKeyToKeychain(secKey: SecKey) {
	if let keyAdded = addPrivateKeyToKeychain(privateKey: secKey, tag: "com.example.mykey") {
		print("\(#function): \(#line), Key added: \(keyAdded)")
	}
}

func addKey() {
	if let privateKey = convertPEMToSecKey(pemKey) {
		addSecKeyToKeychain(secKey: privateKey)
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
		if let keyAdded = addPrivateKeyToKeychain(privateKey: privateKey, tag: "com.example.mykey") {
			print("\(#function): \(#line), Key added: \(keyAdded)")
			if let foundPrivateKey = findPrivateKeyInKeychain(tag: "com.example.mykey") {
				print("\(#function): \(#line), Private key found: \(foundPrivateKey)")
				let keyDeleted = deletePrivateKeyFromKeychain(tag: "com.example.mykey")
				print("\(#function): \(#line), Private key deleted: \(keyDeleted)")
			}
		}
	}
}

	


