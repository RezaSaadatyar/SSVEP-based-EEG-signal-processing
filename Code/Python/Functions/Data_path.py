import os

# ============================================== Data path ===================================================
# Function to construct the path to a data folder and list files within it
def data_path(folder_path, data_format, depth=0):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    Parameters:
    - folder_path: Path to the folder to search.
    - data_format: Desired format of the data files.
    - depth (optional): Current depth in the directory structure (default: 0).
    ================================= Flowchart for the data path function ===================================
    Start
    1. Get the contents of the folder and sort them.
    2. Initialize lists to store files, folders, and files' paths.
    3. Iterate over each item in the folder:
    a. Create the full path of the item.
    b. If the item is a file:
        i. Append it to the files list along with its depth and full path.
    c. If the item is a directory:
        i. Append it to the folders list along with its depth and full path.
        ii. Recursively list files and folders in subfolders.
        iii. Extend the files and folders lists with the subfiles and subfolders.
    4. Iterate over the files:
    a. Check if the file ends with the specified data format.
    b. If it matches the data format, append its full path to the files_path list.
    5. Return the list of files with the specified data format, all files, and all folders.
    End
    ==========================================================================================================
    """
    contents = sorted(os.listdir(folder_path)) # Get the contents of the folder and sort them
    files = []             # Initialize lists to store files
    folders = []           # Initialize lists to store folders
    files_path = []        # Initialize lists to store files path
    
    for item in contents:  # Iterate over each item in the folder
        
        item_path = os.path.join(folder_path, item) # Create the full path of the item

        if os.path.isfile(item_path):               # Check if the item is a file
            # If it's a file, append it to the files list along with its depth and full path
            files.append((item, depth, item_path))  
        
        elif os.path.isdir(item_path):              # Check if the item is a directory
            # If it's a directory, append it to the folders list along with its depth and full path
            folders.append((item, depth, item_path))
            # Recursively list files and folders in subfolders
            _, sub_files, sub_folders= data_path(item_path, data_format, depth + 1)
            files.extend(sub_files)
            folders.extend(sub_folders)
    # Iterate over the files and check if they end with the specified data format
    for _, (_, _, val) in enumerate(files):
        if val.endswith(data_format):
            # If the file matches the data format, append its full path to the path_files list
            files_path.append(val)

    # Return the list of files with specified data format, all files, and all folders
    return files_path, files, folders