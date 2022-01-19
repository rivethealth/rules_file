load("//util:path.bzl", "get_path")

def _directory_impl(ctx):
    actions = ctx.actions
    directory = ctx.attr._directory[DefaultInfo]
    srcs = ctx.files.srcs
    output_name = ctx.attr.output or ctx.label.name
    strip_prefix = ctx.attr.strip_prefix

    output = actions.declare_directory(output_name)
    args = actions.args()
    for src in srcs:
        path = get_path(src, strip_prefix = strip_prefix)
        args.add(src)
        args.add("%s/%s" % (output.path, path))

    actions.run(
        arguments = [args],
        executable = directory.files_to_run.executable,
        inputs = srcs,
        outputs = [output],
        tools = [directory.files_to_run],
    )

    default_info = DefaultInfo(files = depset([output]))

    return [default_info]

directory = rule(
    attrs = {
        "_directory": attr.label(
            cfg = "exec",
            default = ":directory",
            executable = True,
        ),
        "srcs": attr.label_list(
            allow_files = True,
        ),
        "strip_prefix": attr.string(),
        "output": attr.string(),
    },
    implementation = _directory_impl,
)
