function upload () {
    local source="$(pwd)/${1}";
    local target="${remoteUser}@${remoteIP}:${remotePath}/${1}";
    echo "upload ${source} to ${target}"
    scp -r $source $target
}

function download () {
    local source="${remoteUser}@${remoteIP}:${1}";
    local target="$(pwd)";
    echo "download ${source} to ${target}"
    scp -r $source $target
}