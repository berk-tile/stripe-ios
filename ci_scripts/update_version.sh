#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the release string from ${PROJECT_DIR}/VERSION
release_version="$(cat "${script_dir}/../VERSION")"

echo "Updating version to '${release_version}'"

# Generate Version.xcconfig to use to set the framework version string
cat > ${script_dir}/../BuildConfigurations/Version.xcconfig <<EOF
//
// Version.xcconfig
//
// This file was generated by update_version.sh
// Do not edit this file directly.
// Instead, edit the \`VERSION\` file and run \`ci_scripts/update_version.sh\`
//

CURRENT_PROJECT_VERSION=$release_version
EOF

echo "Successfully updated 'Version.xcconfig'"

# Generate StripeAPIConfiguration+Version.swift
cat > "${script_dir}/../StripeCore/StripeCore/Source/API Bindings/StripeAPIConfiguration+Version.swift"  <<EOF
//
// StripeAPIConfiguration+Version.swift
//
// This file was generated by update_version.sh
// Do not edit this file directly.
// Instead, edit the \`VERSION\` file and run \`ci_scripts/update_version.sh\`
//

import Foundation

public extension StripeAPIConfiguration {
    /// The current version of this library.
    static let STPSDKVersion = "${release_version}"

    /*
     NOTE: \`STPSDKVersion\` must be a hard-coded static string instead of
     dynamically generated from the bundle's \`CFBundleShortVersionString\` to
     ensure the correct value is returned when the SDK is statically linked.
     */

}
EOF

echo "Successfully updated 'StripeAPIConfiguration+Version.swift'"


# Replace the version in all .podspec files
for podspec in ${script_dir}/../*.podspec
do
  cat $podspec | sed -E "s|(s\.version *= *)'(.*)'|\1'$release_version'|" > $podspec.copy
  mv $podspec.copy $podspec

  echo "Successfully updated '$(basename $podspec)'"
done
