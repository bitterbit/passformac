# [WIP] passformac
Pass for MacOS - a thin MacOS client compatible with Pass command line application
In very early stage

# Installation
Download the binary as normal :), check that openssl is installed.   
Specificly check that `/usr/local/opt/openssl/lib/libcrypto.1.0.0.dylib` exists.  
If missing follow the following steps (taken from [here](https://github.com/kelaberetiv/TagUI/issues/635)):
```bash
cd /usr/local/Homebrew/
git checkout 2.3.0
cd -
HOMEBREW_NO_AUTO_UPDATE=1 brew install https://github.com/tebelorg/Tump/releases/download/v1.0.0/openssl.rb
cd /usr/local/Homebrew/
git checkout -
cd -
```

# Build from Source
```bash
carthage bootstrap --platform macos

# make sure to switch Certificate under Signing & Capabilities -> Signing -> Team

# if missing libcrypto
wget https://github.com/tebelorg/Tump/releases/download/v1.0.0/openssl.rb 
```

# Motivation
pass is great but terminals dont support utf-8 well, by creating a GUI client one can now describe his acount details in any language he likes :jp::kr::cn::us::fr::es::it::ru::gb::de:🇮🇱

Inspired by [mssun/passforios](https://github.com/mssun/passforios)

Uses: 
- [rzyzanowskim/ObjectivePGP](https://github.com/krzyzanowskim/ObjectivePGP)
- [evgenyneu/keychain-swift](https://github.com/evgenyneu/keychain-swift)
- [libgit2/objective-git](https://github.com/libgit2/objective-git)


# Progress and Features
[Docs/tasks.todo](https://github.com/bitterbit/passformac/blob/master/Docs/tasks.todo)
