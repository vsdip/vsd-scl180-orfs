#!/usr/bin/env bash
set -euo pipefail

TECH_LEF="platforms/scl180fs120/lef/scl18fs120_tech.lef"
OUT="platforms/scl180fs120/make_tracks.tcl"

awk '
BEGIN{
  # desired order
  split("M1 M2 M3 M4 M5 TOP_M", ord, " ")
}
function trim(s){ sub(/^[ \t]+/,"",s); sub(/[ \t]+$/,"",s); return s }

# Enter a layer block
/^LAYER[ \t]+/{
  cur=$2
  inlayer=1
  is_routing=0
  pitch=""
  offset=""
  next
}

inlayer && /TYPE[ \t]+ROUTING/ { is_routing=1; next }

# tech LEF often has "PITCH <num> ;"
inlayer && is_routing && /PITCH[ \t]+/{
  # handle: PITCH 1.12 ;
  pitch=$2
  gsub(/;/,"",pitch)
  next
}

# tech LEF often has "OFFSET <num> ;"
inlayer && is_routing && /OFFSET[ \t]+/{
  offset=$2
  gsub(/;/,"",offset)
  next
}

# End of a layer block
inlayer && /^END[ \t]+/{
  endname=$2
  if (is_routing && cur==endname && pitch!="") {
    if (offset=="") offset="0"
    # If no explicit X/Y tracks exist, use same pitch/offset for both axes.
    # This is a fallback; real tracks are usually half-pitch shifted, but this is safe.
    xoff[cur]=offset; xp[cur]=pitch
    yoff[cur]=offset; yp[cur]=pitch
    seen[cur]=1
  }
  inlayer=0
  next
}

END{
  for (i=1;i<=6;i++){
    l=ord[i]
    if (!seen[l]) {
      printf("# WARNING: no ROUTING PITCH found for %s in tech LEF\n", l)
      continue
    }
    printf("make_tracks %s -x_offset %.6g -x_pitch %.6g -y_offset %.6g -y_pitch %.6g\n",
           l, xoff[l], xp[l], yoff[l], yp[l])
  }
}
' "$TECH_LEF" > "$OUT"

echo "Wrote: $OUT"
cat "$OUT"
