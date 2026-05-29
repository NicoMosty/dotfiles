import bibtexparser

# Load the .bib file
with open('references.bib', 'r') as bib_file:
    bib_database = bibtexparser.load(bib_file)

# Fields to keep in the APA citation
fields_to_keep = ['author', 'title', 'journal', 'year', 'volume', 'number', 'pages', 'DOI', 'url', 'ENTRYTYPE', 'ID', 'booktitle', 'publisher', 'school']

# Function to clean and format entries
def clean_entry(entry):
    cleaned_entry = {k: v for k, v in entry.items() if k in fields_to_keep and k != 'abstract'}
    return cleaned_entry

# Clean all entries
cleaned_entries = []
for entry in bib_database.entries:
    if 'ENTRYTYPE' in entry and 'ID' in entry:
        cleaned_entries.append(clean_entry(entry))

# Update the database with cleaned entries
bib_database.entries = cleaned_entries

# Save the cleaned entries back to a .bib file
with open('cleaned_references.bib', 'w') as bib_file:
    bibtexparser.dump(bib_database, bib_file)
