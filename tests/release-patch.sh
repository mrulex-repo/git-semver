########################################
# Tests: release patch
########################################
test_name="Create patch release when no version nor pre-release/build version"
log "${test_name}"
# given
cleanup
setup-test-repo
# when
git-semver release patch
# then
assert_version_exists 0.1.0
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Create patch release when there is a pre-release/build version"
log "${test_name}"
# given
cleanup
setup-test-repo
git tag 0.1.0-rc1
# when
git-semver release patch
# then
assert_version_exists 0.1.0
assert_version_count_is 2
cleanup
success "${test_name}"

test_name="Create patch release when no pre-release/build version"
log "${test_name}"
# given
cleanup
setup-test-repo
git tag 0.1.0
# when
git-semver release patch
# then
assert_version_exists 0.1.1
assert_version_count_is 2
cleanup
success "${test_name}"
