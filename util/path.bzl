def output_name(label, file, strip_prefix = "", prefix = ""):
    path = file.short_path
    if path.startswith("../"):
        path = "/".join(path.split("/")[2:])
    if strip_prefix.startswith("/"):
        strip_prefix = strip_prefix[len("/"):]
    elif label.package:
        strip_prefix = "%s/%s" % (label.package, strip_prefix) if strip_prefix else label.package

    if not strip_prefix:
        pass
    elif path == strip_prefix:
        path = ""
    elif path.startswith(strip_prefix + "/"):
        path = path[len(strip_prefix + "/"):]
    else:
        fail("File %s does not have prefix %s" % (path, strip_prefix))

    if prefix:
        path = "%s/%s" % (prefix, path) if path else prefix
    return path

def runfile_path(workspace, file):
    path = file.short_path
    if path.startswith("../"):
        path = path[len("../"):]
    else:
        path = "%s/%s" % (workspace, path)
    return path
