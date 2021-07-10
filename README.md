# Get Python from Source
## Easily fetch, build, and install any version of Python from source

This rootless script enables you to specify a major/minor (or, at your 
discretion, a major/minor/patch) version of Python to be downloaded and
optionally unpacked, built, and installed into your local /opt directory.

### Assumptions
  * You have access to Bourne-Again SHell (BASH) on Linux or MacOS
  * You have privileges to read/write to /opt
  * You have a desire to use:
    * the latest patch of a Python release (e.g. 3.6), or
    * a specific patch of a Python release (e.g. 3.6.8)
  * You have already installed the dependencies to build Python (see below)

### Generated Files
This script, upon being executed, will generate locally:

Directory/File           | Description
---                      | ---
downloads/               | Directory for Python source archives (.tgz)
src/                     | Directory for unpacked Python source files
src/Python-N.NN/debug    | Directory for configuring/building Python version
/opt/pythonN.NN          | Optionally, install directory for built Python

### Install Dependencies to Build Python
On Enterprise Linux, the following dependencies are needed:

    sudo yum update
    sudo yum groups mark install "Development Tools"
    sudo yum groups mark convert "Development Tools"
    sudo yum groupinstall -y "Development Tools"
    sudo yum install \
      zlib-devel     \
      bzip2-devel    \
      gdbm-devel     \
      ncurses-devel  \
      xz-devel       \
      readline-devel \
      tk-devel       \
      openssl-devel  \
      libffi-devel   \
      sqlite-devel   \
      db4-devel      \
      libpcap-devel  \
      expat-devel

On Ubuntu, the following dependencies are needed:

    sudo apt update && sudo apt install \
      build-essential                   \
      libncursesw5-dev                  \
      libreadline-gplv2-dev             \
      libssl-dev                        \
      libgdbm-dev                       \
      libc6-dev                         \
      libsqlite3-dev                    \
      libbz2-dev                        \
      libffi-dev

Other Debian-based distributions should have similarly named dependencies.

On MacOS (Homebrew), the following dependencies are needed:

    brew update && brew install \
      openssl    \
      readline   \
      sqlite3    \
      xz         \
      zlib

Additional MacOS environment configuration may be required to use all features:

    export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
    export PATH="/usr/local/opt/sqlite/bin:$PATH"

    export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib:$LDFLAGS"
    export LDFLAGS="-L/usr/local/opt/readline/lib:$LDFLAGS"
    export LDFLAGS="-L/usr/local/opt/sqlite/lib:$LDFLAGS"
    export LDFLAGS="-L/usr/local/opt/zlib/lib:$LDFLAGS"

    export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include:$CPPFLAGS"
    export CPPFLAGS="-I/usr/local/opt/readline/include:$CPPFLAGS"
    export CPPFLAGS="-I/usr/local/opt/sqlite/include:$CPPFLAGS"
    export CPPFLAGS="-I/usr/local/opt/zlib/include:$CPPFLAGS"

### Using this Script
    ./get-python-src.sh <version> <params>

    The <version> is required:
      - Major/Minor         e.g. 3.6      Fetches latest release
      - Major/Minor/Patch   e.g. 3.6.14   Fetches user-specified release

    At least one <param> is required:
      "fetch"   - Only fetch the source (.tgz)
      "build"   - Fetch, unpack, & build the source (.so version)
      "static"  - Build the source as static library (.a version)
      "install" - Install the Python build to /opt/python<version>
      "clean"   - Clean the src/ directory

    NOTE: The <params> can be stacked (any order) for increased effect.

### References
* Most complete guide (includes LDFLAG hint):<br/>
  https://danieleriksson.net/2017/02/08/how-to-install-latest-python-on-centos/

* Info on Additional build flags:<br/>
  https://realpython.com/installing-python/#how-to-build-python-from-source-code

* Clarification on build prefixes:<br/>
  https://www.devdungeon.com/content/how-build-python-source

* Find Python source downloads:<br/>
  https://www.python.org/downloads/

