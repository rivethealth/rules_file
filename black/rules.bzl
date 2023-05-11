load("@rules_python//python:defs.bzl", "py_binary")
load("//generate:providers.bzl", "FormatterInfo")

def configure_black(name, dep = "@rules_file_pip_black//:pkg", options = [], visibility = None):
    black(
        name = name,
        bin = ":%s.bin" % name,
        black_options = options,
        visibility = visibility,
    )

    py_binary(
        name = "%s.bin" % name,
        srcs = ["@rules_file//black/format:src"],
        main = "black/format/src/__main__.py",
        deps = [
            "@rivet_bazel_util//python/worker:py",
            "@rules_file_pip_setproctitle//:pkg",
            dep,
        ],
        visibility = ["//visibility:private"],
    )

def _black_format(ctx, src, out, bin, black_options):
    args = ctx.actions.args()
    args.set_param_file_format("multiline")
    args.use_param_file("@%s", use_always = True)
    args.add_all(black_options, format_each = "--black-option=%s")
    args.add(src)
    args.add(out)
    ctx.actions.run(
        arguments = [args],
        executable = bin.executable,
        execution_requirements = {
            "requires-worker-protocol": "json",
            "supports-workers": "1",
        },
        inputs = [src],
        outputs = [out],
        tools = [bin],
    )

def _black_impl(ctx):
    bin = ctx.attr.bin[DefaultInfo]
    black_options = ctx.attr.black_options

    def format(ctx, path, src, out):
        _black_format(ctx, src, out, bin.files_to_run, black_options)

    format_info = FormatterInfo(fn = format)

    return [format_info]

black = rule(
    implementation = _black_impl,
    attrs = {
        "black_options": attr.string_list(
            doc = "Black options.",
        ),
        "bin": attr.label(
            cfg = "exec",
            executable = True,
            mandatory = True,
        ),
    },
)
