########################################
# Tests: next patch
########################################
test_name="Create next patch pre-release/build version when no version nor pre-release/build version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.1.0-alpha
# when
git-semver next patch
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Create next patch pre-release/build version with custom pre-release metadata when no version nor pre-release/build version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.1.0-rc1
# when
git-semver next patch --metadata rc1
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Create next patch pre-release/build version with custom dash prefixed pre-release metadata when no version nor pre-release/build version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.1.0-rc1
# when
git-semver next patch --metadata -rc1
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Create next patch pre-release/build version with custom build metadata when no version nor pre-release/build version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.1.0+001
# when
git-semver next patch --metadata +001
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Create next patch pre-release/build version with custom metadata when no version nor pre-release/build version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.1.0-rc1+001
# when
git-semver next patch --metadata rc1+001
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Create next patch pre-release/build version when there is a release version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.1.1-alpha
git tag 0.1.0
# when
git-semver next patch
# then
assert_version_exists "${expected_version}"
assert_version_count_is 2
cleanup
success "${test_name}"

test_name="Create next patch pre-release/build version with custom pre-release metadata when there is a release version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.1.1-rc1
git tag 0.1.0
# when
git-semver next patch --metadata rc1
# then
assert_version_exists "${expected_version}"
assert_version_count_is 2
cleanup
success "${test_name}"

test_name="Create next patch pre-release/build version with custom dash prefixed pre-release metadata when there is a release version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.1.1-rc1
git tag 0.1.0
# when
git-semver next patch --metadata -rc1
# then
assert_version_exists "${expected_version}"
assert_version_count_is 2
cleanup
success "${test_name}"

test_name="Create next patch pre-release/build version with custom build metadata when there is a release version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.1.1+001
git tag 0.1.0
# when
git-semver next patch --metadata +001
# then
assert_version_exists "${expected_version}"
assert_version_count_is 2
cleanup
success "${test_name}"

test_name="Create next patch pre-release/build version with custom metadata when there is a release version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=0.1.1-rc1+001
git tag 0.1.0
# when
git-semver next patch --metadata rc1+001
# then
assert_version_exists "${expected_version}"
assert_version_count_is 2
cleanup
success "${test_name}"

test_name="Create next patch pre-release/build version when there is a pre-release version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=3.2.0-alpha
git tag "${expected_version}"
# when
git-semver next patch
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Create next patch pre-release/build version with custom pre-release metadata when there is a pre-release version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=3.2.0-alpha
git tag "${expected_version}"
# when
git-semver next patch --metadata rc1
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Create next patch pre-release/build version with custom dash prefixed pre-release metadata when there is a pre-release version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=3.2.0-alpha
git tag "${expected_version}"
# when
git-semver next patch --metadata -rc1
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Create next patch pre-release/build version with custom build metadata when there is a pre-release version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=3.2.0-alpha
git tag "${expected_version}"
# when
git-semver next patch --metadata +001
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"

test_name="Create next patch pre-release/build version with custom metadata when there is a pre-release version"
log "${test_name}"
# given
cleanup
setup-test-repo
expected_version=3.2.0-alpha
git tag "${expected_version}"
# when
git-semver next patch --metadata rc1+001
# then
assert_version_exists "${expected_version}"
assert_version_count_is 1
cleanup
success "${test_name}"
