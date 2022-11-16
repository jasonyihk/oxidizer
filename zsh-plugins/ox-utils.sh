##########################################################
# Configuration File Utils
##########################################################

# export file
# $@=names
epf() {
    for file in $@; do
        echo "Overwrite ${OX_OXIDE[bk$file]} by ${Element[$file]}"
        if [ -z ${OX_OXIDE[bk$file]} ]; then
            echo "OX_OXIDE[bk$file] does not exist, please define it in custom.sh"
        elif [[ $file == *_ ]]; then
            rm -rf ${OX_OXIDE[bk$file]}
            cp -R -v ${Element[$file]} ${OX_OXIDE[bk$file]}
        else
            if [ ! -d $(dirname ${OX_OXIDE[bk$file]}) ]; then
                mkdir -p $(dirname ${OX_OXIDE[bk$file]})
            fi
            cp -v ${Element[$file]} ${OX_OXIDE[bk$file]}
        fi
    done
}

# import file: reverse action of `epf`
# $@=names
ipf() {
    for file in $@; do
        echo "Overwrite ${Element[$file]} by ${OX_OXIDE[bk$file]}"
        if [[ $file == *_ ]]; then
            for subfile in $(ls ${OX_OXIDE[bk$file]}); do
                cp -R -v ${OX_OXIDE[bk$file]}/$subfile ${Element[$file]}/$subfile
            done
        else
            if [ ! -d $(dirname ${Element[$file]}) ]; then
                mkdir -p $(dirname ${Element[$file]})
            fi
            cp -v ${OX_OXIDE[bk$file]} ${Element[$file]}
        fi
    done
}

# initialize file
# $@=names
iif() {
    for file in $@; do
        echo "Overwrite ${Element[$file]} by ${OX_OXYGEN[ox$file]}"
        if [ ! -d $(dirname ${Element[$file]}) ]; then
            mkdir -p $(dirname ${Element[$file]})
        fi
        cp -v ${OX_OXYGEN[ox$file]} ${Element[$file]}
    done
}

# duplicate file
# $@=names
dpf() {
    for file in $@; do
        echo "Overwrite ${OX_OXIDE[bk$file]} by ${OX_OXYGEN[ox$file]}"
        if [ ! -d $(dirname ${OX_OXIDE[bk$file]}) ]; then
            mkdir -p $(dirname ${OX_OXIDE[bk$file]})
        fi
        cp -v ${OX_OXYGEN[ox$file]} ${OX_OXIDE[bk$file]}
    done
}

##########################################################
# Gerneral File Utils
##########################################################

# refresh file
# $@=names
ff() {
    if [ -z $1 ]; then
        . ${Element[zs]}
    else
        . ${Element[$1]}
    fi
}

# browse file
# $1=name
bf() {
    if [[ $1 == *_ ]]; then
        cmd="ls"
    else
        cmd="cat"
    fi
    case $1 in
    ox[a-z]*) $cmd ${OX_OXYGEN[$1]} ;;
    bk[a-z]*) $cmd ${OX_OXIDE[$1]} ;;
    *) $cmd ${Element[$1]} ;;
    esac
}

# edit file by default editor
# $@=names
ef() {
    if [[ $2 == -t ]]; then
        cmd=$EDITOR_T
    else
        cmd=$EDITOR
    fi
    case $1 in
    ox[a-z]*) $cmd ${OX_OXYGEN[$1]} ;;
    bk[a-z]*) $cmd ${OX_OXIDE[$1]} ;;
    *) $cmd ${Element[$1]} ;;
    esac
}

##########################################################
# Zip Files
##########################################################

# $1=input-name, $2=output-name
zf() {
    local file=${1%%.*}

    if [ -z $2]; then
        local ext=zip
    else
        local ext=${2#*.}
    fi

    case $ext in
    bz | bz2)
        bzip2 -z $1
        ;;
    gz)
        gzip $1
        ;;
    tar)
        tar -cvf $1
        ;;
    tar.gz | tgz)
        tar -zcvf $1
        ;;
    tar.bz)
        tar -jcvf $1
        ;;
    tar.bz2)
        tar -jcvf $1
        ;;
    7z)
        7zz a $1
        ;;
    *)
        zip $1
        ;;
    esac
}

# $1=input-name, $2=output-name
uzf() {
    if [ -z $2]; then
        local dir=$(dirname $1)
    else
        local dir=$2
    fi

    local file=${1%%.*}
    local ext=${1#*.}
    case $ext in
    bz | bz2)
        bzip2 -d $1 $dir
        ;;
    gz)
        gzip -d $1 $dir
        ;;
    tar)
        tar -xvf $1 -C $dir
        ;;
    tar.gz | tgz)
        tar -zxvf $1 -C $dir
        ;;
    tar.bz)
        tar -jxvf $1 -C $dir
        ;;
    tar.bz2)
        tar -jxvf $1 -C $dir
        ;;
    7z)
        7zz e $1 $dir
        ;;
    *)
        unzip $1 $dir
        ;;
    esac
}

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
# OX_PROXY Utils
##########################################################

# px=proxy
px() {
    if [[ ${#1} < 3 ]]; then
        local port=$OX_PROXY[$1]
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
