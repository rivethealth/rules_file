load("//util:path.bzl", "output_name")

def _directory_impl(ctx):
    actions = ctx.actions
    directory = ctx.attr._directory[DefaultInfo]
    label = ctx.label
    srcs = ctx.files.srcs
    output_name_ = ctx.attr.output or ctx.label.name
    strip_prefix = ctx.attr.strip_prefix

    output = actions.declare_directory(output_name_)
    args = actions.args()
    for src in srcs:
        path = output_name(file = src, label = label, strip_prefix = strip_prefix)
        args.add(src.path)
        args.add("%s/%s" % (output.path, path))
    args.set_param_file_format("multiline")
    args.use_param_file("@%s")

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

def _untar_impl(ctx):
    actions = ctx.actions
    name = ctx.attr.name
    src = ctx.file.src

    dir = actions.declare_directory(name)

    args = actions.args()
    args.add(src)
    args.add(dir.path)
    actions.run_shell(
        arguments = [args],
        command = 'mkdir -p "$2" && tar xf "$1" -C "$2"',
        inputs = [src],
        outputs = [dir],
    )

    default_info = DefaultInfo(files = depset([dir]))

    return [default_info]

untar = rule(
    attrs = {
        "src": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
    },
    doc = "Create directory from tar archive",
    implementation = _untar_impl,
)
