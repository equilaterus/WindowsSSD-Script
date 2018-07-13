# WindowsSSD-Script
Powershell scripts to automate symbolic link generation for SSD units on Windows. 

**Fast and easily!** Move your files and applications from your main SSD disk to another HDD unit.

## Supported tasks

* Move Windows Update folder.
* Move Google Chrome data.

## How to use

Download, extract and open **src** folder, inside it you will find a file called **Run.ps1**, right click on it and choose **Run with Powershell** it will ask you for elevated permissions as it needs to be executed as an *administrator user*.

## Tested OS

* Windows 10
* Proceed with caution on other versions of Windows.

## FAQ

* **I can't see Run With Powershell option**: I'm trying to run the program but I can't see the option to run it with Powershell.

    **Solution**: Right click on **Run.ps1** and select **open with...** option,set it back to the default option of **Notepad** (selecting *always open ps1 files with this application*).

*  **Error code 0x80070011**: I'm trying to install **.Net 3.5** but I'm getting the following error: *"The system cannot move the file to a different disk drive"*.

    **Solution**: As it is safe to delete *Windows/SoftwareDistribution* folder it is recommended to delete both original and linked folder, install .Net 3.5 and regenerate links opening **WindowsSSD-Script**.