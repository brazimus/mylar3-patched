# mylar3-patched

A thin Docker image that layers a GetComics DDL fix on top of
`linuxserver/mylar3:latest`.

## What it fixes

GetComics.org changed their download links to route through `/dls/`
interstitial URLs that return obfuscated `Location` headers on redirect.
Mylar's `getcomics.py` scraper doesn't resolve these, so every DDL search
finds releases but gathers zero downloadable links ("No valid items
available that I am able to download from").

This patch adds a `_resolve_dls_link` method that follows the 302 with
redirects disabled, de-obfuscates the `Location` header (the path portion
is intact; only the domain is garbled), and reconstructs the real
file-host URL using the known domain for the link's site title.

It also fixes a case-sensitivity bug where the "READ ONLINE" section
detection compared against `'Read Online'` exactly.

## Image

`ghcr.io/brazimus/mylar3:patched` — rebuilt on every push to `main`
and weekly on Sundays to track upstream `linuxserver/mylar3:latest`.

## Usage

Point your Mylar3 container at `ghcr.io/brazimus/mylar3:patched`
instead of `ghcr.io/linuxserver/mylar3:latest`. All volumes, ports,
and environment variables are identical.
