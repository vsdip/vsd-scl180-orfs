TECHLEF="/home/vsduser/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/6M1L/lef/scl18fs120_tech.lef"
OUT="platforms/scl180fs120/rcx_patterns.rules"

mkdir -p "$(dirname "$OUT")"

python3 - << 'PY'
import re, sys, pathlib

techlef = pathlib.Path("/home/vsduser/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/6M1L/lef/scl18fs120_tech.lef")
out = pathlib.Path("platforms/scl180fs120/rcx_patterns.rules")

txt = techlef.read_text(errors="ignore").splitlines()

# Collect LEF layers (routing + cut)
layers = []
layer_type = {}
for i,line in enumerate(txt):
    m = re.match(r'^\s*LAYER\s+(\S+)\s*$', line)
    if m:
        name = m.group(1)
        layers.append(name)
        # scan forward for TYPE
        t = None
        for j in range(i+1, min(i+50, len(txt))):
            mt = re.match(r'^\s*TYPE\s+(\S+)\s*;\s*$', txt[j])
            if mt:
                t = mt.group(1).upper()
                break
            if re.match(r'^\s*END\s+' + re.escape(name) + r'\s*$', txt[j]):
                break
        layer_type[name] = t or "UNKNOWN"

# Prefer routing layers that look like met1/met2... or metal1 etc.
routing = [l for l in layers if layer_type.get(l) == "ROUTING"]
cut     = [l for l in layers if layer_type.get(l) == "CUT"]

# Sort routing by numeric suffix if present
def keynum(s):
    m = re.search(r'(\d+)', s)
    return (int(m.group(1)) if m else 9999, s)

routing_sorted = sorted(routing, key=keynum)

# Heuristic: pick the first ~6 routing layers if there are many
# (SCL180 FS120 6M1L should have ~6 routing metals)
routing_use = routing_sorted[:6] if len(routing_sorted) >= 6 else routing_sorted

# Build a conservative pattern set: a few widths/spacings (in microns) that won't be empty.
# These are not "PDK-accurate RC", they are bins for pattern extraction.
widths  = [0.28, 0.40, 0.56, 0.80, 1.12, 1.60]
spaces  = [0.28, 0.40, 0.56, 0.80, 1.12, 1.60]

hdr = []
hdr.append("# rcx_patterns.rules for OpenRCX / OpenROAD-flow-scripts")
hdr.append("# Platform: scl180fs120 (auto-generated from tech LEF)")
hdr.append(f"# Source tech LEF: {techlef}")
hdr.append("# NOTE: This file provides pattern bins; accurate RC still depends on the extractor setup.")
hdr.append("")

# The format across OpenROAD-flow platforms is simple and tolerant:
# Define layers and a few width/space combos.
# We'll mimic common sky130 pattern style: 'layer <name> widths (...) spaces (...)'
# (OpenRCX parser is permissive; unknown lines are ignored in some builds.)
lines = hdr
lines.append("patterns {")
for l in routing_use:
    lines.append(f"  layer {l} {{")
    lines.append("    widths  (" + " ".join(f"{w:.2f}" for w in widths) + ");")
    lines.append("    spaces  (" + " ".join(f"{s:.2f}" for s in spaces) + ");")
    lines.append("  }")
lines.append("}")
lines.append("")

lines.append("# Routing layers detected (ROUTING): " + ", ".join(routing_use))
if cut:
    lines.append("# Cut layers present (CUT): " + ", ".join(cut[:10]) + (" ..." if len(cut)>10 else ""))

out.write_text("\n".join(lines))
print(f"Wrote {out} with {len(routing_use)} routing layers.")
print("Routing layers used:", routing_use)
PY

# Quick peek
sed -n '1,80p' platforms/scl180fs120/rcx_patterns.rules

