load("@bazel_skylib//lib:shell.bzl", "shell")
load("//util:path.bzl", "output_name", "runfile_path")

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
        execution_requirements = {"local": "1"},
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
    strip_components = ctx.attr.strip_components

    dir = actions.declare_directory(name)

    args = actions.args()
    args.add(src)
    args.add(dir.path)
    args.add(str(strip_components))
    actions.run_shell(
        arguments = [args],
        # prevent "Ignoring unknown extended header keyword"
        command = 'mkdir -p "$2" && tar xf "$1" -C "$2" --strip-components "$3" 2> /dev/null',
        execution_requirements = {"local": "1"},
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
        "strip_components": attr.int(),
    },
    doc = "Create directory from tar archive",
    implementation = _untar_impl,
)

def _unzip_impl(ctx):
    actions = ctx.actions
    name = ctx.attr.name
    src = ctx.file.src
    strip_components = ctx.attr.strip_components

    dir = actions.declare_directory(name)

    args = actions.args()
    args.add(src)
    args.add(dir.path)
    args.add(str(strip_components))
    actions.run_shell(
        arguments = [args],
        command = 'tmp="$(mktemp -d)" && unzip -q "$1" -d "$tmp" && rm -r "$2" && mv "$tmp"/%s "$2" && rm -fr "$tmp"' % "/".join(["*"] * strip_components),
        execution_requirements = {"local": "1"},
        inputs = [src],
        outputs = [dir],
    )

    default_info = DefaultInfo(files = depset([dir]))

    return [default_info]

unzip = rule(
    attrs = {
        "src": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "strip_components": attr.int(),
    },
    doc = "Create directory from ZIP archive",
    implementation = _unzip_impl,
)

def _find_packages_impl(ctx):
    actions = ctx.actions
    find_packages = ctx.executable._find_packages
    find_packages_default = ctx.attr._find_packages[DefaultInfo]
    name = ctx.attr.name
    prefix = ctx.attr.prefix
    roots = ctx.attr.roots
    runner = ctx.file._runner
    workspace = ctx.workspace_name

    executable = actions.declare_file(name)
    actions.expand_template(
        output = executable,
        substitutions = {
            "%{find_packages}": runfile_path(workspace, find_packages),
            "%{roots}": " ".join([shell.quote(root) for root in roots]),
            "%{prefix}": shell.quote(prefix),
        },
        template = runner,
    )

    runfiles = find_packages_default.default_runfiles
    default_info = DefaultInfo(
        executable = executable,
        runfiles = runfiles,
    )

    return [default_info]

find_packages = rule(
    attrs = {
        "prefix": attr.string(),
        "roots": attr.string_list(),
        "_find_packages": attr.label(
            cfg = "target",
            default = "//file/find-packages:bin",
            executable = True,
        ),
        "_runner": attr.label(
            allow_single_file = True,
            default = "find-packages-runner.sh.tpl",
        ),
    },
    executable = True,
    implementation = _find_packages_impl,
)

def _bazelrc_deleted_packages_gen_impl(ctx):
    actions = ctx.actions
    config = ctx.attr.config
    deleted_packages = ctx.executable._deleted_packages
    deleted_packages_default = ctx.attr._deleted_packages[DefaultInfo]
    label = ctx.label
    packages_default = [package[DefaultInfo] for package in ctx.attr.packages]
    output = ctx.attr.output
    if output.startswith("/"):
        output = output[len("/"):]
    elif ctx.label.package:
        output = "%s/%s" % (ctx.label.package, output)
    name = ctx.attr.name
    runner = ctx.file._runner
    workspace = ctx.workspace_name

    args = []
    if config:
        args.append("--config")
        args.append(shell.quote(config))

    executable = actions.declare_file(name)
    actions.expand_template(
        is_executable = True,
        output = executable,
        substitutions = {
            "%{args}": " ".join(args),
            "%{deleted_packages}": shell.quote(runfile_path(workspace, deleted_packages)),
            "%{commands}": "; ".join(['"$RUNFILES_DIR"/%s' % shell.quote(runfile_path(workspace, default_info.files_to_run.executable)) for default_info in packages_default]),
            "%{label}": shell.quote(str(label)),
            "%{output}": shell.quote(output),
        },
        template = runner,
    )

    runfiles = deleted_packages_default.default_runfiles
    runfiles = runfiles.merge_all([default_info.default_runfiles for default_info in packages_default])
    default_info = DefaultInfo(
        executable = executable,
        runfiles = runfiles,
    )

    return [default_info]

_bazelrc_deleted_packages_gen = rule(
    attrs = {
        "config": attr.string(),
        "output": attr.string(
            mandatory = True,
        ),
        "packages": attr.label_list(
            mandatory = True,
        ),
        "_deleted_packages": attr.label(
            cfg = "target",
            default = "//file/deleted-packages:bin",
            executable = True,
        ),
        "_runner": attr.label(
            allow_single_file = True,
            default = "deleted-packages-gen.sh.tpl",
        ),
    },
    executable = True,
    implementation = _bazelrc_deleted_packages_gen_impl,
)

def _bazelrc_deleted_packages_diff_impl(ctx):
    actions = ctx.actions
    config = ctx.attr.config
    deleted_packages = ctx.executable._deleted_packages
    deleted_packages_default = ctx.attr._deleted_packages[DefaultInfo]
    gen_label = ctx.attr.gen.label
    packages_default = [package[DefaultInfo] for package in ctx.attr.packages]
    output = ctx.attr.output
    if output.startswith("/"):
        output = output[len("/"):]
    elif ctx.label.package:
        output = "%s/%s" % (ctx.label.package, output)
    name = ctx.attr.name
    runner = ctx.file._runner
    workspace = ctx.workspace_name

    args = []
    if config:
        args.append("--config")
        args.append(shell.quote(config))

    executable = actions.declare_file(name)
    actions.expand_template(
        is_executable = True,
        output = executable,
        substitutions = {
            "%{args}": " ".join(args),
            "%{deleted_packages}": shell.quote(runfile_path(workspace, deleted_packages)),
            "%{commands}": "; ".join(['"$RUNFILES_DIR"/%s' % shell.quote(runfile_path(workspace, default_info.files_to_run.executable)) for default_info in packages_default]),
            "%{label}": shell.quote(str(gen_label)),
            "%{output}": shell.quote(output),
        },
        template = runner,
    )

    runfiles = deleted_packages_default.default_runfiles
    runfiles = runfiles.merge_all([default_info.default_runfiles for default_info in packages_default])
    default_info = DefaultInfo(
        executable = executable,
        runfiles = runfiles,
    )

    return [default_info]

_bazelrc_deleted_packages_diff = rule(
    attrs = {
        "config": attr.string(),
        "gen": attr.label(
            mandatory = True,
        ),
        "output": attr.string(
            mandatory = True,
        ),
        "packages": attr.label_list(
            mandatory = True,
        ),
        "_deleted_packages": attr.label(
            cfg = "target",
            default = "//file/deleted-packages:bin",
            executable = True,
        ),
        "_runner": attr.label(
            allow_single_file = True,
            default = "deleted-packages-diff.sh.tpl",
        ),
    },
    implementation = _bazelrc_deleted_packages_diff_impl,
    executable = True,
)

def bazelrc_deleted_packages(name, output, packages, config = None, visibility = None):
    _bazelrc_deleted_packages_gen(
        name = name,
        config = config,
        output = output,
        packages = packages,
        visibility = visibility,
    )

    _bazelrc_deleted_packages_diff(
        name = "%s.diff" % name,
        config = config,
        gen = ":%s" % name,
        output = output,
        packages = packages,
        visibility = visibility,
    )
