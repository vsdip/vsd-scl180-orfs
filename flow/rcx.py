LEF=platforms/scl180fs120/lef/scl18fs120_tech.lef

python3 - <<'PY'
import re, pathlib

lef_path = pathlib.Path("platforms/scl180fs120/lef/scl18fs120_tech.lef")
txt = lef_path.read_text(errors="ignore")

layer_re = re.compile(r'^\s*LAYER\s+(\S+)\s*$(.*?)^\s*END\s+\1\s*$', re.M | re.S)
width_re = re.compile(r'^\s*WIDTH\s+([0-9.]+)', re.M)
type_route_re = re.compile(r'^\s*TYPE\s+ROUTING', re.M)

layers = []
for m in layer_re.finditer(txt):
    name = m.group(1)
    body = m.group(2)
    if not type_route_re.search(body):
        continue
    wm = width_re.search(body)
    if wm:
        layers.append((name, float(wm.group(1))))

layers = layers[:6]

def dists(w):
    base = max(w * 1.8, 0.2)
    mult = [0,1,2,3,4,5,7,9,12,16]
    return [round(base*m,3) for m in mult]

out = []
out.append("Extraction Rules for OpenRCX\n\n")
out.append("DIAGMODEL ON\n\n")
out.append(f"LayerCount {len(layers)}\n\n")
out.append("DensityRate 1  0\n\n")
out.append("DensityModel 0\n\n")

for i,(name,w) in enumerate(layers,1):
    dist = dists(w)
    out.append(f"Metal {i} RESOVER\n")
    out.append(f"WIDTH Table 1 entries:  {w}\n\n")
    out.append(f"Metal {i} RESOVER 0\n")
    out.append("DIST count 55 width %s\n" % w)
    for a in range(len(dist)):
        for b in range(a,len(dist)):
            out.append(f"{dist[a]} {dist[b]} 0 0.001\n")
    out.append(f"{dist[-1]} 0 {dist[-1]} 0.001\n")
    out.append("END DIST\n\n")

out.append("END DensityModel 0\n")

pathlib.Path("platforms/scl180fs120/rcx_patterns.rules").write_text("".join(out))
print("Generated platforms/scl180fs120/rcx_patterns.rules")
PY

