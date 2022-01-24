load("@rules_python//python:pip.bzl", "pip_parse")

def file_init():
    pip_parse(
        name = "rules_file_pip",
        requirements_lock = "@rules_file//:requirements-lock.txt",
    )
