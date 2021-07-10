#! /bin/bash

# File:    get-python-src.sh
# Github:  https://github.com/scottsideleau/get-python-src
# License: Copyright (C) 2021, Scott R. Sideleau (@scottsideleau)
#
#          Licensed under the Apache License, Version 2.0 (the "License");
#          you may not use this file except in compliance with the License.
#          A copy of the License is distributed with this source.  Else,
#          you may obtain a copy of the License at:
#
#          https://www.apache.org/licenses/LICENSE-2.0.html
#
#          Unless required by applicable law or agreed to in writing, software
#          distributed under the License is distributed on an "AS IS" BASIS,
#          WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
#          implied.  See the License for the specific language governing 
#          permissions and limitations under the License.

WELCOME="
  FETCH (and/or BUILD) source for Custom Python Environment
  ------------------------------------------------------------------------"
echo "${WELCOME}"

USAGE="
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
"

# Initialize
FETCH=false
BUILD=false
INSTALL=false
STATIC=false

# Facilitate running this script from any location.
if [ `uname` = "Linux" ]; then
    SCRIPT_PATH=`readlink -f $0`
else
    # Mac/BSD version of 'readlink' doesn't support -f option
    SCRIPT_PATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
fi
SCRIPT_DIR=`dirname ${SCRIPT_PATH}`

# Store the Python version information
if [ -z "${1}" ];
then
  echo "  ERROR: Missing version"
  echo -n "${USAGE}"
  exit 1
else
  if [[ ${1} =~ ^[0-9].[0-9][0-9]?$ ]];
  then
    SPECIFIC=false
  elif [[ ${1} =~ ^[0-9].[0-9][0-9]?.[0-9][0-9]?$ ]];
  then
    SPECIFIC=true
  else
    echo "  ERROR: Invalid version '${1}'"
    echo "         Use form N.N or N.N.N"
    echo "${USAGE}"
    exit 1
  fi
  VERSION=${1}
fi

# Check for at least one user-provided parameter
if [ -z "${2}" ]; 
then
  echo "  ERROR: Missing parameter"
  echo -n "${USAGE}"
  exit 1
fi

# Handle the user-provided parameters
PARAMS=""
while (( "${#}" )); 
do
  case "${1}" in
    --fetch|-fetch|fetch)
      FETCH=true
      shift
      ;;
    --build|-build|build)
      BUILD=true
      shift
      ;;
    --static|-static|static)
      BUILD=true
      STATIC=true
      shift
      ;;
    --install|-install|install)
      BUILD=true
      INSTALL=true
      shift
      ;;
    --clean|-clean|clean)
      pushd ${SCRIPT_DIR} >& /dev/null
      echo "  Cleaning the src/ directory ...
      "
      rm -rf src/*
      popd >& /dev/null
      shift
      ;;
    --*|-*)
      echo "  ERROR: unsupported flag '${1}' " >&2
      echo "${USAGE}"
      exit 1
      ;;
    *)
      PARAMS="${PARAMS} ${1}"
      shift
      ;;
  esac
done

eval set -- ${PARAMS}

# Show version
echo "  Version: ${VERSION}"

# Show fetch status
echo -n "  Fetch:   "
if [ ${FETCH} = true ];
then
  echo "Yes"
else
  echo "No"
fi

# Show build status
echo -n "  Build:   "
if [ ${BUILD} = true ];
then
  echo "Yes"
else
  echo "No"
fi

# Evaluate status & print usage if no action requested
if [ ${FETCH} = false -a ${BUILD} = false ];
then
  echo "${USAGE}"
  exit 1
fi

# Get list of versions
VERSIONS=$( curl --silent https://www.python.org/ftp/python/ \
  | grep ">[0-9].*\/<" \
  | awk -v FS="(>|/<)" '{print $2}' \
  | sort --version-sort )

# If desired, fetch the source
if [ ${FETCH} = true ];
then
  if [ ${SPECIFIC} = true ];
  then
    VER=${VERSION}
  else
    VER=$( echo "$VERSIONS" \
      | grep "${VERSION}\." \
      | sort --version-sort \
      | tail -1 )
  fi
  URL="https://www.python.org/ftp/python/${VER}/Python-${VER}.tgz"
  echo "
  Fetching source for Python ${VER} from:"
  echo "    ${URL}
  "
  $( mkdir ${SCRIPT_DIR}/downloads >& /dev/null )
  pushd ${SCRIPT_DIR}/downloads >& /dev/null
  $( curl --remote-name --location --continue-at - ${URL} )
  popd >& /dev/null
fi

# If desired, build the source
if [ ${BUILD} = true ];
then
  $( mkdir ${SCRIPT_DIR}/src >& /dev/null )
  pushd ${SCRIPT_DIR}/src >& /dev/null
  echo "
  Extracting Python-${VER}.tgz ..."
  $( tar --extract --gzip --file=../downloads/Python-${VER}.tgz )
  $( mkdir Python-${VER}/debug >& /dev/null )
  pushd Python-${VER}/debug >& /dev/null
  echo "  Configuring ..."
  $( mkdir --parents /opt/python${VER}/lib )
  if [ ! -d "/opt/python${VER}/lib" ];
  then
    echo "  Error: Unable to write to /opt"
    echo "         Check your permissions"
    exit 1
  fi
  if [ ${STATIC} = true ];
  then
    DYNOPT=""
    DYNLIB=""
  else
    DYNOPT="--enable-shared"
    DYNLIB="-Wl,-rpath /opt/python${VER}/lib"
  fi
  ../configure ${DYNOPT} --with-lto --with-ensurepip=install \
    --enable-optimizations --prefix=/opt/python${VER} \
    LDFLAGS="${DYNLIB}"
  make -j $(getconf _NPROCESSORS_ONLN)

  # If desired, install
  if [ ${INSTALL} = true ];
  then
    make altinstall
  fi
  popd >& /dev/null
  popd >& /dev/null
fi

