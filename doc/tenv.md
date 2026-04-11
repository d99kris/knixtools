Tenv
====

Tenv - toggle python virtual environment - is a simple tool to toggle enabling/disabling a python
virtual environment.

Example Usage
=============

    ~$ tenv
    (.venv) ~$ pip3 install spacy
    Collecting spacy
    ...
    (.venv) ~$ tenv
    ~$

Usage
=====

For ease-of-use an alias setup is recommended:

    alias tenv=". $(which tenv)"

General usage (with alias):

    tenv

Options:

    <path> optionally specify virtual environment directory name

    --help display this help and exit

    --version
           output version information and exit

Keywords
========
toggle, virtualenv.
