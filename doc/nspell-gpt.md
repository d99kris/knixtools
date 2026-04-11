nspell-gpt
==========

The nspell-gpt utility utilizes OpenAI's ChatGPT to provide users with
spell and grammar checking features as well as other text editing
capabilities.


Usage
=====
Usage:

    usage: nspell-gpt [-h] [-a] [-t TOOL] [-v] FILE

Command-line Options:

    -h, --help
           show this help message and exit

    -a, --accept
           non-interactive use (accepting first suggestion)

    -t TOOL, --tool TOOL
           list of tools: spell, rephrase, formal, legal, short, gentle, absurd, pirate, bible,
           truly, savannah, singlish, aussie, grand, airplane, idiom, vague

    -v, --version
           show version

    FILE   file to check and modify


Pre-requisites
==============
An OpenAI API key is needed. Sign up at [OpenAI](https://platform.openai.com/)
and go to [API keys](https://platform.openai.com/account/api-keys) and click
`Create new secret key`.

Create the file `~/.config/nspell-gpt/api.conf` containing

    OPENAI_API_KEY=yourkey

Alternatively set the environment variable `OPENAI_API_KEY` to contain your
key.


Customizations
==============
You may create your own tools / prompts for ChatGPT. Create a file at
`~/.config/nspell-gpt/tools.conf` and add lines on the format
`name=ChatGPT prompt`. Example:

    film=Rephrase the following sentence in {lang} using at least one famous film quote:

(Keyword `{lang}` will be replaced by the actual source language detected.)


Keywords
========
terminal, tui, spell-checker, chatgpt.
