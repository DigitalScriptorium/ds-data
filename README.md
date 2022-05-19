# Digital Scriptorium data

Repository for CSVs DS data.

New files should be called: `DATE-name.csv`, where `DATE` is the date the file was created in `YYYY-MM-DD` format and `name` is a one-word description, like `jhu`, `combined`, `upenn`, etc.

Directory structure:

```text
/ # root folder
- README.md
- Workflow-README-template.md
- workflow
    - 2022-02-23-README.md
    - 2022-02-23-combined.csv
    - 2022-02-23-combined-enriched.csv
    - 2022-02-23-combined-imported.csv
- member-data
    - beinecke
    - harvard
    - nyu
        - 2021-07-06-nyu.csv
        - 2021-07-06-nyu-enriched.csv
        - 2021-07-06-nyu-imported.csv
        - 2022-06-06-nyu.csv
        - 2022-06-06-nyu-enriched.csv
        - 2022-06-06-nyu-imported.csv
  ```
  
  - [ ] TODO: Add script for splitting and placing member-data files in place


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
