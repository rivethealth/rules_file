load("@rules_file_pip//:requirements.bzl", "install_deps")

def file_repositories():
    install_deps()
