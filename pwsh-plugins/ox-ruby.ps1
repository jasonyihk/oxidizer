##########################################################
# config
##########################################################

##########################################################
# packages
##########################################################

function gmh { gem help $args }
function gmis { gem install }
function gmus { gem uninstall }
function gmup { gem update }

function gmls {
    if ([string]::IsNullOrEmpty($the_env)) { gem list --local }
    else { gem list }
}

##########################################################
# project
##########################################################

function gmb { gem build }

##########################################################
# rbenv
##########################################################

