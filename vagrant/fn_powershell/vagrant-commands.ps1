# Vagrant commands
function vagre {
    param(
        [string[]]$p
    )
    $provisionWith = $p -join ","
    vagrant reload --provision-with $provisionWith
}

function reload-bashrc {
    vagre -p "reload_bashrc"
}

function vnp {
    vagrant up --no-provision
}