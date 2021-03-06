load("//generate:providers.bzl", "FormatterInfo")

def _buildifier_format(ctx, path, src, out, bin):
    ctx.actions.run_shell(
        command = 'cp "$2" "$3" && "$1" "$3"',
        arguments = [bin.executable.path, src.path, out.path],
        inputs = [src],
        outputs = [out],
        tools = [bin],
    )

def _buildifier_impl(ctx):
    bin = ctx.attr.bin[DefaultInfo]

    def format(ctx, path, src, out):
        _buildifier_format(ctx, path, src, out, bin.files_to_run)

    format_info = FormatterInfo(
        fn = format,
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
