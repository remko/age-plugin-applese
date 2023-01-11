import CryptoKit
import Foundation

@testable import age_plugin_applese

class DummyCrypto: Crypto {
  // If more keys are needed, add them to the front
  var dummyKeys = [
    "t8Y0uUHLtBvCtuUz0Hdw2lqbwZf6TgYzYKFWMEEFSs8",
    "HxEmObcQ6bcAUC8w6kPWrnlUIwBQoi66ZNpQZ0cAXww",
    "dCDteyAKpkwYd8jCunOz0mvWmy+24zvWV41YBD+Pkeg",
    "NkkLXSZ+yhx9imKKw9cOsbey4C1XZAPuSDMCgTLENrY",
    "bQrp04tXb+diJ6x28Kd8EDt9sCmI5diS36Zy3n49DHg",
    "m8/qMMkYDelvL+ihdUFYyKXBn+7We21fZ5zH/I61y3M",
    "lQq/Pq0GA2QFGTEiNMQIxZHzBnt+nPRXK5gL3X6nnJY",
    "VoUn+n/vzkuDzWgMV9n3e1L+tTSIl0Sg7lXSNDR5XqY",
    "3naom0zZxBZcSZCfoNzyjLVmG6hyRKX8bCU3wukusFI",
    "N2WRutxd1Ed0l4piqArI2gKYSTG7peE8BYBrLLV7YjQ",
  ].map { Data(base64RawEncoded: $0)! }

  var isSecureEnclaveAvailable = true
  var failingOperations = false

  func SecureEnclavePrivateKey(dataRepresentation: Data) throws -> SecureEnclavePrivateKey {
    return DummySecureEnclavePrivateKey(
      key: try P256.KeyAgreement.PrivateKey(rawRepresentation: dataRepresentation))
  }

  func SecureEnclavePrivateKey(accessControl: SecAccessControl) throws -> SecureEnclavePrivateKey {
    return DummySecureEnclavePrivateKey(
      key: try P256.KeyAgreement.PrivateKey(rawRepresentation: dummyKeys.popLast()!))
  }

  func newEphemeralPrivateKey() -> P256.KeyAgreement.PrivateKey {
    return try! P256.KeyAgreement.PrivateKey(rawRepresentation: dummyKeys.popLast()!)
  }

  func seal(_ plaintext: Data, using key: SymmetricKey) throws -> Data {
    if failingOperations {
      throw DummyCryptoError.dummyError
    }
    return key.withUnsafeBytes { ptr in
      return plaintext + Data(ptr[0..<16])
    }
  }

  func open(sealed ciphertext: Data, using key: SymmetricKey) throws -> Data {
    if failingOperations {
      throw DummyCryptoError.dummyError
    }
    return Data(ciphertext[0..<16])
  }
}

struct DummySecureEnclavePrivateKey: SecureEnclavePrivateKey {
  var key: P256.KeyAgreement.PrivateKey

  var publicKey: P256.KeyAgreement.PublicKey {
    return key.publicKey
  }

  var dataRepresentation: Data {
    return key.rawRepresentation
  }

  func sharedSecretFromKeyAgreement(with publicKeyShare: P256.KeyAgreement.PublicKey) throws
    -> SharedSecret
  {
    return try key.sharedSecretFromKeyAgreement(with: publicKeyShare)
  }
}

enum DummyCryptoError: LocalizedError {
  case dummyError

  public var errorDescription: String? {
    switch self {
    case .dummyError: return "dummy error"
    }
  }
}
