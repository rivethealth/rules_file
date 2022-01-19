load("//generate:providers.bzl", "FormatterInfo")

def _black_format(ctx, path, src, out, bin):
    ctx.actions.run_shell(
        command = 'cat "$2" | "$1" -q - > "$3"',
        arguments = [bin.executable.path, src.path, out.path],
        inputs = [src],
        outputs = [out],
        tools = [bin],
    )

def _black_impl(ctx):
    bin = ctx.attr.bin[DefaultInfo]

    def format(ctx, path, src, out):
        _black_format(ctx, path, src, out, bin.files_to_run)

    format_info = FormatterInfo(
        fn = format,
    )

    default_info = DefaultInfo(files = depset(transitive = [bin.files]))

    return [default_info, format_info]

black = rule(
    implementation = _black_impl,
    attrs = {
        "bin": attr.label(
            cfg = "exec",
            default = "//pip:black",
            executable = True,
        ),
    },
)
