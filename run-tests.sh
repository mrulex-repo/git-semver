#!/bin/bash

set -e

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

TEST_REPO_DIR="${DIR}/test-repo"

########################################
# Text Format
########################################

fmt_h1=$'\e[1;32m' 
fmt_h2=$'\e[1;33m' 
fmt_log=$'\e[1;35m'
fmt_cmd=$'\e[1;36m'
fmt_err=$'\e[1;31m'
fmt_clr=$'\e[0m'   

########################################
# Usage
########################################
usage() {
	echo "Usage: "
  echo "    ${fmt_h1}$(basename "$0") list${fmt_clr}"
	echo "        Show all available tests."
	echo
	echo "    ${fmt_h1}$(basename "$0") [--name <test1>] [--name <test2>] ... [--name <testN>]${fmt_clr}"
	echo "        Run specified tests."
  echo
	echo "    ${fmt_h1}$(basename "$0") help${fmt_clr}"
	echo "        This message"
}


########################################
# Helper functions
########################################

function log() {
	>&2 echo "${fmt_log}[TEST LOG] ${1}${fmt_clr}"
}

function fail() {
	>&2 echo "${fmt_err}[TEST FAILED] ${1}${fmt_clr}"
	exit 1
}

function success() {
	>&2 echo "${fmt_cmd}[TEST SUCCEED] ${1}${fmt_clr}"
	echo
}

function goto-script-dir() {
	cd "${DIR}"
}

function goto-test-repo() {
	cd "${TEST_REPO_DIR}"
}

function setup-test-repo() {
	mkdir "${TEST_REPO_DIR}"
	goto-test-repo
	git init &> /dev/null
	git config user.name "test" &> /dev/null
	git config user.email "test@test" &> /dev/null
	touch dummy &> /dev/null
	git add .  &> /dev/null
	git commit -m "initial commit" &> /dev/null
}

function cleanup() {
	goto-script-dir
	rm -rf "${TEST_REPO_DIR}"
}

function git-semver() {
	"${DIR}/git-semver.sh" $@
}

function version_exists(){
  git rev-parse "${1}" &> /dev/null && echo true || echo false
}

function assert_version() {
  current_version="${1}"
  expected_version="${2}"
  current_version_exists=$(version_exists "${current_version}")

  if [ "${current_version_exists}" == false ]; then
  	fail "Version ${current_version} does not exist"
  elif ! [ "${current_version}" == "${expected_version}" ]; then
  	fail "Version ${current_version} does not match expected ${expected_version}"
  fi
}

function assert_version_does_not_exist() {
  unexpected_version="${1}"
  unexpected_version_exists=$(version_exists "${unexpected_version}")
  
  if [ "${unexpected_version_exists}" == true ]; then
  	fail "Version ${unexpected_version} exists"
  fi
}

function assert_version_exists() {
  expected_version="${1}"
  expected_version_exists=$(version_exists "${expected_version}")
  
  if [ "${expected_version_exists}" == false ]; then
  	fail "Version ${expected_version} does not exist"
  fi
}

function assert_version_count_is() {
  version_count_expected="${1}"
  version_count=$(git tag -l | wc -l)
  
  if ! [ "${version_count}" == "${version_count_expected}" ]; then
  	fail "Version count ${version_count} does not ${version_count_expected}"
  fi
}


# Parse args
action=
tests_to_run=
while [ $# -gt 0 ]; do
  case "$1" in
	  list)
      action=list-tests
      break
      ;;
		--name)
			action=run-test
      shift
      tests_to_run="${1} ${tests_to_run}"
			;;
		help)
			usage
      exit 0
      ;;
	  *)
      usage
      exit 1
      ;;
  esac
  shift
done

tests_files_dir="${DIR}/tests/"
tests_files_pattern="${tests_files_dir}*.sh"

if [ -z "${action}" ]; then
  for f in ${tests_files_pattern}; do 
    source ${f}
  done
elif [ "${action}" == "list-tests" ]; then
  for f in ${tests_files_pattern}; do 
    echo $(echo "${f}" | sed "s|^${tests_files_dir}||g" | sed "s|.sh$||g" | sort)
  done
elif [ "${action}" == "run-test" ]; then
  for f in ${tests_to_run}; do 
    test_file="${tests_files_dir}${f}.sh"
    if [[ -f "${test_file}" ]]; then
      source "${test_file}"
    else
      fail "Test does not exist: ${f}"
    fi
  done
fi  
