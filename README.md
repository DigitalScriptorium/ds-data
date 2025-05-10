# Digital Scriptorium data

This repository is for CSVs of DS data at various stages of extraction, transformation, and enrichment. It also includes RDF and JSON data extracted from our linked database for display and search through a user interface.

## File naming conventions

New files should be called: `DATE-name.csv`, where `DATE` is the date the file was created in `YYYYMMDD` format and `name` is a description, like `jhu`, `combined`, `upenn`, etc. When more than one descriptor is applied, descriptors are separated by a dash, such as in `20220920-language-combined-enriched`. In addition, when `element` is provided in the instructions, it is a description of the metadata element, field, or type of data, such as in `languages.csv`, `named-subjects-unreconciled.csv`, or `20220705-places-combined-enriched.csv`. 

## Data management workflow for current and previously reconciled data

### Uploading data for Wikibase import:

1. Navigate to `member-data` directory.
2. Create sub-directory for institution using code list (if directory does not exist).
3. Create sub-sub-directory based on filename DATE in YYYY-MM format (if directory does not exist).
4. Click on `Add File` button and click `Upload files` from context menu.
5. Drag and drop or `choose your files` to be uploaded.
6. `Commit changes` directly to main branch.

### Uploading reconciled "batch" files:

1. Navigate to `ds-data/terms/batch` directory.
2. Create sub-directory based on filename DATE in YYYY-MM format (if does not exist).
3. Click on `Add File` button and click `Upload files` from context menu (file to be uploaded should be `DATE-element-enriched.csv`).
4. Drag and drop or `choose your files` to be uploaded.
5. `Commit changes` directly to main branch.

### Updating reconciled "term" values to be used in Wikibase import and unreconciled data for documentation:

See also instructions at [ds-open-refine/instructions/json/all] (https://github.com/DigitalScriptorium/ds-open-refine/tree/main/instructions/json/all)

1. Navigate to `ds-data/terms/reconciled` directory
3. Click on `Add File` button and click `Upload files` from context menu (file to be uploaded should be 'element.csv`).
4. Drag and drop or `choose your files` to be uploaded.
5. `Commit changes` directly to main branch.


## Directory structure

```text
.
├── README.md
├── Workflow-README-template.md
├── config.yml
├── member-data
│     ├── burke
│     │     ├── 2022-02
│     │     │     ├── 2022-02-23-burke-marc-combined-import.csv
│     │     │     ├── 2022-02-25-burke-marc-mmw-import.csv
│     │     ├── 2022-04
│     │     │     ├── 2022-04-04-burke-hebrew-import.csv
│     ├── ccny
│     │     ├── 2022-02
│     │     │     ├── 2022-02-23-ccny-mets-import.csv
│     │     │     ├── 2022-02-25-ccny-csv-import.csv
│     ├── columbia
│     │     ├── 2023-01
│     │     │     ├── 2022-02-23-columbia-marcxml-european-import.csv
etc.
├── split_data.rb
├── test
│     ├── missing_inst_name.csv
│     ├── missing_qid.csv
│     └── unknown_qid.csv
└── workflow
    ├── 2022-02-23-combined-README.md
    ├── 2022-02-23-combined-enriched.csv
    ├── 2022-02-23-combined.csv
    ├── 2022-04-04-combined-README.md
    ├── 2022-04-04-combined-enriched.csv
    └── 2022-04-04-combined.csv

  ```

## Splitting files

CSVs in the workflow directory should be split into institution-specific
directories. The `split_data.rb` script splits the CSV on the QID in the
`holding_institution` column and puts the file in folder as defined in the
`config.yml` file.

### `config.yml`

The configuration file contains the QID, name and a single-word folder for each
institution. New repositories should be added to the configuration. The format
of the entries is like so:

```yaml
---
- :qid: Q814779
  :name: Beinecke Rare Book & Manuscript Library
  :directory: beinecke
- :qid: Q995265
  :name: Bryn Mawr College
  :directory: brynmawr
- :qid: Q63969940
  :name: Burke Library at Union Theological Seminary
  :directory: burke
```

`split_data.rb` validates the config file and the CSV.
