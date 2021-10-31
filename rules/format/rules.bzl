load("@bazel_skylib//lib:shell.bzl", "shell")
load(":providers.bzl", "FormatInfo")

def _format_impl(ctx):
    formatter = ctx.attr.formatter[FormatInfo]
    prefix = ctx.attr.prefix + "/"

    script = ""
    outputs = []
    for src in ctx.files.srcs:
        if not src.path.startswith(prefix):
            fail("File %s not in %s" % (src.path, prefix))
        formatted = ctx.actions.declare_file("%s/src/%s" % (ctx.label.name, src.path))
        script += "format %s %s \n" % (src.path[len(prefix):], formatted.path)
        outputs.append(formatted)

        formatter.fn(ctx, src, formatted, *formatter.args)

    bin = ctx.actions.declare_file("%s/bin" % ctx.label.name)
    ctx.actions.expand_template(
        template = ctx.file._runner,
        output = bin,
        substitutions = {"%{files}": script},
    )

    default_info = DefaultInfo(
        executable = bin,
        runfiles = ctx.runfiles(files = outputs),
    )
    return [default_info]

format = rule(
    attrs = {
        "formatter": attr.label(
            mandatory = True,
            providers = [FormatInfo],
        ),
        "prefix": attr.string(
            mandatory = True,
        ),
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
        "_runner": attr.label(
            allow_single_file = True,
            default = "runner.sh.tpl",
        ),
    },
    executable = True,
    implementation = _format_impl,
)
