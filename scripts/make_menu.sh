#!/bin/sh
# argument 1: taxonomy descriptor file

if [ "$#" -ne 1 ]; then
  echo "One parameter is required:"
  echo "  - Path to a file describing the taxonomy to translate to a menu structure"
  exit 1
fi

# Helper method to print the code to auto-generate a set of menu links for a particular genus
# arg 1: genus name
# arg 2: output file path
# arg 3: depth
print_genus_menu () {
  indent="    "
  for i in $(seq 0 $3 );
  do
    indent="  $indent"
  done
  echo "$indent{% assign genus = site.pages | where:'genus','$1' | group_by:'species' | sort:'name' %}" >> "$2"
  echo "$indent{%- for species in genus -%}" >> "$2"
  echo "$indent  {% include menu/section.html title=species.name border="-1" taxon=species.name %}" >> "$2"
  echo "$indent  {% assign speciesByID = species.items | sort:'ID' %}" >> "$2"
  echo "$indent  {%- for individual in speciesByID -%}" >> "$2"
  echo "$indent  <li><a href=\"/caterpillars{{ individual.url }}\">{{ individual.ID }}</a></li>" >> "$2"
  echo "$indent  {%- endfor -%}" >> "$2"
  echo "$indent  {% include menu/section-end.html %}" >> "$2"
  echo "$indent{%- endfor -%}" >> "$2"
}

# Clean up previous menu generation
out_file="_includes/layout/menu.html"
rm "$out_file"

# Heading is standard
echo "{%- capture main-menu -%}" >> "$out_file"
echo "  <div class=\"menu\">" >> "$out_file"
echo "    <h3>Taxonomy</h3>" >> "$out_file"
echo "    <ul>" >> "$out_file"


prev_depth=-1
border=6
END_SECTION="    {%include menu/section-end.html %}";

# Process the taxonomy file one line at a time
while IFS= read -r line
do
  # Each line contains a menu section title with a preceding number of spaces indicating its depth
  # So we extract the trimmed title string, and count the number of spaces
  title=$(echo "$line" | tr -d ' ')
  depth=${line%%[a-zA-Z]*}
  depth=${#depth}

  # For each section we need to create an opening menu section, and a closing menu section after
  # all necessary sub-menus are generated
  line_out="    {% include menu/section.html title=\"$title\""

  if [[ $prev_depth -lt 0 ]]
  then
    # The top-level menu section is opened to show the menu
    line_out+=" open=\"True\""
  else
    # Indent to the current depth
    for i in $(seq 1 $depth);
    do
      line_out="  $line_out"
    done
  fi

  if [[ $depth -gt 0 ]]
  then
    # After the base menu section we start adding a border with width proportionate to the menu depth
    if [[ $depth -gt $prev_depth ]]
    then
      # If our depth has grown then we necessarily transitioned from one menu to a sub-menu
      border=$((--border))
    elif [[ $depth -lt $prev_depth ]]
    then
      # If the depth shrunk, then we transitioned from a leaf item (Genus) to a less-nested sub-menu
      # So we need to:
      # 1 - generate the code for the Genus menu (which is the PREVIOUS line we read)
      # 2 - grow the border to the new depth
      # 3 - add menu section ends to the new depth
      print_genus_menu $prev_title $out_file $prev_depth
      target_depth=$((prev_depth - 1))
      # First we do section ends and border changes to account for depth
      for i in $(seq $target_depth $depth );
      do
        border=$((++border))
        # Indent the section ends appropriately
        sec_end="$END_SECTION"
        for j in $(seq 0 $i);
        do
          sec_end="  $sec_end"
        done
        echo "$sec_end" >> "$out_file"
      done
      # One more section end without a border change to account for closing the Genus menu
      sec_end="$END_SECTION"
      # Indent the section ends appropriately
      for i in $(seq 1 $depth);
      do
        sec_end="  $sec_end"
      done
      echo "$sec_end" >> "$out_file"
    elif [[ $depth -eq $prev_depth ]]
    then
      # If the depth is constant between lines, then we transitioned from one Genus to another
      # within a (sub)family. 
      # We need the code to populate a Genus menu (again, for the PREVIOUS line we read)
      # and add a single end section
      print_genus_menu $prev_title $out_file $prev_depth
      sec_end="$END_SECTION"
      # Indent the section end appropriately
      for i in $(seq 1 $depth);
      do
        sec_end="  $sec_end"
      done
      echo "$sec_end" >> "$out_file"
    fi
    # Record the border value
    line_out+=" border=\"$border\""
    line_out+=" taxon=\"$title\""
  fi

  # Print the current line, update the depth, and record this line's title
  # (the title will be used on future iterations if this was a Genus line)
  line_out+=" %}"
  echo "$line_out" >> "$out_file"
  prev_depth=$depth
  prev_title=$title
done < "$1"

# The final line of the menu should be a species
print_genus_menu $prev_title $out_file $prev_depth

# After reading the menu file, we need to clean up with end sections for the last menu item,
# and account for the final depth (i.e. unclosed menu entries)
for i in $(seq $depth 0);
do
    # NB: END_SECTION has the base indentation.. we need to indent based on depth but because
    # iteration is inclusive there's it will always indent once, creating an off-by-one error,
    # thus we pop off one leading indentation 
    sec_end="$END_SECTION"
    sec_end="${sec_end:2}"
    for i in $(seq 0 $i);
    do
      sec_end="  $sec_end"
    done
    echo "$sec_end" >> "$out_file"
done

# Tail stuff is constant
echo "    </ul>" >> "$out_file"
echo "  </div>" >> "$out_file"
echo "{%- endcapture -%}" >> "$out_file"
echo "" >> "$out_file"
echo "{%- capture page-link -%} <a href=\"/caterpillars/{{page.path | replace: \"md\", \"html\" }}\"> {%- endcapture -%}" >> "$out_file"
echo "" >> "$out_file"
echo "{%- capture current-page -%} <a class=\"current-page\"> {%- endcapture -%}" >> "$out_file"
echo "" >> "$out_file"
echo "{{ main-menu | replace: page-link, current-page }}" >> "$out_file"
echo "" >> "$out_file"
echo "<script type=\"text/javascript\" src=\"{{ \"/assets/js/menu.js\" | relative_url }}\"></script>" >> "$out_file"
echo "" >> "$out_file"
echo "{%- comment -%}" >> "$out_file"
echo "# vi:syntax=liquid" >> "$out_file"
echo "{%- endcomment -%}" >> "$out_file"
