def _files_impl(ctx):
    ctx.file("WORKSPACE.bazel", executable = False)
    content = ctx.read(ctx.attr.build)
    ctx.file("BUILD.bazel", content = content, executable = False)
    path = ctx.path(ctx.attr.root_file).dirname
    ignore = [
        "files/bazel-%s" % path.basename,
        "files/bazel-bin",
        "files/bazel-out",
        "files/bazel-testlogs",
    ]
    ctx.file(".bazelignore", "\n".join(ignore))
    ctx.symlink(path, "files")

# def _files_impl(ctx):
#     ctx.file("WORKSPACE.bazel", executable = False)
#     content = ctx.read(ctx.attr.build)
#     ctx.file("BUILD.bazel", content = content, executable = False)
#     path = ctx.path(ctx.attr.root_file).dirname
#     for child in path.readdir():
#         print(child)
#         ctx.symlink(child, "files/%s" % child.basename)

files = repository_rule(
    implementation = _files_impl,
    attrs = {
        "build": attr.label(
            allow_single_file = True,
        ),
        "root_file": attr.label(
            doc = "A file in the root",
        ),
    },
    local = True,
)
