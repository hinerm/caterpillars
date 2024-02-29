// Helper function to open any details children of a base element
function openMenu(base) {
  if (base.nodeName == "DETAILS")
    base.open = true;
}

// Open all details in a hierarchy starting with a base element
function openAllMenuFromLeaf(id) {
  var base = document.getElementById(id);

  // Traverse all elements from base
  while (base) {
    openMenu(base);
    base = base.parentElement;
  }
}

// Helper method entry point to find the appropriate taxon of
// the current page - which is used as the ID to open the
// menu structure
function openMenuHierarchy() {
  var title = document.title;
  var taxon = title.split('-')[0].trim();
  openAllMenuFromLeaf(taxon);
}

Window.onload = openMenuHierarchy();
