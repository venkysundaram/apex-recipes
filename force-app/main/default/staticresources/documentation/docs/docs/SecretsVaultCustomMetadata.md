---
layout: default
---
# SecretsVaultCustomMetadata class

This implementation of SecretsStorageService is focused on the acceptance and storage of Hashicorp's Vault format.

---
## Constructors
### `SecretsVaultCustomMetadata(SecretsKeyStorageService keyService)`

Constructor requiring injected keyService
#### Parameters
|Param|Description|
|-----|-----------|
|`keyService` |  Key service instance |

---
## Properties

### `keyService` → `SecretsKeyStorageService`

### `serializedSecret` → `String`

### `storageBase` → `SecretsCustomMetadataStorageBase`

---
## Methods
### `createKey(String keyName)` → `Boolean`

Required to conform to interface, but not used in this implementation

#### Parameters
|Param|Description|
|-----|-----------|
|`keyName` |  Name to use |

#### Return

**Type**

Boolean

**Description**

`Boolean`

### `decryptData(String keyName,String itemName,String cipherText)` → `String`

Makes a callout to Hashicorp's Vault transit encryption service to decrypt the secret data and returns the clear text.

#### Parameters
|Param|Description|
|-----|-----------|
|`keyName` |     Key to use |
|`itemName` |    Secret to fetch |
|`cipherText` |  Local encrypted version of the secret |

#### Return

**Type**

String

**Description**

`String`

### `encryptData(String keyName,String itemName,String clearText)` → `String`

Uses Hasicorp Vault transit encryption to encrypt a clear text String and return the encrypted value. Note this relies on a named credential being setup.

#### Parameters
|Param|Description|
|-----|-----------|
|`keyName` |    Key to use |
|`itemName` |   Name of the secret |
|`clearText` |  Unencrypted String to encrypt |

#### Return

**Type**

String

**Description**

`String`

### `retrieve(String itemName)` → `SecretsData`
#### Parameters
|Param|Description|
|-----|-----------|
|`` | e |

#### Return

**Type**

SecretsData

**Description**

`SecretsData`

### `serializeSecret(String keyName, string encryptedValue)` → `string`

Represent the secret value using  the required format of: <ENCRYPTION KEY NAME>~<ENCRYPTED VALUE>

#### Parameters
|Param|Description|
|-----|-----------|
|`keyName` |                Key name to use |
|`encryptedValue` |         Encoded and encrypted blob of the clear text |

#### Return

**Type**

string

**Description**

`String`

### `store(String keyName, String itemName, String clearText)` → `Boolean`

Required to conform to interface, but not used in this implementation

#### Parameters
|Param|Description|
|-----|-----------|
|`keyName` |    Key to use |
|`itemName` |   Name of the Secret |
|`clearText` |  Clear text to encode/encrypt |

#### Return

**Type**

Boolean

**Description**

`Boolean`

### `validateSecretFormat(String secretString)` → `List<String>`

Validates that the stored secret string matches the expected format.

#### Parameters
|Param|Description|
|-----|-----------|
|`secretString` |  Retrieved Secret string. |

#### Return

**Type**

List<String>

**Description**

`List<String>`

---
