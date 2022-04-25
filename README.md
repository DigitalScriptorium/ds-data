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
