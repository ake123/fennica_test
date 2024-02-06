library(curl)

# Function to download and read CSV with retry logic
download_and_read_csv <- function(url, max_attempts = 3, attempt_delay = 10) {
    attempt <- 1
    
    while (attempt <= max_attempts) {
        try({
            conn <- curl(url, "r")
            data <- read.csv(conn, check.names = FALSE, row.names = NULL)
            close(conn)
            return(data)
        }, silent = TRUE)
        
        cat(sprintf("Attempt %d failed. Retrying in %d seconds...\n", attempt, attempt_delay))
        Sys.sleep(attempt_delay)
        attempt <- attempt + 1
    }
    
    stop("Failed to download the file after ", max_attempts, " attempts.")
}

# Example usage within your loop
for (i in 1:nrow(manifest$files)) {
    file_name <- manifest$files$name[i]
    file_location <- manifest$files$location[i]
    
    print(paste("Trying to download:", file_name))
    
    # Attempt to download and read the CSV file
    try({
        data <- download_and_read_csv(file_location)
        # Process data as needed...
    }, silent = TRUE)
}
