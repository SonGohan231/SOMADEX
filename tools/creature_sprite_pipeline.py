#!/usr/bin/env python3
"""SOMADEX creature battle-seed pipeline.

Input: source graphics ZIP + seed_manifest.csv.
Output: 150 transparent 128x128 candidate seeds, QA CSV and review sheet.
Candidates are never auto-approved; visual review remains mandatory.
"""
from __future__ import annotations
import argparse,csv,math,re,shutil,tempfile,zipfile
from pathlib import Path
try:
 import cv2,numpy as np
 from PIL import Image,ImageDraw
except ImportError as exc:
 raise SystemExit("Install Pillow opencv-python-headless numpy") from exc
CARD_DIR="02_OSOBNE_FORMY_150_STWORKOW";FRAME_SIZE=128;OBJECT_BOX=112;FLOOR_Y=124;PALETTE_COLORS=24
ACTION_FRAME_COUNTS={"idle":4,"attack":6,"hurt":3,"faint":5,"special":6}
def slug(v): return re.sub(r"[^a-z0-9ąćęłńóśźż]+","_",v.strip().lower(),flags=re.I).strip("_")
def read_manifest(path):
 with Path(path).open("r",encoding="utf-8-sig",newline="") as h: rows=list(csv.DictReader(h))
 if len(rows)!=150: raise ValueError(f"expected 150 forms, got {len(rows)}")
 return rows
def find_source(root,row):
 family=int(row["family_id"]); dirs=sorted(root.glob(f"{family:03d}_*"))
 if len(dirs)!=1: raise FileNotFoundError(f"family {family:03d}")
 p=dirs[0]/row["source_file"]
 if p.is_file(): return p
 m=list(dirs[0].glob(f"{family:03d}_{int(row['stage']):02d}_*.jpg"))
 if len(m)==1:return m[0]
 raise FileNotFoundError(p)
def central_grabcut(img):
 h,w=img.shape[:2]; art=img[int(h*.10):int(h*.88),int(w*.03):int(w*.94)].copy(); ah,aw=art.shape[:2]
 sc=min(1.,460./max(aw,ah)); work=cv2.resize(art,(max(1,round(aw*sc)),max(1,round(ah*sc))),interpolation=cv2.INTER_AREA); wh,ww=work.shape[:2]
 mask=np.zeros((wh,ww),np.uint8); rect=(max(1,int(ww*.07)),max(1,int(wh*.08)),max(2,int(ww*.86)),max(2,int(wh*.84)))
 bg=np.zeros((1,65),np.float64);fg=np.zeros((1,65),np.float64);cv2.grabCut(work,mask,rect,bg,fg,2,cv2.GC_INIT_WITH_RECT)
 binary=np.where((mask==cv2.GC_FGD)|(mask==cv2.GC_PR_FGD),1,0).astype(np.uint8);n,labs,stats,cents=cv2.connectedComponentsWithStats(binary,8);cx,cy=ww*.5,wh*.55;rank=[]
 for i in range(1,n):
  x,y,cw,ch,area=stats[i]
  if area<60:continue
  dx=(cents[i][0]-cx)/max(1.,ww*.42);dy=(cents[i][1]-cy)/max(1.,wh*.42);rank.append((area/(1+2*(dx*dx+dy*dy)),i,int(area)))
 rank.sort(reverse=True);keep=np.zeros_like(binary)
 if rank:
  main=rank[0][1];mx,my,mw,mh,ma=stats[main];ex0,ex1=mx-mw*.35,mx+mw*1.35;ey0,ey1=my-mh*.35,my+mh*1.35
  for _,i,area in rank[:8]:
   px,py=cents[i]
   if i==main or (ex0<=px<=ex1 and ey0<=py<=ey1 and area>=int(ma*.03)):keep[labs==i]=1
 return art,cv2.resize(keep*255,(aw,ah),interpolation=cv2.INTER_NEAREST).astype(np.uint8)
def normalize_seed(art,alpha):
 ys,xs=np.where(alpha>0)
 if not len(xs):return Image.new("RGBA",(128,128),(0,0,0,0)),{"alpha_occupancy":0.,"components":0,"warning":"empty-mask"}
 x0,x1=max(0,int(xs.min())-4),min(alpha.shape[1],int(xs.max())+5);y0,y1=max(0,int(ys.min())-4),min(alpha.shape[0],int(ys.max())+5)
 rgba=cv2.cvtColor(art,cv2.COLOR_BGR2RGBA);rgba[:,:,3]=alpha;crop=Image.fromarray(rgba[y0:y1,x0:x1]);cw,ch=crop.size;sc=min(OBJECT_BOX/max(1,cw),OBJECT_BOX/max(1,ch));nw,nh=max(1,round(cw*sc)),max(1,round(ch*sc))
 tiny=crop.resize((max(1,round(nw/3)),max(1,round(nh/3))),Image.Resampling.LANCZOS);a=tiny.getchannel("A").point(lambda v:255 if v>=96 else 0);pal=tiny.convert("RGB").quantize(colors=24,method=Image.Quantize.MEDIANCUT).convert("RGB").convert("RGBA");pal.putalpha(a);sprite=pal.resize((nw,nh),Image.Resampling.NEAREST);canvas=Image.new("RGBA",(128,128),(0,0,0,0));canvas.alpha_composite(sprite,((128-nw)//2,FLOOR_Y-nh))
 arr=np.array(canvas.getchannel("A"));occ=float(np.count_nonzero(arr))/16384.;n,_,stats,_=cv2.connectedComponentsWithStats((arr>0).astype(np.uint8),8);components=sum(stats[i,cv2.CC_STAT_AREA]>=8 for i in range(1,n));warning="too-small" if occ<.035 else "too-much-foreground" if occ>.52 else "fragmented-mask" if components>6 else ""
 return canvas,{"alpha_occupancy":round(occ,4),"components":components,"warning":warning}
def build_candidate(path):
 img=cv2.imread(str(path),cv2.IMREAD_COLOR)
 if img is None:raise ValueError(path)
 return normalize_seed(*central_grabcut(img))
def contact_sheet(entries,path):
 cw,ch,cols=148,154,10;sheet=Image.new("RGBA",(cols*cw,math.ceil(len(entries)/cols)*ch),(17,24,28,255));d=ImageDraw.Draw(sheet)
 for i,(row,seed) in enumerate(entries):
  x=(i%cols)*cw;y=(i//cols)*ch;sheet.alpha_composite(seed,(x+10,y+4));d.text((x+4,y+134),f"{int(row['family_id']):03d}-{int(row['stage'])} {row['name']}"[:23],fill=(235,242,242,255))
 Path(path).parent.mkdir(parents=True,exist_ok=True);sheet.convert("RGB").save(path,"JPEG",quality=88)
def self_test():
 art=np.zeros((240,320,3),np.uint8);art[:]=(35,60,90);cv2.circle(art,(160,130),55,(190,210,235),-1);alpha=np.zeros((240,320),np.uint8);cv2.circle(alpha,(160,130),55,255,-1);seed,qa=normalize_seed(art,alpha);assert seed.size==(128,128) and qa["alpha_occupancy"]>.03;print("SOMADEX_SPRITE_PIPELINE_SELF_TEST: PASS");return 0
def run(args):
 rows=read_manifest(args.manifest);out=Path(args.output)
 if out.exists() and args.clean:shutil.rmtree(out)
 out.mkdir(parents=True,exist_ok=True);qa=[];entries=[]
 with tempfile.TemporaryDirectory(prefix="somadex_seed_") as td:
  with zipfile.ZipFile(args.source_zip) as z:z.extractall(td)
  root=Path(td)/CARD_DIR
  if not root.is_dir():raise FileNotFoundError(CARD_DIR)
  for i,row in enumerate(rows,1):
   seed,metrics=build_candidate(find_source(root,row));dst=out/f"{int(row['family_id']):03d}"/f"{int(row['stage']):02d}_{slug(row['name'])}.webp";dst.parent.mkdir(parents=True,exist_ok=True);seed.save(dst,"WEBP",lossless=True,method=6);entry=dict(row);entry.update(metrics);entry["candidate_file"]=str(dst.relative_to(out));entry["qa_status"]="review" if metrics["warning"] else "candidate-ok";qa.append(entry);entries.append((row,seed));print(f"[{i:03d}/150] {row['name']} {entry['qa_status']}")
 with (out/"qa_report.csv").open("w",encoding="utf-8",newline="") as h:w=csv.DictWriter(h,fieldnames=list(qa[0].keys()));w.writeheader();w.writerows(qa)
 contact_sheet(entries,out/"review_contact_sheet.jpg");print(f"Generated 150 candidates; review warnings: {sum(bool(r['warning']) for r in qa)}");return 0
def main():
 ap=argparse.ArgumentParser();ap.add_argument("--source-zip");ap.add_argument("--manifest",default="data/creatures/battle_sprites/seed_manifest.csv");ap.add_argument("--output",default="build/creature_seed_candidates");ap.add_argument("--clean",action="store_true");ap.add_argument("--self-test",action="store_true");a=ap.parse_args()
 if a.self_test:return self_test()
 if not a.source_zip:raise SystemExit("--source-zip required")
 return run(a)
if __name__=="__main__":raise SystemExit(main())
