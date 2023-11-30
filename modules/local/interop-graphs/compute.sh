#!/bin/bash

command_name=''
input_name=''
output_name=''
width=''
height=''
dpi=''

while (( $# >= 1 )); do 
    case $1 in
    --command-name) command_name=$2;;
    --input-name) input_name=$2;;
    --output-name) output_name=$2;; 
    --width) width=$2;;
    --height) height=$2;;
    --dpi) dpi=$2;;
    *) break;
    esac;
    shift 2
done

in2mm=25.4
pt2mm=0.3528

mm2px=$(echo "scale=4; $dpi / $in2mm" | bc -l)
ptscale=$(echo "scale=4; $pt2mm * $mm2px" | bc -l)

# Round function
# Round function
round() {
	local x=$1
	echo "($x + 0.5) / 1" | bc
}
wpx=$(round "$(echo "scale=4; $width * $mm2px" | bc -l)")
hpx=$(round "$(echo "scale=4; $height * $mm2px" | bc -l)")

echo "Width in pixels: $wpx"
echo "Height in pixels: $hpx"

$command_name $input_name | sed -e "3s/.*/set terminal pngcairo size $wpx,$hpx fontscale $ptscale linewidth $ptscale pointscale $ptscale/" -e "/set output/ s/.*/set output '$output_name'/" | gnuplot
