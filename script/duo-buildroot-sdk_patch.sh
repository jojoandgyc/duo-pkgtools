#!/bin/bash
# Parameter 1  duo-buildroot-sdk path , Absolute path required 
# Parameter 2  board name
my_duo_buildroot_sdk_path=$1             
my_duo_board=$2                
my_chip="my_chip"    
my_chip_series="my_chip_series"    

build_patch="./patch/build_change.patch"
fip_v2_patch="./patch/fip_v2_change.patch"
target_build_file="${my_duo_buildroot_sdk_path}/build.sh"
target_fip_v2_file="${my_duo_buildroot_sdk_path}/build/scripts/fip_v2.mk"


if [ -z "$1" ] ; then
    echo "Please provide duo_buildroot_sdk project path"
    exit 1  
fi
#  Check file exist
if [ ! -f "${build_patch}" ] && [ ! -f "${fip_v2_patch}"]; then
    echo "patch Missing"
    exit 1  
fi
if  [ ! -f "${target_build_file}" ] && [ ! -f "${target_fip_v2_file}" ] ; then
    echo "target file Missing"
    exit 1 
fi

#  Use patch
diff -q "${target_build_file}" "${target_build_file}.orig"
if [  $? -eq 0 ]; then
    echo "build_patch applied successfully"
else
    echo "Files different add patch"
    patch -p1 "${target_build_file}" "${build_patch}"
fi

diff -q "${target_fip_v2_file}" "${target_fip_v2_file}.orig"
if [ $? -eq 0 ]; then
    echo "fip_v2_patch applied successfully"
else
    echo "Files different add patch"
    patch -p1 "${target_fip_v2_file}" "${fip_v2_patch}"
fi

#  copy duo-buildroot-sdk files
if [[ -z "$my_duo_board" ]]; then
    echo "Please select board name:"
    echo " duo | duo256m | duos "
    echo "input your board name: "
    read -r my_duo_board_input 
    my_duo_board=${my_duo_board_input}
fi

# set my_chip
if [[ "$my_duo_board" == "duo" ]]; then
    my_chip="cv1800b"
    my_chip_series="cv181x"
elif [[ "$my_duo_board" == "duo256" ]]; then
    my_chip="cv1812cp"
    my_chip_series="cv181x"
elif [[ "$my_duo_board" == "duos" ]]; then
    my_chip="cv1813h"
    my_chip_series="cv181x"
else
    echo " Unknown my_duo_board type set to default duo256m "
    my_duo_board="duo256m"
    my_chip="cv1810c"
    my_chip_series="cv181x"
fi
echo "my_chip is < $my_chip > series"


# pushd ${my_duo_buildroot_sdk_path}
# bash  -i "${my_duo_buildroot_sdk_path}/build.sh"
# popd

my_fsbl_dir="../prebuilt/milkv-${my_duo_board}_sd/fsbl/"
my_opensbi_dir="../prebuilt/milkv-${my_duo_board}_sd/opensbi/"
my_uboot_dir="../prebuilt/milkv-${my_duo_board}_sd/uboot/"
# Create target directory  
mkdir -p "../prebuilt/milkv-${my_duo_board}_sd/fsbl/"
mkdir -p "../prebuilt/milkv-${my_duo_board}_sd/opensbi/"
mkdir -p "../prebuilt/milkv-${my_duo_board}_sd/uboot/"

# Copy files
current_directory=$(pwd)
cp -v  "${my_duo_buildroot_sdk_path}/fsbl/build/${my_chip}_milkv_${my_duo_board}_sd/chip_conf.bin"  "$my_fsbl_dir"
cp -v  "${my_duo_buildroot_sdk_path}/fsbl/build/${my_chip}_milkv_${my_duo_board}_sd/blmacros.env" "$my_fsbl_dir"
cp -v  "${my_duo_buildroot_sdk_path}/fsbl/build/${my_chip}_milkv_${my_duo_board}_sd/bl2.bin" "$my_fsbl_dir"
cp -v  "${my_duo_buildroot_sdk_path}/fsbl/test/empty.bin" "$my_fsbl_dir"
cp -v  "${my_duo_buildroot_sdk_path}/fsbl/test/${my_chip_series}/ddr_param.bin" "$my_fsbl_dir"
cp -v  "${my_duo_buildroot_sdk_path}/fsbl/plat/${my_chip_series}/fiptool.py" "$my_fsbl_dir"
cp -v  "${my_duo_buildroot_sdk_path}/opensbi/build/platform/generic/firmware/fw_dynamic.bin" "$my_opensbi_dir"
cp -v  "${my_duo_buildroot_sdk_path}/u-boot-2021.10/build/${my_chip}_milkv_${my_duo_board}_sd/u-boot-raw.bin" "$my_uboot_dir"
echo "Finish"