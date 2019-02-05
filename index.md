# WindowsSSD-Script

Powershell scripts to automate symbolic link generation for SSD units on Windows. 

**Fast and easily!** Move your files and applications from your main SSD disk to another HDD unit.

## Builds

| **Branch**      | Build status | Current version |
| --------------- |:-------------:| -----:|
| **Master**        | [![Build Status](https://ci.appveyor.com/api/projects/status/rxn77j64dn3s50r8/branch/master?svg=true)](https://ci.appveyor.com/project/dacanizares/windowsssd-script/branch/master) | 0.1.0  |
| **Dev-unstable**  | [![Build Status](https://ci.appveyor.com/api/projects/status/rxn77j64dn3s50r8/branch/dev?svg=true)](https://ci.appveyor.com/project/dacanizares/windowsssd-script/branch/dev) | 0.2.0-unreleased    |

## Supported tasks

* Migrate Windows Update folder.
* Migrate Google Chrome data.
* Migrate Firefox data.

## Downloads

* Download source code from: [GitHub Releases](https://github.com/equilaterus/WindowsSSD-Script/releases)

## How to use it

Download, extract and execute **Run.ps1** by pressing right click on it and choosing **Run with Powershell**.

 **Note**: WindowsSSD-Script will ask you for elevated permissions because it needs to be executed as an *administrator user*.

## Compatibility

* Tested on **Windows 10**
* Proceed with caution on Windows 7/8.
* Windows XP/Vista not supported

## FAQ

* **I can't see Run With Powershell option**: I'm trying to run the program but I can't see the option to run it with Powershell.

    **Solution**: Right click on **Run.ps1** and select **open with...** option,set it back to the default option of **Notepad** (selecting *always open ps1 files with this application*).

*  **Error code 0x80070011**: I'm trying to install **.Net 3.5** but I'm getting the following error: *"The system cannot move the file to a different disk drive"*.

    **Solution**: As it is safe to delete *Windows/SoftwareDistribution* folder it is recommended to delete both original and linked folder, install .Net 3.5 and regenerate links opening **WindowsSSD-Script**.
