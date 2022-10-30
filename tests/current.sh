########################################
# Tests: current
########################################
test_name="Get current version when no previous version in place"
log "${test_name}"
# given
cleanup
setup-test-repo
# when
current_version=$(git-semver current || echo "none")
# then
assert_version_does_not_exist "${current_version}"
assert_version_count_is 0
cleanup
success "${test_name}"

test_name="Get current version when there is previous release version in place"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.98.4
git tag ${expected_version}
# when
current_version=$(git-semver current)
# then
assert_version "${current_version}" "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Get current version when there is previous pre-release version in place"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.98.4-rc1
git tag ${expected_version}
# when
current_version=$(git-semver current)
# then
assert_version "${current_version}" "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Get current version when there is previous build version in place"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.98.4+001
git tag ${expected_version}
# when
current_version=$(git-semver current)
# then
assert_version "${current_version}" "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Get current version when there is previous pre-release/build version in place"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.98.4-rc1+001
git tag ${expected_version}
# when
current_version=$(git-semver current)
# then
assert_version "${current_version}" "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"
