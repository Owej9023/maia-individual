#!/bin/bash
set -e

#args input_path output_dir player

player_file=${1}
p_dir=${2}
p_name=${3}

train_frac=90
val_frac=10

split_dir=$p_dir/split

mkdir -p ${p_dir}
mkdir -p ${split_dir}

echo "${p_name} to ${p_dir}"

python3 split_by_player.py $player_file $p_name $split_dir/games

for c in "white" "black"; do
    python3 pgn_fractional_split.py $split_dir/games_$c.pgn $split_dir/train_$c.pgn $split_dir/validate_$c.pgn --ratios $train_frac $val_frac


    cd $p_dir
    mkdir -p pgns
    for s in "train" "validate"; do
        mkdir -p $s
        mkdir -p $s/$c

        #using tool from:
        #https://www.cs.kent.ac.uk/people/staff/djb/pgn-extract/
        cat $split_dir/${s}_${c}.pgn | /mnt/c/Users/19258/Documents/GitHub/maia-individual/pgn-extract.exe -7 -C -N  -#1000

        cat $split_dir/${s}_${c}.pgn > ./$p_dir/${s}_${c}.pgn
        rm -v *.pgn

        #using tool from:
        #https://github.com/DanielUranga/trainingdata-tool
        screen -S "${p_name}-${c}-${s}" -dm bash -c "cd ${s}/${c}; trainingdata-tool -v ../../pgns/${s}_${c}.pgn"
    done
    cd -
done


