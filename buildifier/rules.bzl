load("//generate:providers.bzl", "FormatterInfo")

def _buildifier_fn(ctx, path, src, out, bin):
    ctx.actions.run_shell(
        command = 'cp "$2" "$3" && "$1" "$3"',
        arguments = [bin.executable.path, src.path, out.path],
        inputs = [src],
        outputs = [out],
        tools = [bin],
    )

def _buildifier_impl(ctx):
    bin = ctx.attr.bin[DefaultInfo]

    format_info = FormatterInfo(
        fn = _buildifier_fn,
        args = [bin.files_to_run],
    )

    default_info = DefaultInfo(files = depset(transitive = [bin.files]))

    return [default_info, format_info]

buildifier = rule(
    implementation = _buildifier_impl,
    attrs = {
        "bin": attr.label(
            cfg = "exec",
            default = "@com_github_bazelbuild_buildtools//buildifier",
            doc = "Buildifier",
            executable = True,
        ),
    },
)
