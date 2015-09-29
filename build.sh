#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'
clear

# Resources
THREAD="-j8"
KERNEL="zImage"
DTBIMAGE="dtb"
DEFCONFIG="ownbacon_defconfig"
device="bacon"

# Kernel Details
BASE_OWN_VER="OwnKernel-Bacon-"
VER="V1.4"
OWN_VER="$BASE_OWN_VER$VER"

# Vars
export LOCALVERSION="-$OWN_VER-$(date +%Y%m%d)"
export CROSS_COMPILE="/home/akhilnarang/UBERTC/out/arm-eabi-5.2-cortex-a15/bin/arm-eabi-"
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_HOST="blazingphoenix.in"
# Paths
OUT_DIR="/tmp/OwnKernel-bacon"
KERNEL_DIR=`pwd`
REPACK_DIR="$KERNEL_DIR/anykernel"
PATCH_DIR="$KERNEL_DIR/anykernel/patch"
ZIMAGE_DIR="$OUT_DIR/arch/arm/boot"
FINAL_ZIP="/home/akhilnarang/android/$OWN_VER-$(date +%Y%m%d).zip"
# Functions

function upload()
{
scp $1 akhilnarang,ownrom@frs.sourceforge.net:/home/frs/project/ownrom/$device/OwnKernel/
}

function make_dtb {
		anykernel/tools/dtbToolCM -2 -o $OUT_DIR/arch/arm/boot/dt.img -s 2048 -p $OUT_DIR/scripts/dtc/ $OUT_DIR/arch/arm/boot/
}
function clean_all {
		make clean && make mrproper
		make clean mrproper O=$OUT_DIR
		rm -rf /tmp/OwnKernel-bacon
		mkdir -p /tmp/OwnKernel-bacon
}

function make_kernel {
		mount -t tmpfs -o size=3072M tmpfs /tmp/OwnKernel-bacon
		make $DEFCONFIG O=$OUT_DIR
		DATE_START=$(date +"%s")
		make -j8 O=$OUT_DIR
		DATE_END=$(date +"%s")
		DIFF=$(($DATE_END - $DATE_START))
		echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 $FINAL_ZIP *
		cd $KERNEL_DIR
		while read -p "Do you want to upload zip (y/n)? " uchoice
		do
		case "$uchoice" in
		        y|Y )
		                upload $FINAL_ZIP
		                break
		                ;;
		        n|N )
		                break
		                ;;
		        * )
		                echo
		                echo "Invalid try again!"
		                echo
		                ;;
		esac
		done
}



echo -e "${red}"; echo -e "${blink_red}"; echo "$AK_VER"; echo -e "${restore}";

echo -e "${green}"
echo "-----------------"
echo "Making OwnKernel:"
echo "-----------------"
echo -e "${restore}"

case "$1" in
clean|cleanbuild)
clean_all
make_kernel
make_dtb
if [ -e "$OUT_DIR/arch/arm/boot/zImage" ]; then
make_zip
else
echo -e "Error Occurred"
echo -e "zImage not found"
fi
;;
dirty)
make_kernel
make_dtb
if [ -e "$OUT_DIR/arch/arm/boot/zImage" ]; then
make_zip
else
echo -e "Error Occurred"
echo -e "zImage not found"
fi
;;
*)
while read -p "Do you want to clean stuff (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_kernel
		make_dtb
		if [ -e "$OUT_DIR/arch/arm/boot/zImage" ]; then
		make_zip
		fi
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done
;;
esac
echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."

umount /tmp/OwnKernel-bacon

