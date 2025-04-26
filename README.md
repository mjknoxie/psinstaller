# psinstaller-fork

Qt-based graphical installer for writing a SquashFS image to disk and executing setup scripts.

See [NOTICE](./NOTICE) for project history and upstream attribution.

## Requirements

- Qt 5 (QtWidgets, QtCore, QtGui)
- C++ compiler (e.g., `g++`, `clang++`)

## Build Instructions

```bash
cd app
qmake
make
```

This will produce the `psinstaller` binary inside the `app` directory.

## Script Execution

All install-time logic (e.g., disk preparation, image writing, configuration steps) is handled by shell scripts located in:

```
app/scripts/
```

These scripts are invoked by the Qt UI during installation. You may customize them to suit your deployment needs.

## License

This project is licensed under the GNU Affero General Public License v3.0.  
See [LICENSE](./LICENSE) for full terms.
