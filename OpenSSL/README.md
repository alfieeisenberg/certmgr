# OpenSSL-Universal

## == Invisinet fork of https://github.com/krzyzanowskim/OpenSSL ==

The original project contained bash shell scripts to build an Apple xcframework.

Original build instructions are in README.orig.md, but you should not need them.

## Fetching from GIT

Simple clone this repo:

    $ git clone git@192.168.120.168:invisinet-dev/openssl-framework.git 

## MacOS 

### Developing and Debugging

Open OpenSSL.xcodeproj directly from Xcode, or from commandline:

    $ cd openssl-framework
    $ open OpenSSL.xcodeproj

Select the Framework target for the platform you are building.  From the UI, Xcode is configured to create *debug* binaries.

### Releasing

Run the following script to create an Apple XCFramework

    $ make

The script will build iOS, iOS Simulator, MacOS and Mac Catalyst targets, and then bundle the resultant binaries into a single xcframework folder:

    Frameworks/OpenSSL.xcframework

For now, the Frameworks/OpenSSL.xcframework is committed back to the GIT repo.