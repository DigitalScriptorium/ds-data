# Digital Scriptorium data

## Introduction

This repository is for storing and sharing files for various projects related to the Digital Scriptorium (DS) Catalog, including data reuse initiatives such as creation of Wikidata items for manuscript objects owned by DS member institutions.

Please note that DS data is made available to the public under a Creative Commons Attribution 4.0 International (CC BY 4.0) license.

The ds-data repository principally contains CSVs of DS data at various stages of extraction, transformation, and enrichment. It also includes RDF and JSON data extracted from our linked database for display and search through a user interface.

## Directory information

### Data model

This directory is dedicated to JSON files containing specifications for items and properties found in the DS Wikibase, based on the DS data model.

### DS to SDBM

This directory contains files generated through the DS Wikibase query service which are used to upload batch files into the Schoenberg Database of Manuscripts (SDBM) to create manuscript observations (`inputs`) and resulting data extracted from the SDBM after uploading and manual processing of additional information (`outputs`).

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

### Updating reconciled "term" values to be used in Wikibase import documentation:

See also instructions at [ds-open-refine/instructions/](https://github.com/DigitalScriptorium/ds-open-refine/blob/main/instructions/merge-new-data.md#updating-data-dictionaries-in-ds-data-repository)

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
