#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="zImage"
DTBIMAGE="dtb"
DEFCONFIG="ownbacon_defconfig"
device="bacon"

# Kernel Details
BASE_OWN_VER="OwnKernel-Bacon-"
VER="V1.0"
OWN_VER="$BASE_OWN_VER$VER"

# Vars
export LOCALVERSION=~`echo $OWN_VER`
export CROSS_COMPILE="/home/akhil/android/arm-eabi-6.0/bin/arm-eabi-"
export ARCH=arm
export SUBARCH=arm

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="$KERNEL_DIR/anykernel"
PATCH_DIR="$KERNEL_DIR/anykernel/patch"
ZIP_MOVE="/home/akhil/android/OwnKernel/$device"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm/boot"

# Functions

function make_dtb {
		$REPACK_DIR/tools/dtbToolCM -2 -o $REPACK_DIR/$DTBIMAGE -s 2048 -p scripts/dtc/ arch/arm/boot/

}
function clean_all {
		cd $REPACK_DIR
		rm -rf $KERNEL
		rm -rf $DTBIMAGE
		git reset --hard > /dev/null 2>&1
		git clean -f -d > /dev/null 2>&1
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 ~/android/OwnKernel_$device-$OWN_VER.zip *
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")

echo "---------------"
echo "Kernel Version:"
echo "---------------"

echo -e "${red}"; echo -e "${blink_red}"; echo "$AK_VER"; echo -e "${restore}";

echo -e "${green}"
echo "-----------------"
echo "Making OwnKernel:"
echo "-----------------"
echo -e "${restore}"

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
		make_zip
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

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo

