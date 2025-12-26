#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p "python3.withPackages (ps: [ps.scramp])"
import scramp, base64
from getpass import getpass

PASSWORD = getpass()

m = scramp.ScramMechanism()
salt, stored_key, server_key, iteration_count = m.make_auth_info(PASSWORD)
print(f"SCRAM-SHA-256${iteration_count}:{base64.b64encode(salt).decode()}${base64.b64encode(stored_key).decode()}:{base64.b64encode(server_key).decode()}")
