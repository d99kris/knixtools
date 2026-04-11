knixtools
=========

| **Linux** | **Mac** |
|-----------|---------|
| [![Linux](https://github.com/d99kris/knixtools/workflows/Linux/badge.svg)](https://github.com/d99kris/knixtools/actions?query=workflow%3ALinux) | [![macOS](https://github.com/d99kris/knixtools/workflows/macOS/badge.svg)](https://github.com/d99kris/knixtools/actions?query=workflow%3AmacOS) |

knixtools (kris *nix tools) is a repository for small Linux/macOS development
tools (shell-scripts primarily) that are too small to warrant their own
repositories.


Supported Platforms
===================

knixtools is primarily developed on macOS and Linux.


Tools Listing
=============

| **Name**     | **Src**                  | **Doc**                     | **Description**                |
|--------------|--------------------------|-----------------------------|--------------------------------|
| 7zetools     | [dir](/bin)              | [doc](/doc/7zetools.md)     | 7-Zip encryption tools         |
| agentusage   | [src](/bin/agentusage)   | -                           | Coding agent transcript store  |
| cvc          | [src](/bin/cvc)          | -                           | Git / Subversion wrapper       |
| liveinstall  | [src](/bin/liveinstall)  | [doc](/doc/liveinstall.md)  | Linux live-cd installer        |
| nspell-gpt   | [src](/bin/nspell-gpt)   | [doc](/doc/nspell-gpt.md)   | Spell check using OpenAI GPT   |
| pipdeps      | [src](/bin/pipdeps)      | -                           | Auto-install pip packages      |
| sget         | [src](/bin/sget)         | [doc](/doc/sget.md)         | Install package from source    |
| tenv         | [src](/bin/tenv)         | [doc](/doc/tenv.md)         | Toggle python virtual env      |


Installation
============

Download the source code:

    git clone https://github.com/d99kris/knixtools && cd knixtools

Install:

    ./make.sh install


License
=======

knixtools is distributed under the MIT license. See LICENSE file.


Contributions
=============

Bug reports are welcome, but feature requests and pull requests are generally
not entertained.


Keywords
========

unix, linux, macos, util, shell tools.
