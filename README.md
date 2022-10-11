# Digital Scriptorium data

This repository for for CSVs of DS data at various stages of extraction, transformation, and enrichment.

## File naming conventions

New files should be called: `DATE-name.csv`, where `DATE` is the date the file was created in `YYYYMMDD` format and `name` is a description, like `jhu`, `combined`, `upenn`, etc. When more than one descriptor is applied, descriptors are separated by a dash, such as in `20220920-language-combined-enriched`. In addition, when `element` is provided in the instructions, it is a descrption of the metadata element, field, or type of data, such as in `languages.csv`, `named-subjects-unreconciled.csv`, or `20220705-places-combined-enriched.csv`. 

## Data management workflow for current and previous reconciled data

### Uploading extracted data:

1. Navigate to `member-data` directory.
2. Click on `Add File` button and click `Upload files` from context menu.
3. Drag and drop or click to add files to be uploaded.
4. Commit changes directly to main branch.

### Uploading full reconciled "batch" files:

1. Navigate to `ds-data/terms/batch` directory.
2. Click on `Add File` button and click `Upload files` from context menu (file to be uploaded should be 'DATE-element-combined-enriched.csv`).
3. Drag and drop or click to add files to be uploaded.
4. Commit changes directly to main branch.

### Updating reconciled "term" values to be used in Wikibase import:

#### Archiving previous reconciled data

1. Navigate to `ds-data/terms/reconciled` directory.
2. Click on `element.csv` file to be updated.
3. Edit file by changing file path from `ds-data/terms/reconciled/element.csv` to `ds-data/terms/archived/DATE-element.csv`, where `DATE` is the date the terms were originally extracted.
4. Commit changes directly to main branch.

#### Uploading new reconciled data

5. Navigate to `ds-data/terms/reconciled` directory.
6. Click on `Add File` button and click `Upload files` from context menu (file to be uploaded should be 'element.csv`).
7. Drag and drop or click to add files to be uploaded.
8. Commit changes directly to main branch.

### Updating unreconciled values for documentation

1. Navigate to `ds-data/terms/unreconciled` directory.
2. Click on `element-unreconciled.csv` file to be updated.
3. Edit file by changing file path from `ds-data/terms/unreconciled/element-unreconciled.csv` to `ds-data/terms/unreconciled/archived/DATE-element-unreconciled.csv`, where `DATE` is the date the terms were originally extracted.
4. Commit changes directly to main branch.


## Directory structure:

```text
.
├── README.md
├── Workflow-README-template.md
├── config.yml
├── member-data
│     ├── burke
│     │     ├── 2022-02-23-combined-burke.csv
│     │     ├── 2022-02-23-combined-enriched-burke.csv
│     │     └── 2022-04-04-combined-burke.csv
│     ├── ccny
│     │     ├── 2022-02-23-combined-ccny.csv
│     │     ├── 2022-02-23-combined-enriched-ccny.csv
│     │     └── 2022-04-04-combined-ccny.csv
│     ├── columbia
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

## Adding data

New files should be added to the `workflow` directory and named using the date
and a signifier describing the data; e.g., `2022-06-13-combined.csv`. Subsequent
and related files should use the same data an name:
`2022-06-13-combined-enriched.csv`, `2022-06-13-combined-README.csv`, and so
forth.

1. Add a CSV of extracted data named according to the pattern described above;
   e.g., `2022-06-13-combined.csv`.
2. Copy the `Workflow-README-template.md` to the folder following the name
   pattern; e.g., `2022-06-13-combined-README.md`.
3. Edit the README for the current set of data.
4. Once the data has been cleaned and reconciled, add an `enriched` version of
   the CSV; e.g., `2022-06-13-combined-enriched.csv`.
5. Add notes about enrichment to the README.
6. When the data is imported, add an `imported` file to the `workflow` folder;
   e.g., `2022-06-13-combined-imported.csv`.
7. Add notes about the import to the README.

## Proposed alternate workflow

```
.
|-- import
|   |-- batch-20220223
|   |   |-- README.md
|   |   |-- base.csv
|   |   |-- clean.csv
|   |   `-- imported.csv
|   `-- batch-20220505
|       |-- README.md
|       |-- base.csv
|       |-- clean.csv
|       `-- imported.csv
`-- terms
    |-- genres.csv
    |-- names.csv
    |-- places.csv
    |-- subjects-named.csv
    `-- subjects.csv
```

The workflow is as follows.

- A new set of raw data (CSV, MARC XML) is received.

A. Terms reconciliations

- Term extraction: All terms (names, places, genres, etc.) are extracted from
  the new data.

The lists will contain all terms from the new data, but previously reconciled
terms will be accompanied by their URIs/identifiers.

- Reconciliation: New terms (those not previously reconciled) are reconciled
  and added to the appropriate CSVs in the `terms` folder (`places.csv`,
  `names.csv`, etc.)

B. Import CSV preparation

- Extraction of import CSV: Using new raw data and updated `terms` CSVs, a new
  `base.csv` is generated and added to the folder `import/batch-<DATE>`.

- Cleaning and reconciliation: The `base.csv` is processed in OpenRefine for
  reconciliation of language and material columns; any other needed cleaning is
  preformed, and the result is added as `clean.csv` to
  `import/batch-<DATE>`.

C. Data import

- Data import and CSV updat: The file `import/batch-<DATE>/clean-recon.csv` is
  imported into DS, and the output CSV with DS IDs is added to
  `import/batch-<DATE>` as `imported.csv`.

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
