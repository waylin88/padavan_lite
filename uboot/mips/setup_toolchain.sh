#!/bin/bash
#
# Prepare the vendor 32-bit MIPS toolchains used to build U-Boot.
#
#   RT3XXX / MT7620 / MT7628 : tools/buildroot-gcc342.tar.bz2
#   MT7621                   : tools/mips-2012.03.tar.bz2
#
# Both toolchains are 32-bit x86 executables.  They are extracted under
# /opt (the path hard-coded in the profiles via CONFIG_CROSS_COMPILER_PATH).
# On hosts without IA32 support each executable is replaced by a tiny shell
# wrapper that forwards to qemu-i386-static, so the (32-bit) compiler can
# still launch its own sub-processes (cc1 / as / ld) transparently.
#
# The script is idempotent: already extracted / already wrapped files are
# left untouched.
#
set -e

BASE=$(cd "$(dirname "$0")" && pwd)
TOOLS="$BASE/tools"
OPT="${UBOOT_TOOLCHAIN_PREFIX:-/opt}"

extract() {
	local tarball="$1" dir="$2"
	if [ -d "$OPT/$dir" ]; then
		echo "-- $OPT/$dir already present, skip extract"
		return 0
	fi
	echo "-- extracting $tarball -> $OPT/$dir"
	mkdir -p "$OPT"
	tar -xf "$TOOLS/$tarball" -C "$OPT"
}

wrap_tree() {
	local root="$1" bin
	[ -d "$root" ] || return 0
	while IFS= read -r bin; do
		# Skip the originals we renamed ourselves and anything already wrapped.
		case "$bin" in *.real) continue ;; esac
		[ -x "$bin" ] || continue
		# An already-generated wrapper starts with a shebang.
		if [ "$(head -c 2 "$bin" 2>/dev/null)" = "#!" ]; then
			continue
		fi
		if file -b "$bin" 2>/dev/null | grep -q 'ELF 32-bit'; then
			mv -f "$bin" "$bin.real"
			printf '#!/bin/sh\nexec %s "%s.real" "$@"\n' "$QEMU" "$bin" >"$bin"
			chmod +x "$bin"
		fi
	done < <(find "$root" -type f)
}

extract buildroot-gcc342.tar.bz2 buildroot-gcc342
extract mips-2012.03.tar.bz2 mips-2012.03

QEMU=$(command -v qemu-i386-static || true)
if [ -n "$QEMU" ]; then
	echo "-- wrapping 32-bit toolchain binaries with $QEMU"
	wrap_tree "$OPT/buildroot-gcc342"
	wrap_tree "$OPT/mips-2012.03"
else
	echo "-- qemu-i386-static not found: assuming the host can run 32-bit ELF natively"
fi

# Sanity check: the C compiler of each toolchain must be able to start.
for cc in "$OPT/buildroot-gcc342/bin/mipsel-linux-uclibc-gcc" \
          "$OPT/mips-2012.03/bin/mips-sde-elf-gcc"; do
	if [ -x "$cc" ]; then
		echo -n "-- check $cc : "
		"$cc" --version 2>/dev/null | head -n1 || echo "FAILED"
	fi
done

echo "U-Boot toolchains ready under $OPT"