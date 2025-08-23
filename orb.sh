#!/bin/bash

usage() {
	echo "Usage: orb -b SOURCE_DIR DESTINATION_DIR"
	echo "       orb -r BACKUP_DIR RESTORE_DIR"
	echo "-b Perform a backup from SOURCE_DIR to DESTINATION_DIR"
	echo "-r Restore data from BACKUP_DIR to RESTORE_DIR"
	echo "-v Show version"
	echo "-h Display this help message"
}

backup() {
	# 参数列表
	local dir_source="$1"
	local dir_dest="$2"

	if [ ! -d "$dir_source" ];then 
		echo "source is no such or directory"
		exit 1
	fi

	if [ ! -d "$dir_source" ];then 
		echo "dest is no such or directory"
		exit 1
	fi


	for i in {0..9}; do
		if [ ! -d $dir_dest/$i ]; then
			next=$i;
			let pre=0;
			if [ $next -gt 0 ]; then
				let pre=i-1;
			fi
			break;
		fi;
	done;


	link=""
	if [ $next -gt $pre ]; then
		link=" --link-dest=$dir_dest/$pre "
	fi;

	# 执行 Rsync 永远把数据落地到 $next 目录中
	rsync -avl --delete --progress $link $dir_source/* $dir_dest/$next/


	# 执行轮转
	if [ $next -eq 9 ]; then

		rm -rf $dir_dest/0;

		# 因为 0 被删除了，所以选择1-9的目录把序号前移
		# 这时候 9就变成了8，在8号目录下永远是最新的一次备份
		for i in {1..9}; do
			let n=i-1;
			mv $dir_dest/$i $dir_dest/$n;
		done;
	fi;

}

restore() {
	local dir_source="$1"
	local dir_dest="$2"
	local dir_index=""

	if [ ! -d "$dir_source" ];then 
		echo "source is no such or directory"
		exit 1
	fi

	if [ ! -d "$dir_source" ];then 
		echo "dest is no such or directory"
		exit 1
	fi

	# 如果未选择目录编号，则自动选择最新的目录
	if [ -n $dir_index ]; then
		for i in {0..9}; do
			if [ ! -d $i ]; then
				next=$i;
				dir_index="0";
				if [ $next -gt 0 ]; then
					let dir_index=i-1
				fi
				break;
			fi;
		done;

	fi

	rsync -avl --delete --progress $dir_source/$dir_index/* $dir_dest

}

version() {
	echo "v1.0.7"
}

upgrade() {
	echo "Upgrading..."
	installFile="/usr/local/bin/orb.sh"
	latestFile="https://github.com/xjqxz2/orb/releases/latest/download/orb.sh"
	curl -sS -o $installFile $latestFile 
	chmod +x $installFile
	echo "Upgrade ok!"
}

while getopts "b:r:vu" opt; do
	case ${opt} in
		b)
			SOURCE_DIR="$2"
			DEST_DIR="$3"

			# 当输入的目录都不为空时生效
			if [ -n "$SOURCE_DIR" ] && [ -n "$DEST_DIR" ]; then
				backup "$SOURCE_DIR" "$DEST_DIR"
				exit 0
			fi
			;;
		r)
			DEST_DIR="$2"
			SOURCE_DIR="$3"
			INDEX="$4"

			if [ -n "$SOURCE_DIR" ] && [ -n "$DEST_DIR" ]; then
				restore "$DEST_DIR" "$SOURCE_DIR" "$INDEX"
				exit 0
			fi
			;;
		v)
			version
			exit 0
			;;
		u)
			upgrade
			exit 0
			;;
	esac	
done

usage
