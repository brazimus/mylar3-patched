# Thin patch layer on top of linuxserver/mylar3.
# Overlays a fixed getcomics.py that resolves GetComics /dls/ interstitial
# redirect links (which return obfuscated Location headers).
FROM ghcr.io/linuxserver/mylar3:latest

COPY mylar/getcomics.py /app/mylar3/mylar/getcomics.py
