# If a file ~/.mysql/$1.cnf exists, call mysql(1) using that file. Otherwise
# just run MySQL with given args. Use restrictive permissions on these files.
# Examples:
#
#   [client]
#   host=dbhost.example.com
#   user=foo
#   database=bar
#   password=SsJ2pICe226jM
#
mysql() {
    local config
    config=$HOME/.mysql/$1.cnf
    if [[ -r $config ]] ; then
        shift
        command mysql --defaults-extra-file="$config" "$@"
    else
        command mysql "$@"
    fi
}

# Completion setup for MySQL for configured databases
_mysql() {
    local word
    word=${COMP_WORDS[COMP_CWORD]}

    # Check directory exists and has at least one .cnf file
    local dir
    dir=$HOME/.mysql
    if [[ ! -d $dir ]] || (
        shopt -s nullglob dotglob
        declare -a files=("$dir"/*.cnf)
        ((! ${#files[@]}))
    ) ; then
        return 1
    fi

    # Return the names of the .cnf files sans prefix as completions
    local -a items
    items=("$dir"/*.cnf)
    items=("${items[@]##*/}")
    items=("${items[@]%%.cnf}")
    COMPREPLY=( $(compgen -W "${items[*]}" -- "$word") )
}
complete -F _mysql -o default mysql

