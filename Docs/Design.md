
## Storage 
```bash
graph TD
  
  class Router
    - private PassItemStorage
  
  class PassItemStorage
    - private GitPassRepo

  class PersistentKeyring
    - private keyring  // stores PGP Keys
    - private keychain // manages data in apples KeyChain
    func keys

  <<static>> GitRepoCreator
    static func initFromLocalFolder
    static func initFromScratch
    static initFrom(remote:URL)
    
  <<singleton>> class PGPFileReader
    PGPFileReader shared 
    private PersistentKeyring keyring
    func write 
    func read
    
    
  <<singleton>> class Config
```