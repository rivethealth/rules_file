def get_path(file, prefix = "", strip_prefix = ""):
    path = file.short_path
    if path.startswith("../"):
        path = path[len("../"):]
        path = path[path.index("/") + 1:]
    if strip_prefix:
        if path == strip_prefix:
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
