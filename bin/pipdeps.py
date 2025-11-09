#!/usr/bin/env python3

# pipdeps v0.11
#
# Copyright (c) 2025 Kristofer Berggren
# All rights reserved.
#
# pipdeps is distributed under the MIT license.

# Install pip packages in shared virtual environment allow calling script to access them
def pipdeps(pkgs):
    import os, sys, subprocess, venv, importlib.metadata

    HOME = os.environ.get("XDG_CACHE_HOME", os.path.join(os.path.expanduser("~"), ".cache"))
    VENVDIR = os.path.join(HOME, "pipdeps", "venv")

    if not os.path.exists(VENVDIR):
        venv.EnvBuilder(with_pip=True).create(VENVDIR)

    pyver = f"python{sys.version_info.major}.{sys.version_info.minor}"
    sitepkgs = os.path.join(VENVDIR, "lib", pyver, "site-packages")
    sys.path.insert(0, sitepkgs)

    missing = []
    for pkg in pkgs:
        try:
            importlib.metadata.distribution(pkg)
        except importlib.metadata.PackageNotFoundError:
            missing.append(pkg)

    if missing:
        pip = os.path.join(VENVDIR, "bin", "pip")
        print(f"Installing missing packages: {', '.join(missing)}")
        subprocess.check_call([pip, "install"] + missing)


# Example usage, installs the listed packages and prints their versions

pipdeps(["requests", "beautifulsoup4"])

import requests, bs4

def main():
    print("It works!", requests.__version__, bs4.__version__)

if __name__ == "__main__":
    main()
