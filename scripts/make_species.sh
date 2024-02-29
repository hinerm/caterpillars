#!/bin/sh
# argument 1: directory containing image subdirectories,
#             each named by caterpillar ID number
# argument 2: CSV file with caterpillar data 

if [ "$#" -ne 2 ]; then
  echo "Two parameters are required:"
  echo "  - Path to directory containing caterpillar image subdirectories, named by ID number"
  echo "  - Path to csv file with caterpillar data"
  exit 1
fi

out_dir=species

rm -rf "$out_dir"
mkdir -p "$out_dir"

# Iterate over each caterpillar directory in the image folder
for dir in "$1"/* ; do
  # Each directory is a caterpillar ID
  ID=$(basename "$dir")

  # Extract CSV data
  row=$(awk -v n="$ID" -F',' '$1 ~ n && NR > 1 {print}' "$2")
  species=$(echo "$row" | cut -d"," -f2)
  genus=$(echo "$species" | cut -d" " -f1)
  plant=$(echo "$row" | cut -d"," -f3)

  # Determine the filename
  filename=$(echo "${ID// /-}")
  filename=$(echo "${filename//./}")
  filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
  filename+=".md"

  # Create the file for this caterpillar
  echo "---" >> "$out_dir/$filename"
  echo "layout: species" >> "$out_dir/$filename"
#  taxonomy: "Entheus:Hesperiidae:Hesperioidea:Lepidoptera:Insecta"
  echo "genus: \"$genus\"" >> "$out_dir/$filename"
  echo "ID: \"$ID\"" >> "$out_dir/$filename"
  echo "species: \"$species\"" >> "$out_dir/$filename"
  echo "title: \"$species - $ID\"" >> "$out_dir/$filename"
  echo "categories: jekyll species" >> "$out_dir/$filename"
  echo "---" >> "$out_dir/$filename"
  echo "" >> "$out_dir/$filename"
  echo "Host plant: $plant" >> "$out_dir/$filename"
  echo "" >> "$out_dir/$filename"
  echo "{% include image-gallery.html folder=\"/docs/assets/cats/$ID\" %}" >> "$out_dir/$filename"
done
