# rules_file

Bazel rules for basic file operations, like creating directories, and formatting.

## Example

To use buildifier as a formatter,

**WORKSPACE.bazel**

```bzl
workspace(name = "example")

load("@rules_file//file:workspace.bzl", "files")

files(
    name = "example_files"
    build = "BUILD.file.bazel",
    root_file = "@example//WORKSPACE.bazel",
)
```

**BUILD.bazel**

```bzl
load("@rules_file//buildifier:rules.bzl", "buildifier")
load("@rules_file//generate:rules.bzl", "format", "generate_test")

buildifier(
    name = "buildifier",
)

format(
    name = "format",
    srcs = ["@example_files//:buildifier_files"],
    formatter = ":buildifier",
    strip_prefix = "files",
)

generate_test(
    name = "test",
    generate = ":format",
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

# format
bazel run "--deleted_packages=$packages" //:format
# test
bazel run "--deleted_packages=$packages" //:test
```
