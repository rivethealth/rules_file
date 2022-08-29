load("//generate:providers.bzl", "FormatterInfo")

def _gofmt(ctx, path, src, out, bin):
    ctx.actions.run_shell(
        command = 'cat "$2" | "$1" > "$3"',
        arguments = [bin.executable.path, src.path, out.path],
        inputs = [src],
        outputs = [out],
        tools = [bin],
    )

def _gofmt_impl(ctx):
    bin = ctx.attr.bin[DefaultInfo]

    def format(ctx, path, src, out):
        _gofmt(ctx, path, src, out, bin.files_to_run)

    format_info = FormatterInfo(
        fn = format,
    )

    default_info = DefaultInfo(files = depset(transitive = [bin.files]))

    return [default_info, format_info]

gofmt = rule(
    implementation = _gofmt_impl,
    attrs = {
        "bin": attr.label(
            cfg = "exec",
            default = "//gofmt:bin",
            executable = True,
        ),
    },
)
