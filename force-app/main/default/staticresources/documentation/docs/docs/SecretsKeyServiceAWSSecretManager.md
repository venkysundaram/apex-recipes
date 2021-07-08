---
layout: default
---
# SecretsKeyServiceAWSSecretManager class

Concrete implementation of the SecretsKeyStorageService interface that stores the keys inside AWS Secrets Manager vaults.

## Related

Secrets, SecretsKeyStorageService

---
## Properties

### `memoizedKeys` → `Map<String, Blob>`

 Because retrieving keys can be a time consuming, or query burning activity, this code 'memoizes' the keys previously accessed in this transaction

---
## Methods
### `createKey(String keyName, Integer keySize)` → `Boolean`

Stubbed out implementation that would create a new key and stores it in Secrets Manager

#### Parameters
|Param|Description|
|-----|-----------|
|`keyName` |  Name of the key |
|`keySize` |  Size of the key |

#### Return

**Type**

Boolean

**Description**

`Boolean`

### `getKey(String keyName)` → `Blob`

Retrieves the key from AWS Secrets Manager

#### Parameters
|Param|Description|
|-----|-----------|
|`keyName` |  Name of the key to return |

#### Return

**Type**

Blob

**Description**

`Blob`

### `queryForKey(String keyName)` → `List<Secrets__c>`

Method uses AWS REST API for query for key

#### Parameters
|Param|Description|
|-----|-----------|
|`keyName` |  Name of the key to find |

#### Return

**Type**

List<Secrets__c>

**Description**

`List<Secrets__c>`

---
## Inner Classes

### SecretsKeyServiceAWSSecretManager.SecretsKeyServiceException class

internally used exception subclass.

---
