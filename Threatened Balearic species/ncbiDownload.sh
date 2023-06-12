

# Input file containing species names
input_file="organisms.txt"

# Output folder
output_folder="TEST"

# Create the output folder if it doesn't exist
# mkdir -p "$output_folder"

# Counter for sequential number
counter=1

# Open the input file for reading
exec 3< "$input_file"

# Read the file line by line and process each species
while IFS= read -r line <&3; do
  # Remove leading and trailing whitespace from the line
  line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  # Check if the line is not empty
  if [ -n "$line" ]; then
    # Construct the query string for the species
    query="${line}[Organism]"

    # Use esearch to retrieve the list of sequence IDs
    esearch -db nucleotide -query "$query" | \
      efetch -format gbwithparts > "${output_folder}/${counter}_${line// /_}.txt"

    # Increment the counter
    ((counter++))
  fi
done

# Close the input file
exec 3<&-




