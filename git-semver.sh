#!/bin/bash

set -e

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
# Common constants
########################################

const_modifiers_next="major|minor|patch"
const_modifiers_release="${const_modifiers_next}"

regex_metadata_valid_chars="[0-9A-Za-z-]+"
regex_metadata_pre_release="[-]?${regex_metadata_valid_chars}(\.${regex_metadata_valid_chars})*"
regex_metadata_build="[+]${regex_metadata_valid_chars}(\.${regex_metadata_valid_chars})*"

########################################
# Usage
########################################
usage() {
	log "Printing usage"
	echo "Usage: $(basename-git "$0") [command]"
	echo 
	echo "See https://github.com/mrulex-repo/git-semver for more detail."
	echo
	echo "Commands"
	echo
	echo "    ${fmt_h1}current${fmt_clr}"
	echo "        Gets the current version tag."
	echo
	echo "    ${fmt_h1}create <version>${fmt_clr}"
	echo "        Createa version tag."
	echo
	echo "    ${fmt_h1}next <${const_modifiers_next}> [--metadata <metada>]${fmt_clr}"
	echo "        Generates a pre-release/build tag for the next version, if not metadata option"
	echo "        is provided it adds the pre-release ${fmt_h2}alpha${fmt_clr} metadata to the version,"
	echo "        otherwise it adds the provided metadata to the version. Examples:"
	echo "            - ${fmt_h1}next major${fmt_clr}"
	echo "                  Increases major version, for example: If current version is"
	echo "                  ${fmt_h2}0.1.0${fmt_clr} then next major version will be ${fmt_h2}1.0.0-alpha${fmt_clr}."
  echo "            - ${fmt_h1}next major --metadata rc1${fmt_clr}"
  echo "                  Increases major version and adds ${fmt_h2}rc1${fmt_clr} metadata, for example:"
	echo "                  If current version is ${fmt_h2}0.1.0${fmt_clr} then next major version will be"
	echo "                  ${fmt_h2}1.0.0-rc1${fmt_clr}"
	echo "            - ${fmt_h1}next minor --metadata +8546af${fmt_clr}"
	echo "                  Increases minor version and adds ${fmt_h2}+8546af${fmt_clr} metadata, for "
	echo "                  example: If current version is ${fmt_h2}0.1.0${fmt_clr} then next minor version"
	echo "                  will be ${fmt_h2}0.2.0+8546af${fmt_clr}"
	echo "            - ${fmt_h1}next minor --metadata rc1+8546af${fmt_clr}"
	echo "                  Increases minor version and adds ${fmt_h2}rc1+8546af${fmt_clr} metadata, for"
	echo "                  example: If current version is ${fmt_h2}0.1.0${fmt_clr} then next minor version"
	echo "                  will be ${fmt_h2}0.2.0-rc1+8546af${fmt_clr}"
	echo "            - ${fmt_h1}next patch${fmt_clr}"
	echo "                  Increases patch version, for example: If current version is"
	echo "                  ${fmt_h2}0.1.0${fmt_clr} then next patch version will be ${fmt_h2}0.1.1-alpha${fmt_clr}"
	echo "    ${fmt_h1}release [${const_modifiers_release}]${fmt_clr}"
	echo "        Generates a release tag based on a pre-release/build version. If there is no"
  echo "        pre-release/build tag defined one of the modifier arguments (major, minor "
	echo "        or patch) need to be provided. Examples:"
	echo "            - ${fmt_h1}release${fmt_clr}"
	echo "                  - If there is no version nor pre-release/build tag created it will create version ${fmt_h2}0.1.0${fmt_clr}."
	echo "                  - If there is no pre-release/build tag created it will fail and show"
	echo "                    the error ${fmt_h2}No pre-release/build tag created, please create one or"
	echo "                    provide the proper modifier argument${fmt_clr}."
	echo "                  - If there is a pre-release/build tag it removes the metadata part"
	echo "                    and leaves only the version part, for example if the pre-release/build"
	echo "                    tag is${fmt_h2}1.0.0-alpha${fmt_clr} or ${fmt_h2}1.0.0-rc1+8546af${fmt_clr} or ${fmt_h2}1.0.0+8546af${fmt_clr} it"
	echo "                    will create the release tag ${fmt_h2}1.0.0${fmt_clr}."
	echo "            - ${fmt_h1}release major${fmt_clr}"
	echo "                  - If there is not a pre-release/build tag nor a release tag it will create"
	echo "                    the release tag ${fmt_h2}0.1.0${fmt_clr},effect is same as"
	echo "                    without the modifier argument."
	echo "                  - If there is pre-release/build tag created it will create the"
	echo "                    release tag based on the pre-release/build tag, effect is same as"
	echo "                    without the modifier argument."
	echo "                  - If there is not a pre-release/build tag it will create the release tag"
	echo "                    based on the last release tag and increase the major version, for"
	echo "                    example: If the last release tag is ${fmt_h2}1.1.0${fmt_clr} then it will create"
	echo "                    the release tag ${fmt_h2}2.0.0${fmt_clr}."
	echo "            - ${fmt_h1}release minor${fmt_clr}"
	echo "                  - If there is not a pre-release/build tag nor a release tag it will create"
	echo "                    the release tag ${fmt_h2}0.1.0${fmt_clr}."
	echo "                  - If there is pre-release/build tag created it will create the"
	echo "                    release tag based on the pre-release tag, effect is same as"
	echo "                    without the modifier argument."
	echo "                  - If there is not a pre-release/build tag it will create the release tag"
	echo "                    based on the last release tag and increase the minor version, for"
	echo "                    example: If the last release tag is ${fmt_h2}1.0.1${fmt_clr} then it will create"
	echo "                    the release tag ${fmt_h2}1.1.0${fmt_clr}."
	echo "            - ${fmt_h1}release patch${fmt_clr}"
	echo "                  - If there is not a pre-release/build tag nor a release tag it will create"
	echo "                    the release tag ${fmt_h2}0.1.0${fmt_clr}"
	echo "                  - If there is pre-release/build tag created it will create the"
	echo "                    release tag based on the pre-release tag, effect is same as"
	echo "                    without the modifier argument."
	echo "                  - If there is not a pre-release/build tag it will create the release tag"
	echo "                    based on the last release tag and increase the patch version, for"
	echo "                    example: If the last release tag is ${fmt_h2}1.0.0${fmt_clr} then it will create"
	echo "                    the release tag ${fmt_h2}1.0.1${fmt_clr}."
	echo "    ${fmt_h1}help${fmt_clr}"
	echo "        This message"
	echo
	echo
	echo "There are also optional arguments that can be added to the commands:"
	echo
	echo "    --${fmt_h1}dry-run${fmt_clr}"
	echo "        Simulates the excution, but does not perform any action"
	echo
	echo "    --${fmt_h1}verbose${fmt_clr}"
	echo "        Shows all the details during the execution"
	log "Usage printed, exiting..."
	exit
}

########################################
# Helper functions
########################################

function basename-git() {
	log "Getting basename with git command"
	result=$(basename "$1" | tr '-' ' ' | sed 's/.sh$//g')
	log "basename with git command is: ${result}"
	echo -n ${result}
}

function log() {
	if [ ${verbose} == 1 ]; then
		>&2 echo "${fmt_log}[LOG] ${1}${fmt_clr}"
	fi	
}

function log_error() {
	>&2 echo "${fmt_err}[ERROR] ${1}${fmt_clr}"
}

function log_cmd() {
	>&2 echo "${fmt_cmd}${1}${fmt_clr}"
}

function run_cmd() {
	local cmd=${1}
	log "Command to execute: ${cmd}"
	if [ ${dry_run} == 1 ]; then
		log_cmd "${cmd}"
	else
		$cmd
	fi	
}

function validate-metadata() {
	local metadata=$1
	log "Validating metadata: ${metadata}"
	local regex_metadata="^(${regex_metadata_pre_release})?(${regex_metadata_build})?$"
	local regex_leading_zeroes_head="[0]+[0-9]*"
	local regex_leading_zeroes_part="\.[0]+[0-9]*"

	if ! [[ "$metadata" =~ ${regex_metadata} ]]; then
		log_error "Metadata is not valid."
		exit 1
	fi
		
	if [[ "${metadata}" =~ ${metadata_regex} ]]; then
		local error_prerelease_leading_zeroes="Pre-release is not valid. Numeric identifiers MUST NOT include leading zeroes."
		if [[ "${metadata}" =~ ^[-]?${regex_leading_zeroes_head}(\.${regex_metadata_valid_chars})*(${regex_metadata_build})?$ ]]; then
			log_error "${error_prerelease_leading_zeroes}"
      exit 1
		elif [[ "${metadata}" =~ ^[-]?${regex_metadata_valid_chars}(\.${regex_metadata_valid_chars})*(\.${regex_leading_zeroes_head})(\.${regex_metadata_valid_chars})*(${regex_metadata_build})?$ ]]; then
			log_error "${error_prerelease_leading_zeroes}"
      exit 1
		fi
	fi
	log "Metadata validation done: ${metadata}"
}

function is-pre-release-build-version() {
	local version=$1
	log "Checking if version is pre-release/build: ${version}"
	local regex_pre_release_build="^${VERSION_PREFIX}[0-9]+(\.[0-9]+){2}(${regex_metadata_pre_release})?(${regex_metadata_build})?$"

	result=true
	if ! [[ "$version" =~ ${regex_pre_release_build} ]]; then
		result=false
	fi
	log "Version is pre-release/build: ${result}"
	
	echo ${result}
}

function is-release-version() {
	local version=$1
	log "Checking if version is pre-release/build: ${version}"
	local regex_release="^${VERSION_PREFIX}[0-9]+(\.[0-9]+){2}$"

	result=true
	if ! [[ "$version" =~ ${regex_release} ]]; then
		result=false
	fi
	log "Version is a release: ${result}"
	
	echo ${result}
}

function validate-next-modifier() {
	local modifier=$1
	log "Validating next modifier: ${modifier}"
	local regex_modifiers="^(${const_modifiers_next})$"

	if ! [[ "$modifier" =~ ${regex_modifiers} ]]; then
		log_error "next modifier is not valid."
		exit 1
	fi

	log "next modifier validation done: ${modifier}"
}

function validate-release-modifier() {
	local modifier=$1
	log "Validating release modifier: ${modifier}"
	local regex_modifiers="^(${const_modifiers_release})$"

	if ! [ -z "${modifier}" ]; then
		if ! [[ "$modifier" =~ ${regex_modifiers} ]]; then
			log_error "release modifier is not valid."
			exit 1
		fi
	fi

	log "release modifier validation done: ${modifier}"
}

########################################
# Version functions
########################################

function version-remove-prefix() {
    echo "$1" | sed "s/^${VERSION_PREFIX}//g"
}

function version-parse-major() {
    echo "$1" | cut -d "." -f1 | sed "s/^${VERSION_PREFIX}//g"
}

function version-parse-minor() {
    echo "$1" | cut -d "." -f2
}

function version-parse-patch() {
    echo "$1" | cut -d "." -f3 | sed 's/[-+].*$//g'
}

function version-calculate-metadata() {
	local metadata=${1}
	log "Calculating metadata: ${metadata}"
	
	if [ -z ${metadata} ]; then
		metadata=${VERSION_DEFAULT_METADATA:-alpha}
	fi
	
	if ! [[ "${metadata}" =~ ^[-].*$ ]]; then
		if ! [[ "${metadata}" =~ ^[+].*$ ]]; then
			metadata="-${metadata}"
		fi
	fi
	log "Metadata: ${metadata}"

	echo "${metadata}"
}

function current-version() {
	log "Calculating current version"
  local sort_args version version_pre_releases pre_release_id_count pre_release_id_index
  local tags=$(git tag)
	log "Found git tags: ${tags}"
  local version_pre_release=$(
    local version_main=$(
      echo "$tags" |
        grep "^${VERSION_PREFIX}[0-9]\+\.[0-9]\+\.[0-9]\+" |
        awk -F '[-+]' '{ print $1 }' |
        uniq |
        sort -t '.' -k 1,1n -k 2,2n -k 3,3n |
        tail -n 1
    )
		log "Version main: ${version_main}"
		
    local version_pre_releases=$(
      echo "$tags" |
        grep "^${version_main//./\\.}" |
        awk -F '-' '{ print $2 }'
    )
		log "Version pre-releases: ${version_pre_releases}"

    local pre_release_id_count=$(
      echo "$version_pre_releases" | tr -d -c ".\n" |
        awk 'BEGIN{ max = 0 }
        { if (max < length) { max = length } }
        END{ if ( max == 0 ) { print 0 } else { print max + 1 } }'
    )
		log "Version pre-releases id count: ${pre_release_id_count}"

    local sort_args='-t.'
    for ((pre_release_id_index=1; pre_release_id_index<=$pre_release_id_count; pre_release_id_index++)); do
      chars="$(echo "$version_pre_releases" | awk -F '.' '{ print $'$pre_release_id_index' }' | tr -d $'\n')"
      if [[ "$chars" =~ ^[0-9]*$ ]]; then
          sort_key_type=n
      else
          sort_key_type=
      fi
      sort_args="$sort_args -k$pre_release_id_index,$pre_release_id_index$sort_key_type"
    done
    echo "$version_pre_releases" |
      eval sort $sort_args |
      awk '{ if (length == 0) { print "'$version_main'" } else { print "'$version_main'-"$1 } }' |
      tail -n 1
  )
	log "Version pre-release: ${version_pre_release}"
	
  # Get the version with the build number
  version=$(echo "$tags" | grep "^${version_pre_release//./\\.}" | tail -n 1)
  echo "${version}"
}

function version-do() {
  local new="${VERSION_PREFIX}$1"
	log "Creating version tag: ${new}"

  local sign="${GIT_SIGN:-0}"
	log "Sign tag: ${sign}"

  local cmd="git tag"
  
	if [ "${sign}" == "1" ]; then
      cmd="${cmd} --annotate --sign --message ${new}"
  fi
	
  run_cmd "${cmd} ${new}"

	log_cmd "Version tag created: ${new}"
}

function next-major() {
	log "Calculating next major pre-release version"
	local new_version minor_version 
	
	local current_version=$(current-version || echo "")
	log "Current version: ${current_version}"
	
	local metadata=$(version-calculate-metadata "${1}")
	
	if [ -z "${current_version}" ]; then
		new_version=0
		minor_version=1
	else
		new_version=$(( $(version-parse-major "${current_version}") + 1 ))
		minor_version=0
	fi
	
	new_version="${new_version}.${minor_version}.0${metadata}"
	log "Next major version: ${new_version}"
	
	version-do "${new_version}"
}

function next-minor() {
	log "Calculating next minor pre-release version"
	local new_version major_version
	
	local current_version=$(current-version || echo "")
	log "Current version: ${current_version}"
	
	local metadata=$(version-calculate-metadata "${1}")
	
	if [ -z "${current_version}" ]; then
		major_version=0
		new_version=1
	else
		major_version=$(version-parse-major "${current_version}")
		new_version=$(( $(version-parse-minor "${current_version}") + 1 ))
	fi
	
	new_version="${major_version}.${new_version}.0${metadata}"
	log "Next minor version: ${new_version}"
	
	version-do "${new_version}"
}

function next-patch() {
	log "Calculating next patch pre-release version"
	local new_version major_version minor_version
	
	local current_version=$(current-version || echo "")
	log "Current version: ${current_version}"
	
	local metadata=$(version-calculate-metadata "${1}")
	
	if [ -z "${current_version}" ]; then
		major_version=0
		minor_version=1
		new_version=0
	else
		major_version=$(version-parse-major "${current_version}")
		minor_version=$(version-parse-minor "${current_version}")
		new_version=$(( $(version-parse-patch "${current_version}") + 1 ))
	fi
	
	new_version="${major_version}.${minor_version}.${new_version}${metadata}"
	log "Next patch version: ${new_version}"
	
	version-do "${new_version}"
}

function calculate-release-version() {
	log "Calculating release version"
	local current_version=$(current-version || echo "0.1.0-alpha")
	local new_version
	
	if ! [[ $(is-pre-release-build-version "${current_version}") == true ]]; then
		log_error "No pre-release/build tag created, please create one or provide the proper modifier argument"
		exit 1
	fi
	
	echo $(version-parse-major ${current_version}).$(version-parse-minor ${current_version}).$(version-parse-patch ${current_version})
}

function release-do() {
	log "Calculating release version"
	local current_version=$(current-version)
	local new_version
	
	if [ -z "${current_version}" ]; then
		current_version=0.1.0-alpha
	elif [[ $(is-release-version "${current_version}") == true ]]; then
		log_error "No pre-release/build tag created, please create one or provide the proper modifier argument"
		exit 1
	fi
	
	new_version=$(version-parse-major ${current_version}).$(version-parse-minor ${current_version}).$(version-parse-patch ${current_version})
	
	version-do "${new_version}"
}

function release-major() {
	log "Calculating major release version"
	local current_version=$(current-version)
	
	if [ -z "${current_version}" ]; then
		version-do 0.1.0
	elif [[ $(is-release-version "${current_version}") == true ]]; then
		local major_version=$(( $(version-parse-major "${current_version}") + 1 ))		
		version-do "${major_version}.0.0"
	elif [[ $(is-pre-release-build-version "${current_version}") == true ]]; then
		release-do
	else
		log_error "Oops!!! don't know how to release major the version ${current_version}"
	fi
}

function release-minor() {
	log "Calculating minor release version"
	local current_version=$(current-version)
	local new_version
	
	if [ -z "${current_version}" ]; then
		version-do 0.1.0
	elif [[ $(is-release-version "${current_version}") == true ]]; then
		local major_version=$(version-parse-major "${current_version}")
		local minor_version=$(( $(version-parse-minor "${current_version}") + 1 ))
		version-do "${major_version}.${minor_version}.0"
	elif [[ $(is-pre-release-build-version "${current_version}") == true ]]; then
		release-do
	else
		log_error "Oops!!! don't know how to release major the version ${current_version}"
	fi
}

function release-patch() {
	log "Calculating patch release version"
	local current_version=$(current-version)
	local new_version
	
	if [ -z "${current_version}" ]; then
		version-do 0.1.0
	elif [[ $(is-release-version "${current_version}") == true ]]; then
		local major_version=$(version-parse-major "${current_version}")
		local minor_version=$(version-parse-minor "${current_version}")
		local patch_version=$(( $(version-parse-patch "${current_version}") + 1 ))
		version-do "${major_version}.${minor_version}.${patch_version}"
	elif [[ $(is-pre-release-build-version "${current_version}") == true ]]; then
		release-do
	else
		log_error "Oops!!! don't know how to release major the version ${current_version}"
	fi
}


########################################
# Run
########################################

# Set home
readonly DIR_HOME="${HOME}"

# Use XDG Base Directories if possible
# (see http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html)
DIR_CONF="${XDG_CONFIG_HOME:-${HOME}}/.git-semver"

# Set vars
DIR_ROOT="$(git rev-parse --show-toplevel 2> /dev/null || echo -n '')"

# Set (and load) user config
if [ -f "${DIR_ROOT}/.git-semver" ]
then
    FILE_CONF="${DIR_ROOT}/.git-semver"
    source "${FILE_CONF}"
elif [ -f "${DIR_CONF}/config" ]
then
    FILE_CONF="${DIR_CONF}/config"
    # shellcheck source=config.example
    source "${FILE_CONF}"
else
    # No existing config file was found; use default
    FILE_CONF="${DIR_HOME}/.git-semver/config"
fi

# Parse args
action=
modifier=
metadata=
dry_run=0
verbose=0
while [ $# -gt 0 ]; do
	log "Remainig arguments: $#"
  case "$1" in
	  --dry-run)
      dry_run=1
			log "Dry run enabled"
      ;;
		--verbose)
			verbose=1
			log "Verbose enabled"
			;;
		--metadata)
			metadata=$2
			log "Metadata argument: ${metadata}"
			shift
      ;;
		help)
			action=$1
      break
      ;;
	  create|current|next|release)
      action=$1
			log "Action argument: ${action}"
      ;;
	  *)
      modifier=$1
			log "Modifier argument: ${modifier}"
      ;;
  esac
  shift
done

log "Parsed arguments: verbose=${verbose} dry_run=${dry_run} metadata=${metadata} action=${action} modifier=${modifier}"

case "${action}" in
  current)
	  current_version=$(current-version)
		if [ "" == "${current_version}" ]; then
			log_error "No current version yet"
			exit 1
		fi
		echo ${current_version}
	  ;;
	create)
		if ! [[ $(is-pre-release-build-version "${modifier}") == true ]]; then
			log_error "Version provided is not valid."
			exit 1
		fi
		version-do "$(version-remove-prefix "${modifier}")"		
    ;;
  next)
		validate-next-modifier "${modifier}"
		current_version=$(current-version)
		if [ -n "${current_version}" ] && [ "$(is-release-version "${current_version}")" == "false" ]; then
			log_cmd "Version tag created: ${current_version}"
		else
			validate-metadata "${metadata}"
	    next-${modifier} "${metadata}"
		fi
    ;;
  release)
		validate-release-modifier "${modifier}"
		release-${modifier:-do}
    ;;
  *)
	  usage
	  ;;
esac
