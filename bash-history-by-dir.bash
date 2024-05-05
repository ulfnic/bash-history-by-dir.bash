

# Example .bashrc implementation:
#
#	bash_history_by_dir__root=$HOME'/.local/share/bash-history-by-dir'
#	source $HOME/.local/bin/bash-history-by-dir.bash
#	bind -x '"\e[1;3B":"bash_history_by_dir__fzf"'  # Alt + down



bash_history_by_dir__prompt_write() {
	if [[ ! -t 0 ]]; then
		printf '%s\n' 'ERROR, bash_history_by_dir__prompt_write(): not a terminal session.' 1>&2
		return 1
	fi
	local str=$*
	str=${str//\\/\\\\}
	str=${str//\"/\\\"} #"
	bind '"\e[0n":"'"$str"'"'
	printf '\e[5n'
}



bash_history_by_dir__fzf() {
	local cmd
	bash_history_by_dir__set_log_path
	if [[ -f $bash_history_by_dir__log_path ]]; then
		cmd=$( fzf --no-sort --prompt='history: ' --tac --read0 < "$bash_history_by_dir__log_path" )
	else
		cmd=$( fzf <<< '' )
	fi
	[[ $cmd ]] && bash_history_by_dir__prompt_write "$cmd"
}



bash_history_by_dir__set_log_path() {
	if [[ $PWD != bash_history_by_dir__current ]]; then
		bash_history_by_dir__current=$PWD
		local sum=$(printf '%s' "$PWD" | md5sum)
		sum=${sum%% *}
		bash_history_by_dir__log_path=$bash_history_by_dir__root'/'$sum
	fi
}



bash_history_by_dir__add() {
	[[ $BASH_COMMAND == ' '* ]] && return 0
	[[ $BASH_COMMAND == 'bash_history_by_dir__'* ]] && return 0
	bash_history_by_dir__set_log_path
	printf '%s\0' "$BASH_COMMAND" >> "$bash_history_by_dir__log_path"
}



bash_history_by_dir__init(){
	# Declare locals
	local trap_str

	# Clear globals
	bash_history_by_dir__current=
	bash_history_by_dir__log_path=

	# Create log dir
	[[ -d $bash_history_by_dir__root ]] || mkdir -- "$bash_history_by_dir__root"

	# Append bash_history_by_dir__add to DEBUG trap
	trap_str=$(trap -p DEBUG)
	trap_str=${trap_str:8}
	trap_str=${trap_str% *}
	eval "trap_str=${trap_str}"
	trap -- "$trap_str"$'\n\nbash_history_by_dir__add' DEBUG
}



[[ $bash_history_by_dir__root ]] && bash_history_by_dir__init



