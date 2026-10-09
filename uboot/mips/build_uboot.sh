#!/bin/sh
#
# Non-interactive Ralink/MediaTek U-Boot builder.
#
# Usage:
#   ./build_uboot.sh <profile> [<profile> ...]
#   ./build_uboot.sh all
#
# Each <profile> is a directory name under ./profiles that contains a .config
# (e.g. profiles/ZY-L1/.config).  The build result (uboot.bin / uboot.img) and
# its checksum are written back into that profile directory.
#
# The 32-bit vendor toolchains are expected under /opt
# (buildroot-gcc342 for RT3XXX/MT7620/MT7628, mips-2012.03 for MT7621).
# On hosts without IA32 support they are executed through qemu-i386-static.
#
set -e

BASE=$(cd "$(dirname "$0")" && pwd)
SRC="$BASE/uboot-5.x.x.x"
PROFILES="$BASE/profiles"

# Make sure the vendor toolchains are extracted (and runnable) under /opt.
bash "$BASE/setup_toolchain.sh"

build_one() {
	name="$1"
	cfg="$PROFILES/$name/.config"

	if [ ! -f "$cfg" ]; then
		echo "!! profile not found: $cfg"
		return 1
	fi

	echo ""
	echo "==================== U-Boot: $name ===================="

	cp -f "$cfg" "$SRC/.config"

	log="$BASE/.build-$name.log"
	# Drop stale objects from a previous profile, regenerate .config/autoconf.h
	# from config.in using the profile as defaults, then compile.
	# scripts/Configure -d runs fully non-interactive.
	if (
		cd "$SRC" &&
		make clean >/dev/null 2>&1 &&
		bash scripts/Configure -d config.in >/dev/null &&
		mv -f .tmpconfig.h autoconf.h &&
		make
	) >"$log" 2>&1; then
		:
	else
		echo "-- build FAILED ($name), last lines:"
		tail -n 25 "$log"
		return 1
	fi

	# Collect produced images.
	found=""
	for img in uboot.img uboot.bin; do
		if [ -f "$SRC/$img" ]; then
			cp -f "$SRC/$img" "$PROFILES/$name/$img"
			( cd "$PROFILES/$name" && md5sum "$img" > uboot.md5 )
			echo "-- $name -> $img ($(stat -c %s "$PROFILES/$name/$img") bytes)"
			found="$found $img"
		fi
	done

	if [ -z "$found" ]; then
		echo "!! build produced no image for $name"
		return 1
	fi
	return 0
}

if [ "$#" -eq 0 ]; then
	echo "usage: $0 <profile> [<profile> ...] | all"
	exit 1
fi

if [ "$1" = "all" ]; then
	set -- $(ls -1 "$PROFILES")
fi

rc=0
for name in "$@"; do
	build_one "$name" || rc=1
done

echo ""
if [ "$rc" -eq 0 ]; then
	echo "All requested U-Boot images built successfully."
else
	echo "Some U-Boot builds failed."
fi
exit "$rc"