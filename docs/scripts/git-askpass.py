#!/usr/bin/env python3
"""Provide the hosting repository token to Git's credential prompt."""
import os
import sys

prompt = sys.argv[1].lower()
if "username" in prompt:
    print("x-access-token")
elif "password" in prompt:
    print(os.environ["DOCS_DEPLOY_TOKEN"])
else:
    raise SystemExit("Unexpected Git credential prompt")
