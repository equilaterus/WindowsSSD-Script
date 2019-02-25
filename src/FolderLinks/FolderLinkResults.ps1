$FolderLinkResults = [PsCustomObject]@{
    # Symlink creation
    DestinationFolderExists = [PsCustomObject]@{
        Error = $true;
        CanRetry = $true;
        Message = 'There are files on the destination folder. Do you want to continue anyway?';
    };
    SymlinkError = [PsCustomObject]@{
        Error = $true;
        CanRetry = $false;
        Message = $('We cannot create SymbolicLink.');
    };
    Success = [PsCustomObject]@{
        Error = $false;
        Message = $('SymbolicLink created successfully!');
    };

    # Relinking
    NoSymlink = [PsCustomObject]@{
        Error = $true;
        CanRetry = $false;
        Message = 'Symlink doesnt exist. We cannot recreate an unexisting Symlink.';
    };

    # Common    
    UnableToMoveOrigin = [PsCustomObject]@{
        Error = $true;
        CanRetry = $false;
        Message = 'We cannot move origin folder. Close all application or move it manually.';
    };
};

Export-ModuleMember -Variable $FolderLinkResults