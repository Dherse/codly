# Documentation site

From the repository root:

```sh
just docs-setup
just docs-dev          # http://127.0.0.1:8001
just docs-check
just docs-build        # output: docs/book/
just docs-serve
just docs-site         # assemble docs/.site/ with version navigation
just docs-serve-site
just docs-deploy       # dispatch the Pages workflow on main; requires gh login
```

Add pages under `src/` and list them in `src/SUMMARY.md`.
Builds use Codly directly from the parent checkout.
Third-party runtime and font assets are pinned submodules; `just docs-setup`
initializes them. For a fresh clone, use `git clone --recurse-submodules`.

## Deployment

The source workflow publishes generated files to the `gh-pages` branch of
[Dherse/codly.github.io](https://github.com/Dherse/codly.github.io).

1. Create a fine-grained personal access token restricted to `Dherse/codly.github.io`,
   with **Contents: Read and write**.
2. In `Dherse/codly`, add it as the Actions secret `DOCS_DEPLOY_TOKEN`.
3. Merge the workflow into `main`. Its push publishes the first build; use
   `just docs-deploy` to run it manually.
4. After `gh-pages` exists, in `Dherse/codly.github.io` select
   **Settings → Pages → Source → Deploy from a branch → gh-pages → /(root)**.

The default Pages URL is `https://dherse.github.io/codly.github.io/`.
This is a project site because the repository owner is `Dherse`.
All site links are relative, so a later custom domain needs no URL rewrite.

Main pushes update `/main/`. The release workflow builds `/vX.Y.Z/` after validation.
Missing release tags from `initialVersion` onward are also backfilled automatically.
The hosting branch retains published versions across deployments.

`site.json` sets the default version. `"latest"` opens the highest published stable
release; replace it with a tag such as `"v2.0.0"` to pin the landing site.
`initialVersion` seeds the first release from main only when its package version
matches and no archive exists. The actual release tag rebuilds that snapshot.

To backfill an existing tag, run **Deploy documentation** with `release_ref` set
to that tag. Tags without the site scaffold use the current scaffold and their
own Codly source. Later tags use their own documentation and runtime.
