scene-detect() {
    ffmpeg -i "$1" -vf "select='gte(scene,${2:-0.02})',metadata=print" -an -f null - 2>&1
}

chrome-youtube-dl() {
    youtube-dl --cookies-from-browser chrome "$@"
}
