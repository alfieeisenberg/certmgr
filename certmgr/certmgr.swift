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
let pemCertificate1 = """
 -----BEGIN CERTIFICATE-----
 MIIEJjCCAw6gAwIBAgIQZwBinnGe0eANbPsdiAW1WDANBgkqhkiG9w0BAQsFADBM
 MQswCQYDVQQGEwJVUzEMMAoGA1UECgwDUFlBMS8wLQYDVQQDDCZCbHVlQXJtb3It
 UG9ydGFibGUgU3ViIENBIHY0LjAgZm9yIFRBQzAeFw0yNDA2MjcxNDE2NTRaFw0y
 NTA2MjcxNDE2NTRaMGUxCzAJBgNVBAYTAlVTMQswCQYDVQQIDAJOSDESMBAGA1UE
 CgwJSW52aXNpbmV0MQwwCgYDVQQLDANlcGMxJzAlBgNVBAMMHnRlc3RkZWxldGVq
 dW5lMjcuaW52aXNpbmV0LmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
 ggEBANHiYbDqNFSAgkUD4EIZ15HS24wFV9n7EZ5qYczOd/pKO5CqWbnlab0i8/KK
 FU8j4DxD1rKrkymFLB3uUMO2qIRAodSdSZlwOq9oRjCiqBsHfHz88dEouArh5pAz
 qBFzkBIcTESVd5Vi+j1vc2XU4CraANhQ7XamjsLjlcju6lGexxASBdyGMhe3ob7b
 cWYVtQmrp9OO2Y08hbCcxLzV2SMj6OT3J6pSN7phPhzAjF/bgJ9HHYvvDiYTl6SR
 QmOaueR0npl45RvPPo2C+W2MBRr0bIoznXqXNxMdwzgfQjXBDN0jq4qNX5TWLVMj
 tQIdg6jRdewJXx2Vqhec8eolfI0CAwEAAaOB6jCB5zAJBgNVHRMEAjAAMAsGA1Ud
 DwQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwbgYDVR0RBGcw
 ZYIedGVzdGRlbGV0ZWp1bmUyNy5pbnZpc2luZXQuY29thkNibHVlYXJtb3I6Ly90
 ZXN0ZGVsZXRlanVuZTI3LmludmlzaW5ldC5jb20vQWdlbnQvaWRlbnRpdHlBY3Rp
 dmF0aW9uMB0GA1UdDgQWBBQP1+OCUAgsPoK5+jBIrOpyVGPzRzAfBgNVHSMEGDAW
 gBSJWYXB8Kj3AXsnSvieggSaDrdyOzANBgkqhkiG9w0BAQsFAAOCAQEAuJql/GlA
 RK+nAHPJqgRc4aaMeVEL/kn4taOpSL5UyagTrDWawgXnRVAt+s0i/evbjqUK3n/T
 XbW5xS1W6IN67xwm5BARNEPOow8GhvniWZLDvHIkA/Mth51RH+uGLB2PAvP3pKP8
 f81Pp1rc093xAvqx4lnwIoT15FjN6o+sLGhKdEUJr75UGvQxo2FLSq2XEnWMaK64
 u/HD6OwVCQZkY0i+8t1Zy7RsPpsXWXFNyjdVSgdM7+/RSwNtdNEiB61o2XsqmNSu
 kQLwXMrgilZ/5VFnvXkbTG0DFQyOpsMA6eByKNBLOgWhN8ZtOreqORe7FsE0GAsu
 A76X5eeqmTS4Pw==
 -----END CERTIFICATE-----
 """
	
let pemKey1 = """
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDR4mGw6jRUgIJF
A+BCGdeR0tuMBVfZ+xGeamHMznf6SjuQqlm55Wm9IvPyihVPI+A8Q9ayq5MphSwd
7lDDtqiEQKHUnUmZcDqvaEYwoqgbB3x8/PHRKLgK4eaQM6gRc5ASHExElXeVYvo9
b3Nl1OAq2gDYUO12po7C45XI7upRnscQEgXchjIXt6G+23FmFbUJq6fTjtmNPIWw
nMS81dkjI+jk9yeqUje6YT4cwIxf24CfRx2L7w4mE5ekkUJjmrnkdJ6ZeOUbzz6N
gvltjAUa9GyKM516lzcTHcM4H0I1wQzdI6uKjV+U1i1TI7UCHYOo0XXsCV8dlaoX
nPHqJXyNAgMBAAECggEAASQSJGBNiwUM0Du6aRmTXKlRBLSVuutct+f7op2ftNZY
9wsaBELtPXg2a8PY5E59Xk5/GQcKPIBLElmUik/QoDFqv8lgGEuuIfx23zZPJCB5
CoPke57VS0fZlUCWogunBZYuSvQmC4OXeSSFM9FBq7H2LbbY55t1rLUIgCheUTXB
eSmAr4DndIDqGrZxwCbAX8vei6x+kj3if7a5Fn6+0lMK431hAz+LOSuK+M++AgCq
UM8QfUekmDtIkc3k3bu6Z75MOpdjDea0QyKd3RInXdEX5QlG9Zjg2hZiec2/1nvS
104jA6dVNsg8hostwFIIa+kyhf4dNm4+ttANEcTc0QKBgQDwr/VFR1sQ3GkHLG5t
oO+bRzJ31LlWoPPM1J9jcKQw2I7o9EHndGM5PwmYKcGuJo9tqXtg5U67lBYJvwEI
dJYvsCIKOSxxyzqjjI+Rs/W+DX4/EF/GNeAp+wgInsEjw7SoUuxZcL/qmpDdGmlD
0W0ik3RZKWfSHz8F9C49wEg1nQKBgQDfPL0b1wkGtb3ooMNFz+0iKzamtmgb0HhV
+0TX45QOpCUa3UsTkPmdI018YBGAc2ELQPmxQ+dfxlsdX5JCdx+/OKr8pv9GvAEs
/oXR8UQLEilQxg4M5OYn4usbS2rzs4EcaHU/7VwDiU6dFvyzTTqJAYRSsrkd8C03
xL8XdYunsQKBgB9sGW1N/4mX/O4+0rvlQuLWzLPwRbIVmT6ok5Z74jOuUhn/qYr6
GuoiXLJM4UhHKHp8oerohPrgPnBPS2c7MVBQgmErTa4dhi5L74JqKC8Du/Onw5kw
928DouzdLQHqTu+aw9h5a9TJERiMlimQcdsNvSbWzQMVqTixxEezjrnRAoGACFsI
pQMedl7VFeD2jiVjNdUyPXk0Wl4qMuWtxPrirs2cCe5gggH6JdSNcOtTnGA1MKuk
7OqivWX6QRYzrkMxMAIZ/Ezv3yDoVlvMfHgwWM28OCbBnd/vcWy/6gyfmzGL0pli
Uhs7R3KbO6wBl2B7oWcqIcJIxYMY3i6CDIm8yXECgYA77h4+nvmVesgYTNcEs279
X/KXKjrPttWJXpGs8SjoTO7I3pQe8mMlm8eCBWCxwNrUSrk0GWhz8UZWBpjlnE9/
SNkWF/BPI6rvT/EuNw+czeIBzGE+3fyvF2wIsXJ82KSpZ9LAKzzSO8hze2JbfNXs
S8PypMwjZDMS7p+uemTpfg==
-----END PRIVATE KEY-----
"""

let pemCertificate = """
-----BEGIN CERTIFICATE-----
MIIEFDCCAvygAwIBAgIQZwBinnGe0eANbPsdiAW1YjANBgkqhkiG9w0BAQsFADBM
MQswCQYDVQQGEwJVUzEMMAoGA1UECgwDUFlBMS8wLQYDVQQDDCZCbHVlQXJtb3It
UG9ydGFibGUgU3ViIENBIHY0LjAgZm9yIFRBQzAeFw0yNDA3MDkxOTMzMjdaFw0y
NTA3MDkxOTMzMjdaMF8xCzAJBgNVBAYTAlVTMQswCQYDVQQIDAJOSDESMBAGA1UE
CgwJSW52aXNpbmV0MQwwCgYDVQQLDANlcGMxITAfBgNVBAMMGGJpbGxnd3kxMjMu
aW52aXNpbmV0LmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANCZ
Dnj80Lrs6egilyNX2FbHU6aSWdOuSkhhybWPuNGbhln2MpV/k9+/lC1aioi6NrgE
lgIGrmqht8uqvZQC1IEW+zJSMDLW+AVPOg9m4f46/19hmPac2jsXRarYjPYKknk7
fjI1eugVCG+l+EIglaro63MCY4P7tw9b0lHpx89rBviwuEJ6RpQFyw2M8lAYoAr2
gfXgxCCDF4Hzyt3kt+HUNR4SiF0qbGXhC7IINRnXGrfeubvn67C0kKwekc/RQ7QY
b8lG9wrOsAITJJg0revygspTzpNGgwOqmxpMDuvgTkeD4Z3cDpIAG3D47Jh+yvKq
vwqEuFgZGRK9BW7kv/ECAwEAAaOB3jCB2zAJBgNVHRMEAjAAMAsGA1UdDwQEAwIF
oDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwYgYDVR0RBFswWYIYYmls
bGd3eTEyMy5pbnZpc2luZXQuY29thj1ibHVlYXJtb3I6Ly9iaWxsZ3d5MTIzLmlu
dmlzaW5ldC5jb20vQWdlbnQvaWRlbnRpdHlBY3RpdmF0aW9uMB0GA1UdDgQWBBQU
JQ1Kyl/oDbpKL9G66AJ6nMQ7XDAfBgNVHSMEGDAWgBSJWYXB8Kj3AXsnSvieggSa
DrdyOzANBgkqhkiG9w0BAQsFAAOCAQEAoFbONOLTC9rVD0nutgSzDj9Le2okytgZ
O7CY2WLJ+snmaYFa67omjtwMHTP9vb3Spf8Nq/kS19V1Mhuzcwbg5vbswJQrSggQ
iTgsTsmfJXFtHBVOm+HxmJzmy2LNcrRTjpMjTRt48hMOVnXR53qGdI3Tiwt4SJN7
rBOTsl0MuvgZdgcbFo66yYeHxLT37n6U7pUAmdSHnGlcM+QKoUwgRI+KlIQP+d7u
B0uSVO0UvpZ9IsZ6EY0uhNqTyjRQkwW0HGBNd5K47AZ4KRFMc4Hn7L9A93HNf3TG
cPTwyJXitzR3tRn492YcFF1iE9eUtm99unNkUZXaUPbl0oSWINq3IA==
-----END CERTIFICATE-----
"""
let pemKey = """
-----BEGIN PRIVATE KEY-----
MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDQmQ54/NC67Ono
IpcjV9hWx1OmklnTrkpIYcm1j7jRm4ZZ9jKVf5Pfv5QtWoqIuja4BJYCBq5qobfL
qr2UAtSBFvsyUjAy1vgFTzoPZuH+Ov9fYZj2nNo7F0Wq2Iz2CpJ5O34yNXroFQhv
pfhCIJWq6OtzAmOD+7cPW9JR6cfPawb4sLhCekaUBcsNjPJQGKAK9oH14MQggxeB
88rd5Lfh1DUeEohdKmxl4QuyCDUZ1xq33rm75+uwtJCsHpHP0UO0GG/JRvcKzrAC
EySYNK3r8oLKU86TRoMDqpsaTA7r4E5Hg+Gd3A6SABtw+OyYfsryqr8KhLhYGRkS
vQVu5L/xAgMBAAECggEAA4OzTuOHisFcwYNPrjyX0a0jDNPmEonFs57TfK0dYolZ
w/XrbUG3K+u44zi6y8nuC79RXbBfdj7KRMgC0KsUNHvpeIlnntD+CxeGIBCjhG/Z
sfGILQ4rI8K6cuyaF2J0jE6ty3UY4IR2M2ywQuufSeq0XigvUApzekfu7Qq2H0RO
Xod93ojzSUZeebxIowVuO75HFoTs6qrUt4olDJLCjYYqBo0owbmmL2dgzCnDckAq
gul8wcYqOjwFbgfR1SB+guAQCcN6Vk9OZEKznEk4Q3gL/Aqsd0K+LMyzvMElFaYy
LNz9B4xsIHZ/shiJ5qG/uhSPqg2aCCMw/INiKqDavwKBgQD+FRWQkyN9ROCNBMlh
hwmQHyrl4+b88NUZOw8gK45HyLBwSsYNUxYzBOXxky8arlYJvy95JupwevdtBf1t
LQEAy2AvCRNhlL7YDZsvS8wpKKz2siPs/b4nGTgvgqAYiqs5+8s+ippnYbCYacCy
U5jLGEhXhOAfdnsi0cjVPcfO4wKBgQDSLBdVbidqKQJKfb+7JJ+jaf729qctaQFB
AI8h7rOI4PtggC05uS98t/yjwIKPOt36Hb35YeKzze3ANlvo8n5s3YkDsue1Crif
Iu7FqAcrTXWDG+/tgDs+2PiJUV8aZxfUaFr0yx+5TK7XoZOneBoyvrBdaPyQcM8z
feIP9ku6GwKBgQCjDVLGcbY/qJjVxnGZdbgsVeQInYVZYw/N3jmpsmnfJSodFc8d
M+m2GfmaWpLK83/hR2CmxdODFVZ9D2//xPa01M7HwHJAl90U9z5UTrcY3rKIqe8m
IfwKSUPmMVSeCzcwwaY/X2EQ4P8cABmaFs2h39Zk26+cYUNKKAhS2A/GcwKBgQCd
FbVO9ejhsMr0kC44mrPyeKvHPC1RhHUad2eDjhyEBtv7kXG7/gxfJEjgv2cV1ILK
iWZPOXkuuJClpDtnza7ugVoB+Lq0FtJMpthdxSuuktNs7fmSwtAFNjf0smvpmPo3
mNO6uQL6BTV9F1f7yImUOfApsOlsr9Q+AS1wjr6k1wKBgQC82zQrld/cnp4ZYY2y
5xm0w/Nz5VGE2ow13lg/1hT43a/5T3eO5YO7s41hCRKPvIpPpft/RNoPkmG6py7r
e2Z5FijIMcJ2voxAZzh5bKTE5Zmac3WR1ny8Cm5y4pQ9BWwN2jvJPdmyUKG534iY
UkUDBmxRAhhqQq/Uamc64K17kg==
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

	


