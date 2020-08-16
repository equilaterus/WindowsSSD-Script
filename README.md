# WindowsSSD-Script

[Official Website](https://equilaterus.github.io/WindowsSSD-Script/)

Powershell scripts to automate symbolic link generation for SSD units on Windows. 

**Fast and easily!** Move your files and applications from your main SSD disk to another HDD unit.

## Builds

| **Branch**      | Build status | Current version |
| --------------- |:-------------:| -----:|
| **Master**        | [![Build Status](https://ci.appveyor.com/api/projects/status/rxn77j64dn3s50r8/branch/master?svg=true)](https://ci.appveyor.com/project/dacanizares/windowsssd-script/branch/master) | 0.1.3  |
| **Dev-unstable**  | [![Build Status](https://ci.appveyor.com/api/projects/status/rxn77j64dn3s50r8/branch/dev?svg=true)](https://ci.appveyor.com/project/dacanizares/windowsssd-script/branch/dev) | 0.2.0-unreleased    |

## Supported tasks

* Migrate Windows Update folder.
* Migrate Brave Browser data.
* Migrate Edge Chromium data.
* Migrate Google Chrome data.
* Migrate Firefox data.
* Migrate Opera data.
* Migrate Spotify data.

## Downloads

* Download source code from: [GitHub Releases](https://github.com/equilaterus/WindowsSSD-Script/releases)

## How to use it

Download, extract and execute **Run.bat**.

 **Note**: WindowsSSD-Script will ask you for elevated permissions because it needs to be executed as an *administrator user*.

## Compatibility

* Tested on **Windows 10**
* Proceed with caution on Windows 7/8.
* Windows XP/Vista not supported

## FAQ

*  **Error code 0x80070011**: I'm trying to install **.Net 3.5** but I'm getting the following error: *"The system cannot move the file to a different disk drive"*.

    **Solution**: As it is safe to delete *Windows/SoftwareDistribution* folder it is recommended to delete both original and linked folder, install .Net 3.5 and regenerate links opening **WindowsSSD-Script**.