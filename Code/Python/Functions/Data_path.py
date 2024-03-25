import os

# ================================================= Data path =========================================================
# Function to construct the path to a data folder and list files within it
def data_path(folder_path, data_format, depth=0):

    contents = sorted(os.listdir(folder_path)) # Get the contents of the folder and sort them
    files = []             # Initialize lists to store files
    folders = []           # Initialize lists to store folders
    files_path = []        # Initialize lists to store files path
    
    for item in contents:  # Iterate over each item in the folder
        
        item_path = os.path.join(folder_path, item) # Create the full path of the item

        if os.path.isfile(item_path):               # Check if the item is a file
            files.append((item, depth, item_path))  # If it's a file, append it to the files list along with its depth and full path
        
        elif os.path.isdir(item_path):              # Check if the item is a directory
            folders.append((item, depth, item_path)) # If it's a directory, append it to the folders list along with its depth and full path
            _, sub_files, sub_folders= data_path(item_path, data_format, depth + 1) # Recursively list files and folders in subfolders
            files.extend(sub_files)
            folders.extend(sub_folders)
    
    for _, (_, _, val) in enumerate(files): # Iterate over the files and check if they end with the specified data format
        if val.endswith(data_format):
            files_path.append(val) # If the file matches the data format, append its full path to the path_files list
    
    return files_path, files, folders  # Return the list of files with specified data format, all files, and all folders