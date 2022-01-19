import os
import os.path
import shutil
import sys

for i in range(1, len(sys.argv), 2):
  input = sys.argv[i]
  output = sys.argv[i + 1]
  os.makedirs(os.path.dirname(output), exist_ok=True)
  shutil.copy(input, output)
