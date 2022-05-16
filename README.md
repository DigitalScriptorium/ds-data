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
|   |   |-- base.csv
|   |   |-- clean-recon.csv
|   |   `-- imported.csv
|   `-- batch-20220505
|       `-- base.csv
`-- terms
    |-- genres.csv
    |-- names.csv
    |-- places.csv
    |-- subjects-named.csv
    `-- subjects.csv
```

The workflow is as follows.

- Doug receives a set of raw data.

A. Terms reconciliations

- Update terms CSVs from source: Doug produces new versions of the `terms`
  CSVs.

The process is additive. Each new version of a list (like `genres.csv`) will
add terms not in its previous version, keeping all the existing terrms. No
terms should be removed from a list.

- Reconcile and update terms CSVs: L.P. perfoms reconciliation on each new
  `terms` list, and updates each file in this repo: `terms/genres.csv`,
  `terms/names.csv`. etc.

This process neither adds nor subtracts rows from the CSVs, only adds values
to the authority columns.

B. Import CSV preparation

- Extract to `base` import CSV: Using new raw data and updated `terms` CSVs,
  Doug creates a new `base.csv` in the folder `import/batch-<DATE>`.

- Clean and complete recon: Using the `base.csv`, L.P. peforms data cleaning
  and reconciliation on language and material columns; performs any other
  cleaning needed, and adds a file `clean-recon.csv` to `import/batch-<DATE>`.

C. Import data

- Perform immport and update CSV: Using the file
  `import/batch-<DATE>/clean-recon.csv`, Doug adds/updates the records in DS,
  which produces an update CSV with DS IDs. This sheet is added to
  `import/batch-<DATE>` as `importe.csv`.
