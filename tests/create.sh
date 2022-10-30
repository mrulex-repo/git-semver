########################################
# Tests: create
########################################
test_name="Create new version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.98.4
# when
git-semver create "${expected_version}"
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Create new release version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.98.4
# when
git-semver create "${expected_version}"
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Create new pre-release version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.98.4-rc1
# when
git-semver create "${expected_version}"
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Create new build version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.98.4+001
# when
git-semver create "${expected_version}"
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Create new pre-release/build version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.98.4-rc1+001
# when
git-semver create "${expected_version}"
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Attempt to create a wrong version"
log "${test_name}"
# given
cleanup
setup-test-repo
# when
git-semver create wrong || echo ""
# then
assert_version_does_not_exist "wrong"
cleanup
success "${test_name}"
