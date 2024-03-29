# Fennica data storage ideas

Storing CSV files in Git, especially if they are large or frequently updated, can lead to challenges such as repository bloat, slow cloning and pulling times, and difficulties in handling merge conflicts. Here are several strategies to manage or mitigate these issues by storing CSV files elsewhere:

1.  **Git Large File Storage (LFS):** Git LFS replaces large files, such as CSV files, with short pointer files in the Git repository, while storing the file contents on a remote server. This is an excellent option if you need to track the file history but want to avoid bloating the repository with large files.

2.  **External Storage Services:** Store your CSV files on external cloud storage services like Amazon S3, Google Cloud Storage, or Microsoft Azure Blob Storage. You can reference these files in your repository through URLs or by including a manifest file in your repository that lists the locations of the CSV files. This approach is useful for very large datasets or binary files that do not benefit from version control.

3.  **Data Version Control Systems:** Tools like DVC (Data Version Control) are designed to handle large data files and machine learning models. DVC works alongside Git to manage data files and models efficiently without storing the data itself in the Git repository. It allows you to version control your data and models in a way that is similar to how Git versions source code.

4.  **Submodules and Subtrees:** If your CSV files must remain within a Git environment, consider using Git submodules or subtrees to store them in a separate repository. This allows you to keep your main repository lightweight while still maintaining a link to the data stored elsewhere.

5.  **Database Solutions:** For data that is frequently updated or needs to be queried, consider using a database. This could be a traditional SQL database, a NoSQL database, or a cloud-based database as a service (DBaaS). Storing data in a database instead of flat CSV files can improve performance, scalability, and data integrity.

6.  **Artifact Repositories:** Artifact repositories like JFrog Artifactory or Nexus Repository can be used to store binary artifacts, including CSV files. These tools offer version control for artifacts, which can be a good fit for datasets that need to be versioned but are not suitable for storage directly in Git.

7.  **Documentation and Access Control:** Regardless of where you store your CSV files, ensure you document their locations and how to access them. If you're using cloud storage or databases, also consider access control and security to protect your data.

Each of these strategies has its advantages and considerations, depending on the size of the data, the frequency of updates, and your specific workflow requirements. It's important to choose the option that best fits your project's needs and to document the chosen strategy for team members.

# CSC-ALLAS

If you're considering using CSC's Allas storage service, which is a versatile data storage service provided by CSC (IT Center for Science) in Finland for storing and managing large datasets, you'll have a somewhat different approach compared to using Google Cloud Storage. Allas is designed to handle massive datasets and is often used for scientific computing, research data storage, and high-performance computing environments. It supports both object storage and file storage interfaces, making it flexible for various use cases.

Here's how you might adapt the approach to use CSC's Allas for storage, including reading a manifest file in R, but tailored to the specifics of accessing data in Allas:

### Step 1: Understanding Allas Storage

Allas uses S3 and Swift APIs for object storage access, allowing integration with various tools and libraries capable of interfacing with these protocols. Determine which API (S3 or Swift) you'll use based on your preference, the tools you're using, or recommendations from CSC.

### Step 2: Setup Environment for Allas

1.  **Authentication and Configuration:** You'll need to authenticate and possibly configure your environment to access Allas. This typically involves sourcing an environment setup script provided by CSC and using CSC's authentication tokens.

2.  **Tools and Libraries:** Depending on your choice of API, you might use R packages that can interact with S3 or Swift APIs. For S3, the `aws.s3` package in R could be used. Ensure you have the necessary packages installed and configured to use the Allas service.

### Step 3: Read the Manifest File

Just like with Google Cloud Storage, you'll have a manifest file that lists the locations of your CSV files in Allas. The manifest file's structure doesn't change; what changes is how you access the files listed in it.

``` r
library(jsonlite)

# Load the manifest file
manifest <- fromJSON("path/to/manifest.json")
```

### Step 4: Access Files in Allas

Assuming you're using the S3 interface with `aws.s3` package in R, you'll first set up your environment with credentials for Allas access, then use the `aws.s3` functions to interact with the storage. Note that the exact setup details (like authentication methods) can vary based on CSC's current practices and the specifics of your project.

``` r
library(aws.s3)

# Setup credentials for S3 access, might involve setting environment variables
Sys.setenv("AWS_ACCESS_KEY_ID" = "your_access_key",
           "AWS_SECRET_ACCESS_KEY" = "your_secret_key",
           "AWS_DEFAULT_REGION" = "your_region")

# Example: Access the first dataset in the manifest
file_info <- manifest$files[[1]]
bucket_name <- "your_allas_bucket_name"
object_name <- "path/in/allas/to/your/file.csv" # You might need to adjust this based on your manifest structure

# Download the object (file) from Allas to a temporary file
temp_file <- tempfile()
get_object(object = object_name, bucket = bucket_name, save_to = temp_file)

# Read the CSV file
data <- read.csv(temp_file)
```

### Step 5: Work With Your Data

Once you've successfully accessed and read your data into R, you can proceed with your analysis, visualization, or any other data processing you need to perform.

``` r
##First attempt

library(aws.s3)
library(jsonlite)

# Set S3 options to work with Allas
Sys.setenv("AWS_ACCESS_KEY_ID" = "xxxxxxxx",
           "AWS_SECRET_ACCESS_KEY" = "xxxxxxxx",
           "AWS_S3_ENDPOINT" = "a3s.fi",
           "AWS_DEFAULT_REGION" = "optional_region",
           "AWS_BUCKET" = "fennica-container")

# Assuming the Allas S3 endpoint and region are correctly set,
# you can now use aws.s3 functions to interact with your bucket.

# Read the manifest file
manifest <- fromJSON("manifest.json")
# str(manifest)
# # Example to download and read the first dataset CSV
# file_info <- manifest$files[[1]]
# str(file_info)
# file_location <- file_info$location
# #object <- get_object(file_info$location)
# 
# # Assuming the file is a CSV
# data <- read.csv(text = rawToChar(object), stringsAsFactors = FALSE)

# Iterate over each file entry
for (i in 1:nrow(manifest$files)) {
    file_name <- manifest$files$name[i]
    file_location <- manifest$files$location[i]
    
    # Example: Print or use the file name and location
    print(paste("Name:", file_name, "- Location:", file_location))
    
    # Here you can add code to download the file, read the data, etc.
    # For example, to read a CSV file directly from the URL:
    data <- read.csv(file_location, row.names = NULL)
    print(head(data))
}
```

``` r

library(jsonlite)
library(httr)

# Load the manifest file
manifest <- fromJSON("manifest.json")

# Iterate over each file entry
for (i in 1:nrow(manifest$files)) {
    file_name <- manifest$files$name[i]
    file_location <- manifest$files$location[i]
    
    # Print file name and location
    print(paste("Name:", file_name, "- Location:", file_location))
    
    # Using httr to handle the request more robustly
    response <- GET(file_location, timeout(60))  # Extend timeout as needed
    
    # Check if the request was successful
    if (status_code(response) == 200) {
        # Read the content of the response as text
        content_text <- content(response, "text", encoding = "UTF-8")
        
        # Use read.csv on the content directly
        data <- read.csv(text = content_text, check.names = FALSE, row.names = NULL)
        
        # Now, `data` contains your CSV file as a dataframe
        # Process data as needed...
    } else {
        print(paste("Failed to download:", file_location, "- Status code:", status_code(response)))
    }
}
```
