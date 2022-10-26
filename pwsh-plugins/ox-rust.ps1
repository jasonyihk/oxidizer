##########################################################
# config
##########################################################

# config files
$Global:Element.cg = "$HOME\.cargo\env"
$Global:Element.cg_ = "$HOME\.cargo"
# backup files
$Global:Oxide.bkcg = "$env:BACKUP\rust\env.ps1"
$Global:Oxide.bkcg_ = "$env:BACKUP\rust"

if ( !(Test-Path "$env:BACKUP\rust") ) {
    New-Item -ItemType Directory -Force -Path "$env:BACKUP\rust"
}

##########################################################
# mirrors
##########################################################

function rsmr {
    param ( $mirror)
    $env:RUSTUP_DIST_SERVER = "https://$Global:Rust_Mirror.$mirror/rust-static"
    $env:RUSTUP_UPDATE_ROOT = "https://$Global:Rust_Mirror.$mirror/rust-static/rustup"
}

##########################################################
# packages
##########################################################

function cg { cargo }
function cgh { cargo help }
function cgis { cargo install $args }
function cgus { cargo uninstall $args }
function cgup { cargo update $args }
function cgcl { cargo clean }
function cgsc { cargo search $args }
function cgck { cargo check }

##########################################################
# project
##########################################################

function cgb { cargo build $args }
function cgr { cargo run $args }
function cgts { cargo test $args }
function cgpb { cargo publish $args }

function cgii {
    if ([string]::IsNullOrEmpty($args)) { cargo new $args }
    else { cargo init $args }
}

##########################################################
# rustup
##########################################################

function rsh { rustup help }
function rsis { rustup component add $args }
function rsus { rustup component remove $args }
function rsls { rustup component list }
function rsup { rustup update }
function rsck { rustup check }
function rsr { rustup run }
