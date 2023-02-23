##########################################################
# Configuration File Utils
##########################################################

# export file
# $@=names
epf() {
    for file in $@; do
        local in_path=${OX_ELEMENT[$file]}
        local out_path=${OX_OXIDE[bk$file]}

        if [[ -z $out_path ]]; then
            echo "OX_OXIDE[bk$file] does not exist, please define it in custom.sh"
        elif [[ $file == *_ ]]; then
            rm -rf $out_path
            cp -R -v $in_path $out_path
        else
            if [[ ! -d $(dirname $out_path) ]]; then
                mkdir -p $(dirname $out_path)
            fi
            cp -v $in_path $out_path
        fi
    done
}

# import file: reverse action of `epf`
# $@=names
ipf() {
    for file in $@; do
        local in_path=${OX_OXIDE[bk$file]}
        local out_path=${OX_ELEMENT[$file]}

        if [[ $file == *_ ]]; then
            rm -rf $out_path
            cp -R -v $in_path $out_path
        else
            if [[ ! -d $(dirname $out_path) ]]; then
                mkdir -p $(dirname $out_path)
            fi
            cp -v $in_path $out_path
        fi
    done
}

# initialize file
# $@=names
iif() {
    for file in $@; do
        local in_path=${OX_OXYGEN[ox$file]}
        local out_path=${OX_ELEMENT[$file]}

        if [[ ! -d $(dirname $out_path) ]]; then
            mkdir -p $(dirname $out_path)
        fi
        cp -v $in_path $out_path
    done
}

# duplicate file
# $@=names
dpf() {
    for file in $@; do
        local in_path=${OX_OXYGEN[ox$file]}
        local out_path=${OX_OXIDE[bk$file]}

        if [[ ! -d $(dirname $out_path) ]]; then
            mkdir -p $(dirname $out_path)
        fi
        cp -v ${OX_OXYGEN[ox$file]} ${OX_OXIDE[bk$file]}
    done
}

##########################################################
# Gerneral File Utils
##########################################################

# refresh file
# $@=names
frf() {
    if [[ -z $1 ]]; then
        . ${OX_ELEMENT[zs]}
    else
        . ${OX_ELEMENT[$1]}
    fi
}

# browse file
# $1=name
brf() {
    if [[ $1 == *_ ]]; then
        cmd="ls"
    else
        cmd="cat"
    fi
    case $1 in
    ox[a-z]*) $cmd ${OX_OXYGEN[$1]} ;;
    bk[a-z]*) $cmd ${OX_OXIDE[$1]} ;;
    *) $cmd ${OX_ELEMENT[$1]} ;;
    esac
}

# edit file by default editor
# $@=names
edf() {
    if [[ $2 == -t ]]; then
        cmd=$EDITOR_T
    else
        cmd=$EDITOR
    fi
    case $1 in
    ox[a-z]*) $cmd ${OX_OXYGEN[$1]} ;;
    bk[a-z]*) $cmd ${OX_OXIDE[$1]} ;;
    *) $cmd ${OX_ELEMENT[$1]} ;;
    esac
}

##########################################################
# Zip Files
##########################################################

zpf="ouch compress"
uzpf="ouch decompress"
lzpf="ouch list"

##########################################################
# Hash Files
##########################################################

alias sha1="sha1sum"
alias sha2="sha256sum"
alias sha5="sha512sum"

##########################################################
# Batch Management
##########################################################

# $1=old, $2=new, $3=path
replace() {
    sd "$1" "$2" $(fd "$3")
}

# $1=old, $2=new
rename() {
    fd "$1" | while read file; do
        new=$(echo $file | sd "$1" "$2")
        mv $file $new
    done
}

##########################################################
# Proxy Utils
##########################################################

# px=proxy
px() {
    if [[ ${#1} < 3 ]]; then
        local port=${OX_PROXY[$1]}
    else
        local port=$1
    fi
    echo "using port $port"
    export https_proxy=http://127.0.0.1:$port
    export http_proxy=http://127.0.0.1:$port
    export all_proxy=socks5://127.0.0.1:$port
}

pxq() {
    echo 'unset all proxies'
    unset https_proxy
    unset http_proxy
    unset all_proxy
}
