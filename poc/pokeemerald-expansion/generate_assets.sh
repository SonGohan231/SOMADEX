#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 /path/to/SOMADEX-repository" >&2
    exit 2
fi

source_root=$1
work_dir=${TMPDIR:-/tmp}/somadex-poc-assets
mkdir -p "$work_dir"

base64 -d "$source_root/assets/embedded/luzik.b64" > "$work_dir/luzik.png"
base64 -d "$source_root/assets/embedded/trainer_walk.b64" > "$work_dir/trainer.png"
base64 -d "$source_root/assets/embedded/npc_mira.b64" > "$work_dir/mira.png"

convert \
    xc:'#00B0E8' xc:'#081820' xc:'#103040' xc:'#185058' \
    xc:'#287880' xc:'#40A8A8' xc:'#70D8D0' xc:'#C0F8E8' \
    xc:'#F8F8F8' xc:'#F0E058' xc:'#E89038' xc:'#784830' \
    xc:'#607070' xc:'#303840' xc:'#D04040' xc:'#F800F8' \
    +append "$work_dir/luzik-palette.png"

convert \
    xc:'#73C5A4' xc:'#5B3A29' xc:'#E1A474' xc:'#9A5E49' \
    xc:'#19384D' xc:'#102334' xc:'#39D0CD' xc:'#E9F2ED' \
    xc:'#768389' xc:'#101010' xc:'#EEC85E' xc:'#C54141' \
    xc:'#394A7B' xc:'#293962' xc:'#FFFFFF' xc:'#000000' \
    +append "$work_dir/person-palette.png"

convert \
    xc:'#629C83' xc:'#737373' xc:'#BDBDBD' xc:'#FFFFFF' \
    xc:'#416A94' xc:'#6294A4' xc:'#94C5DE' xc:'#C5E6EE' \
    xc:'#294152' xc:'#E6C54A' xc:'#E68B31' xc:'#8B5231' \
    xc:'#DE737B' xc:'#984A52' xc:'#62625A' xc:'#414141' \
    +append "$work_dir/icon-palette.png"

convert "$work_dir/luzik.png" -background '#00B0E8' -alpha background -flatten \
    -remap "$work_dir/luzik-palette.png" "$work_dir/luzik-indexed.png"

convert -size 64x128 xc:'#00B0E8' \
    "$work_dir/luzik-indexed.png" -geometry +8+8 -composite \
    "$work_dir/luzik-indexed.png" -geometry +8+72 -composite \
    -remap "$work_dir/luzik-palette.png" PNG8:graphics/pokemon/treecko/anim_front.png
cp graphics/pokemon/treecko/anim_front.png graphics/pokemon/treecko/anim_front_gba.png

convert -size 64x64 xc:'#00B0E8' \
    \( "$work_dir/luzik-indexed.png" -flop \) -geometry +8+8 -composite \
    -remap "$work_dir/luzik-palette.png" PNG8:graphics/pokemon/treecko/back.png
cp graphics/pokemon/treecko/back.png graphics/pokemon/treecko/back_gba.png

convert "$work_dir/luzik.png" -background '#629C83' -alpha background -flatten \
    -filter point -resize 28x28 -gravity center -extent 32x32 \
    -remap "$work_dir/icon-palette.png" "$work_dir/luzik-icon.png"
convert "$work_dir/luzik-icon.png" "$work_dir/luzik-icon.png" -append \
    -remap "$work_dir/icon-palette.png" PNG8:graphics/pokemon/treecko/icon.png
cp graphics/pokemon/treecko/icon.png graphics/pokemon/treecko/icon_gba.png

for frame in 0 1 2 3 4 5 6 7; do
    convert "$work_dir/trainer.png" -crop "24x24+$((frame * 24))+0" +repage \
        -trim -background '#73C5A4' -alpha background -flatten \
        -gravity south -extent 16x32 -remap "$work_dir/person-palette.png" \
        "$work_dir/trainer-$frame.png"
done
convert \
    "$work_dir/trainer-0.png" "$work_dir/trainer-1.png" "$work_dir/trainer-1.png" \
    "$work_dir/trainer-2.png" "$work_dir/trainer-3.png" "$work_dir/trainer-3.png" \
    "$work_dir/trainer-4.png" "$work_dir/trainer-5.png" "$work_dir/trainer-5.png" \
    +append -remap "$work_dir/person-palette.png" PNG8:graphics/object_events/pics/people/brendan/walking.png
cp graphics/object_events/pics/people/brendan/walking.png graphics/object_events/pics/people/brendan/running.png

for frame in 0 1; do
    convert "$work_dir/mira.png" -crop "24x24+$((frame * 24))+0" +repage \
        -trim -background '#73C5A4' -alpha background -flatten \
        -gravity south -extent 16x32 -remap "$work_dir/person-palette.png" \
        "$work_dir/mira-$frame.png"
done
convert \
    "$work_dir/mira-0.png" "$work_dir/mira-1.png" "$work_dir/mira-1.png" \
    "$work_dir/mira-0.png" "$work_dir/mira-1.png" "$work_dir/mira-1.png" \
    "$work_dir/mira-0.png" "$work_dir/mira-1.png" "$work_dir/mira-1.png" \
    +append -remap "$work_dir/person-palette.png" PNG8:graphics/object_events/pics/people/boy_2.png

convert "$work_dir/luzik.png" -background '#00B0E8' -alpha background -flatten \
    -filter point -resize 16x16 -gravity south -extent 16x32 \
    -remap "$work_dir/luzik-palette.png" "$work_dir/luzik-overworld-frame.png"
convert \
    "$work_dir/luzik-overworld-frame.png" "$work_dir/luzik-overworld-frame.png" \
    "$work_dir/luzik-overworld-frame.png" "$work_dir/luzik-overworld-frame.png" \
    "$work_dir/luzik-overworld-frame.png" "$work_dir/luzik-overworld-frame.png" \
    "$work_dir/luzik-overworld-frame.png" "$work_dir/luzik-overworld-frame.png" \
    "$work_dir/luzik-overworld-frame.png" "$work_dir/luzik-overworld-frame.png" \
    "$work_dir/luzik-overworld-frame.png" "$work_dir/luzik-overworld-frame.png" \
    +append -remap "$work_dir/luzik-palette.png" PNG8:graphics/pokemon/treecko/overworld.png

echo "SOMADEX Micro-PoC assets generated from repository seeds."
