import sys
from black import patched_main

sys.argv[0] = "black"
sys.exit(patched_main())
