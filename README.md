# rules_file

Bazel rules for basic file operations, such as creating directories and formatting.

## Directory

Create a directory from files:

```bzl
load("@rules_file//file:rules.bzl", "directory")

directory(
    name = "example",
    srcs = glob(["**/*.txt"]),
)
```

Create a directory from a tarball:

```bzl
load("@rules_file//file:rules.bzl", "untar")

untar(
    name = "example",
    src = "example.tar",
)
```

## Package-less Files

Access files without regard to package structure. This can be helpful for formatting or Bazel integration tests.

### Workspace Example

Create a new repository containing all workspace files.

**WORKSPACE.bazel**

```bzl
files(
    name = "files"
    build = "BUILD.file.bazel",
    root_file = "//:WORKSPACE.bazel",
)
```

**BAZEL.bazel**

```
load("@rules_file//file:rules.bzl", "bazelrc_deleted_packages")

bazelrc_deleted_packages(
    name = "gen_bazelrc",
    output = "deleted.bazelrc",
    packages = ["@files//:packages"],
)
```

**files.bazel**

```bzl
# note: files is the symlink to the workspace
filegroup(
    name = "example",
    srcs = glob(["files/**/*.txt"]),
    visibility = ["//visibility:public"],
)
```

Generate deleted.bazelrc:

```
bazel run :gen_bazelrc
```

**.bazelrc**

```
import %workspace%/deleted.bazelrc
```

Now `@files//:example` is all \*.txt files in the workspace.

### Bazel Integration Test Example

Use files in the test directory as data for a Bazel integration test.

**BAZEL.bazel**

```
load("@rules_file//file:rules.bzl", "bazelrc_deleted_packages", "find_packages")

filegroup(
    name = "test",
    srcs = glob(["test/**/*.bazel" "test/**/*.txt"]),
)

find_packages(
    name = "test_packages",
    roots = ["test"],
)

bazelrc_deleted_packages(
    name = "gen_bazelrc",
    output = "deleted.bazelrc",
    packages = [":test_packages"],
)
```

Generate `deleted.bazelrc` by running:

```
bazel run :gen_bazelrc
```

**.bazelrc**

```
import %workspace%/deleted.bazelrc
```

## Generate

In some cases, it is necessary to version control build products in the workspace (bootstrapping, working with other tools).

These rules build the outputs, and copy them to the workspace or check for differences.

**BUILD.bazel**

```bzl
load("@rules_file//file:rules.bzl", "bazelrc_deleted_packages")
load("@rules_file//file:rules.bzl", "generate", "generate_test")

genrule(
    name = "example",
    cmd = "echo GENERATED! > $@",
    outs = ["out/example.txt"],
)

generate(
    name = "example_gen",
    srcs = "example.txt",
    data = ["out/example.txt"],
    data_strip_prefix = "out",
)

generate_test(
    name = "example_diff",
    generate = ":example_gen",
)

bazelrc_deleted_packages(
    name = "gen_bazelrc",
    output = "deleted.bazelrc",
    packages = ["@files//:packages"],
)
```



To overwrite the workspace file:

```bzl
bazel run :example_gen
```

To check for differences (e.g. in CI):

```bzl
bazel test :example_diff
```

## Format

Formatting is a particular case of the checked-in build products pattern.

The code formatting is a regular Bazel action. The formatted result can be using to overwrite workspace files, or to check for differences.

This repository has rules for buildifier, black, and gofmt. It is also used for [prettier](https://github.com/rivethealth/rules_javascript).

### Buildifier Example

**WORKSPACE.bazel**

```bzl
BUILDTOOLS_VERSION = "3.5.0"

http_archive(
    name = "com_github_bazelbuild_buildtools",
    sha256 = "f5b666935a827bc2b6e2ca86ea56c796d47f2821c2ff30452d270e51c2a49708",
    strip_prefix = "buildtools-%s" % BUILDTOOLS_VERSION,
    url = "https://github.com/bazelbuild/buildtools/archive/%s.zip" % BUILDTOOLS_VERSION,
)

load("@com_github_bazelbuild_buildtools//buildifier:deps.bzl", "buildifier_dependencies")

buildifier_dependencies()

files(
    name = "files"
    build = "BUILD.file.bazel",
    root_file = "//:WORKSPACE.bazel",
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
    name = "buildifier_format",
    srcs = ["@files//:buildifier_files"],
    formatter = ":buildifier",
    strip_prefix = "files",
)

generate_test(
    name = "buildifier_diff",
    generate = ":format",
)
```

**files.bazel**

```bzl
filegroup(
    name = "buildifier_files",
    srcs = glob(
        [
            "files/**/*.bazel",
            "files/**/*.bzl",
            "files/**/BUILD",
            "files/**/WORKSPACE",
        ],
    ),
    visibility = ["//visibility:public"],
)
```

Generate deleted.bazelrc:

```
bazel run :gen_bazelrc
```

**.bazelrc**

```
import %workspace%/deleted.bazelrc
```

To format:

```sh
bazel run :buildifier_format
```

To check format:

```sh
bazel run :buildifier_diff
```
