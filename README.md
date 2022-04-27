# Digital Scriptorium data

Repository for CSVs DS data.

New files should be called: `DATE-name.csv`, where `DATE` is the date the file was created in `YYYY-MM-DD` format and `name` is a description, like `jhu`, `combined`, `upenn`, etc.

Directory structure:

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