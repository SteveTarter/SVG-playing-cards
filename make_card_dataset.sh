#!/usr/bin/env bash
# Generate a labeled card dataset using ./makecards
# Usage: ./make_card_dataset.sh [OUTPUT_DIR]
# Default OUTPUT_DIR = ./cards

set -u
OUT_ROOT="${1:-./cards}"
MAKECARDS="${MAKECARDS:-./makecards}"

mkdir -p "$OUT_ROOT"

# --------- Card lists ----------
# Rank codes used by makecards: A,2..9,T,J,Q,K ; Suits: C,D,H,S
ranks=(A 2 3 4 5 6 7 8 9 T J Q K)
rank_names=("ace" "two" "three" "four" "five" "six" "seven" "eight" "nine" "ten" "jack" "queen" "king")
suits=(C D H S)
suit_names=("clubs" "diamonds" "hearts" "spades")
jokers=("1J", "2J")

# --------- Permutation knobs (edit me) ----------
# Sizes / aspect presets
#sizes=(
#  " --poker "
#  " --bridge "
#  " --width=744 --height=1038 "
#)
# The above permutations changed nothing.  Sticking with poker.
sizes=(
  " --poker "
)

# Visual themes/toggles (keep these fairly orthogonal)
themes=(
  ""                   # classic
  " --four-colour "
  " --no-border "
  " --box "
  " --symmetric "
  " --plain "          # plain court
  " --plain-pip "      # plain pips
  " --single-pip "     # single large suit
)

# Optional front background colour variants (CSS/SVG colours or hex)
front_colours=(
  " --front-colour=white "
  " --front-colour=#e8e8e8 "
)

# Blocky or pointy pips
pip_styles=(
  "--pip=0"
  "--pip=1"
)

# If you know valid ranges for these on your build, add them (examples commented):
value_styles=(
  ""
)

# Helper to normalize filename fragments
normalize() { echo "$1" | tr -s ' ' '_' | tr -d '=' | sed 's/__\+/_/g;s/^_//;s/_$//'; }

# --------- 52 faces ----------
for i in "${!ranks[@]}"; do
  rcode="${ranks[$i]}"
  rname="${rank_names[$i]}"
  for j in "${!suits[@]}"; do
    scode="${suits[$j]}"
    sname="${suit_names[$j]}"
    card_code="${rcode}${scode}"
    dir="${OUT_ROOT}/${rname} of ${sname}"
    mkdir -p "$dir"

    for size in "${sizes[@]}"; do
      for theme in "${themes[@]}"; do
        for front in "${front_colours[@]}"; do
          for pip in "${pip_styles[@]}"; do
            for val in "${value_styles[@]}"; do
              opts="--inline --ace=Fancy --ace1=""cards.rev.uk"" --ace2=""cards.rev.uk"" --card=${card_code} ${size} ${theme} ${front} ${pip} ${val}"
              # Unique, descriptive filename (add short hash of options to guarantee uniqueness)
              token="$(normalize "${size} ${theme} ${front} ${pip} ${val}")"
              hash=$(echo "${opts}" | tr -s ' ' | sha1sum | cut -c1-8)
              fname="$(normalize "${rname}_of_${sname}__${token}__${hash}").svg"

              echo "→ ${dir}/${fname}"
              if ! ${MAKECARDS} ${opts} > "${dir}/${fname}"; then
                echo "   (skip: makecards failed for ${card_code} with '${token}')"
              fi
            done
          done
        done
      done
    done
  done
done

# --------- Jokers (optional) ----------
# makecards doesn’t take a --card for jokers, so we generate a mini-deck into a temp dir
# and copy only joker SVGs into ./joker
if false; then
dir="${OUT_ROOT}/joker"
JOKER_DIR="${OUT_ROOT}/joker"
mkdir -p "$JOKER_DIR"
for joker in "${jokers[@]}"; do
  for size in "${sizes[@]}"; do
    for theme in "${themes[@]}"; do
      for front in "${front_colours[@]}"; do
        opts="--inline --card=${joker} ${size} ${theme} ${front} --jokers=2 --joker1-image=""svg/1J.svg"" --joker2-image=""svg/2J.svg"""
        token="$(normalize "${size} ${theme} ${front}")"
        hash=$(echo "${opts}" | tr -s ' ' | sha1sum | cut -c1-8)
        fname="$(normalize "joker__${token}__${hash}").svg"

        echo "→ ${dir}/${fname}"
        echo "${MAKECARDS} ${opts} > ${dir}/${fname}";
        if ! ${MAKECARDS} ${opts} > "${dir}/${fname}"; then
          echo "   (skip: makecards failed for jokers with '${token}')"
        fi
      done
    done
  done
done
fi

# --------- Convert SVG to PNG ---------
# makecards creates cards in SVG format.  These need to be converted to PNG for training.
find ./cards -type f -name '*.svg' \
  | awk -E resize_convert.awk \
  | /bin/bash -x

echo "Done. Output under: ${OUT_ROOT}"

