# rules_format

Bazel rules for formatting.

## Example

To use buildifier as a formatter,

**WORKSPACE.bazel**

```bzl
workspace(name = "example")

load("@rules_format//rules/file:workspace.bzl", "files")

files(
    name = "example_files"
    build = "BUILD.file.bazel",
    root_file = "@example//WORKSPACE.bazel",
)
```

**BUILD.bazel**

```bzl
load("@rules_format//rules/buildifier:rules.bzl", "buildifier")
load("@rules_format//rules/format:rules.bzl", "format")

buildifier(
    name = "buildifier",
)

format(
    name = "buildifier_format",
    srcs = ["@example_files//:buildifier_files"],
    formatter = "//:buildifier",
    prefix = "external/example_files/files",
)
```

**BUILD.file.bazel**

```bzl
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "buildifier_files",
    srcs = glob(
        [
            "files/**/*.bazel",
            "files/**/*.bzl",
            "files/**/BUILD",
            "files/**/WORKSPACE",
        ],
        ["**/bazel-*/**"],
    ),
)
```

Then run

```sh
packages="$(\
    find .-name BUILD -o -name BUILD.bazel \
    | sed -e 's:/[^/]*$::' -e 's:^\./::' -e 's:^:@example_files//files/:' -e 's:/.$::' \
    | tr '\n' , \
    | sed 's/,$//' \
)"

bazel run "--deleted_packages=$packages" @rules_format//:buildifier_format -- write
```
