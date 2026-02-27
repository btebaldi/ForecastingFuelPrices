# Prompt the user for the destination directory
# This will ask the user to input the name of the destination directory
$destinationDirectory = Read-Host -Prompt "Please enter the destination directory"

# Combine the base path ".\mat_files\Result_Matrix" with the user-provided directory name
# This creates the full path for the destination directory
$destinationDirectory = Join-Path -Path ".\mat_files\Result_Matrix" -ChildPath $destinationDirectory 

# Check if the destination directory exists
# If it doesn't exist, create it
if (-not (Test-Path -Path $destinationDirectory)) {
    Write-Output "Destination directory does not exist. Creating it..."
    # Create the directory and suppress output using Out-Null
    New-Item -Path $destinationDirectory -ItemType Directory -Force | Out-Null
}

# Initialize an empty array to store the list of files that need to be moved
$filesToMove = @()

# Define the list of file paths to check and potentially move
# These are the files that the script will look for in the current directory structure
$fileNames = @(
    ".\mat_files\Result_Matrix\mGy_inv_X_mC.mat", 
    ".\mat_files\Result_Matrix\mGy_inv_X_mGyL1.mat", 
    ".\mat_files\Result_Matrix\mGy_inv_X_mGyL2.mat", 
    ".\mat_files\Result_Matrix\mGy_inv_X_mGyL3.mat", 
    ".\mat_files\Result_Matrix\mGy_inv_X_mGyL4.mat", 
    ".\mat_files\Result_Matrix\mGy_inv_X_mGyL5.mat", 
    ".\mat_files\Result_Matrix\mGy_inv_X_mGyL6.mat", 
    ".\mat_files\Result_Matrix\mGy_inv_X_mGyL7.mat", 
    ".\mat_files\Result_Matrix\mGy_inv_X_mGyL8.mat", 
    ".\mat_files\Result_Matrix\mGy_inv_X_mL.mat", 
    ".\mat_files\Result_Matrix\mGy_inv.mat", 
    ".\mat_files\Result_Matrix\mGy.mat",
    ".\Gvar_Passo0.out",
    ".\Gvar_Passo1.out",
    ".\Gvar_Passo2.out",
    ".\Gvar_Passo3.out",
    ".\Gvar_Passo4.out"
)

# Iterate through each file in the list
foreach ($fileName in $fileNames) {
    # Check if the file exists at the specified path
    if (Test-Path -Path $fileName) {
        # If the file exists, add it to the list of files to move
        $filesToMove += $fileName
    }
    else {
        # If the file does not exist, output a message indicating it was not found
        Write-Host "File not found: $fileName" -ForegroundColor Red
    }
}

# Check if there are any files to move
if ($filesToMove.Count -eq 0) {
    # If no files were found, output a message and exit
    Write-Host "No files were found."-ForegroundColor Red
}
else {
    # If there are files to move, iterate through each file
    foreach ($file in $filesToMove) {
        # Construct the destination path for the file
        # This combines the destination directory with the file name
        $destinationPath = Join-Path -Path $destinationDirectory -ChildPath (Split-Path -Path $file -Leaf)
        try {
            # Attempt to move the file to the destination path
            Move-Item -Path $file -Destination $destinationPath -Force
            # Output a success message
            Write-Host "Moved: $file to $destinationPath" -ForegroundColor Green
        }
        catch {
            # If an error occurs during the move operation, output an error message
            Write-Host "Error moving $file : $_" -ForegroundColor Red
        }
    }
}

# Output a message indicating the operation is complete
Write-Output "Operation completed."


# Define the directories to delete files from
$directoriesToClean = @(
    ".\mat_files\A_Matrix",
    ".\mat_files\G_Matrix",
    ".\mat_files\RawMatrix",
    ".\mat_files\Cointegration",
    ".\mat_files\W_mat"
)

$userInput = Read-Host -Prompt "Do you want to archive files from the specified directories before deletion? (Y/N)"
if ($userInput -in @('Y', 'y')) {
    
    $zipFileName = Join-Path -Path $destinationDirectory -ChildPath "mat_files_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
    
    foreach ($dir in $directoriesToClean) {
        if (Test-Path -Path $dir) {
            try {
                # $files = Get-ChildItem -Path $dir -File
                Compress-Archive -Path $dir -Update -DestinationPath $zipFileName
                Write-Host "Added files from $dir to $zipFileName" -ForegroundColor Green
            }
            catch {
                Write-Host "Error adding files from $dir to zip: $zipFileName" -ForegroundColor Red
            }
     
        }
        else {
            Write-Host "Directory not found: $dir" -ForegroundColor Yellow
        }
    }
    Write-Host "Files archived to: $zipFileName" -ForegroundColor Green
}



$userInput = Read-Host "Do you want to delete files? (Y/N)"

if ($userInput -in @('Y', 'y')) {


    foreach ($dir in $directoriesToClean) {
        if (Test-Path -Path $dir) {
            $userInput = Read-Host -Prompt ("Do you want to delete all files in {0}? (Y/N)" -f $dir)

            if ($userInput -notin @('Y', 'y')) {
                Write-Host "Skipping deletion in: $dir" -ForegroundColor Yellow
                continue
            }
            else {
                try {
                    Get-ChildItem -Path $dir -File | Remove-Item -Force
                    Write-Host "Deleted all files in: $dir" -ForegroundColor Green
                }
                catch {
                    Write-Host "Error deleting files in $dir : $_" -ForegroundColor Red
                }
            }        
        }
        else {
            Write-Host "Directory not found: $dir" -ForegroundColor Yellow
        }
    }

}
