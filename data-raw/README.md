# Data Preparation

> [!NOTE]
> The `data-raw` folder contains ...

## Contents

## Folders

The folder structure for `data-raw` is as follows:

```plaintext
data-raw/
├── README.md
├── ...
```

Folders:

- [cache](cache): Contains cached, intermediate data files that are generated during the data preparation process.

The directories are explained in further detail below.

### Cache

> [!INFO]
> The `cache` folder contains cached, intermediate data files that are generated during the data preparation process.

- Cached files are saved to disk to avoid re-running expensive computations.
- The `qs` (*quick serialization*) file format and corresponding R package, [qs](https://github.com/traversc/qs) is
  used for serialization and deserialization of data for optimal performance.
- The `qs` file format is a binary format that is optimized for speed and space efficiency as well as flexibility.

By default the `cache` folder's contents are ignored by Git and not committed to the repository.

### Excel

### Entrata
