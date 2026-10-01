# mylar3-patched

A thin Docker image that layers GetComics DDL fixes on top of
`linuxserver/mylar3:latest`.

## What it fixes

GetComics.org is protected by Cloudflare and changed their page structure,
breaking Mylar's DDL search in multiple ways. This patch addresses:

### 1. FlareSolverr cookie domain (root cause of "No valid items")
Mylar's `cookie_receipt()` loaded FlareSolverr cookies without their domain,
so Python's `requests` never sent the `cf_clearance` cookie. Fixed by
passing `domain=c.get('domain')` when setting cookies.

### 2. FlareSolverr page fetch
Even with valid cookies, Cloudflare validates TLS fingerprints that
python-requests cannot spoof. When FlareSolverr is enabled, `loadsite()`
now fetches detail pages via FlareSolverr's `request.get` instead of direct
`session.get()`.

### 3. New page structure (aio-pulse fallback)
GetComics moved download links from `<p style="text-align: center;">`
elements to `<section><div class="aio-button-center"><div class="aio-pulse">`.
Added a fallback that directly extracts links from `aio-pulse` divs when
the legacy beeswax parsing finds nothing.

### 4. `/dls/` interstitial link resolution
GetComics routes download links through `/dls/` URLs that 302-redirect to
file hosts with obfuscated `Location` headers. Added `_resolve_dls_link()`
which uses FlareSolverr to follow the redirect (the endpoint is also
Cloudflare-protected) and returns the real file-host URL.

Also fixes a case-sensitivity bug where "READ ONLINE" section detection
compared against `'Read Online'` exactly.

## Configuration

Enable FlareSolverr in Mylar's config.ini:
```ini
[FlareSolverr]
enable_flaresolverr = True
flaresolverr_url = http://flaresolverr:8191/v1
```

## Image

`ghcr.io/brazimus/mylar3:patched` — rebuilt on every push to `main`
and weekly on Sundays to track upstream `linuxserver/mylar3:latest`.

## Usage

Point your Mylar3 container at `ghcr.io/brazimus/mylar3:patched`
instead of `ghcr.io/linuxserver/mylar3:latest`. All volumes, ports,
and environment variables are identical.

## Verification

Tested 2026-10-01: successfully searched, resolved, downloaded, and
post-processed Alien vs. X-Men #1 (2026) via GetComics DDL.
