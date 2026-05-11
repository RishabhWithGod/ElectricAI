from app.utils.normalize import normalize_component_name, extract_ratings, _normalize_text
from typing import List, Any, Dict
import numpy as np

def iou(boxA, boxB):
    xA = max(boxA[0], boxB[0])
    yA = max(boxA[1], boxB[1])
    xB = min(boxA[0]+boxA[2], boxB[0]+boxB[2])
    yB = min(boxA[1]+boxA[3], boxB[1]+boxB[3])
    interArea = max(0, xB - xA) * max(0, yB - yA)
    boxAArea = boxA[2] * boxA[3]
    boxBArea = boxB[2] * boxB[3]
    iou = interArea / float(boxAArea + boxBArea - interArea + 1e-6)
    return iou

def merge_wires(detections):
    wires = [d for d in detections if d['class'] == 'wire']
    merged = []
    used = set()
    for i, w1 in enumerate(wires):
        if i in used:
            continue
        group = [w1]
        for j, w2 in enumerate(wires):
            if i != j and j not in used and iou(w1['box'], w2['box']) > 0.2:
                group.append(w2)
                used.add(j)
        used.add(i)
        # Merge group
        x1 = min(w['box'][0] for w in group)
        y1 = min(w['box'][1] for w in group)
        x2 = max(w['box'][0]+w['box'][2] for w in group)
        y2 = max(w['box'][1]+w['box'][3] for w in group)
        merged.append({**w1, 'box': [x1, y1, x2-x1, y2-y1]})
    return [d for d in detections if d['class'] != 'wire'] + merged

def deduplicate(detections):
    out = []
    for d in detections:
        if not any(iou(d['box'], o['box']) > 0.5 and d['class'] == o['class'] for o in out):
            out.append(d)
    return out

def process_results(detections: List[List[Dict]], ocr_results: List[List[Dict]]) -> Dict:
    summary = {}
    all_items = []
    for page_idx, (dets, ocrs) in enumerate(zip(detections, ocr_results)):
        dets = merge_wires(deduplicate(dets))
        for d in dets:
            label = d['class']
            conf = d['conf']
            # Find nearest OCR label
            nearest = None
            min_dist = float('inf')
            for o in ocrs:
                ox, oy, ow, oh = o['box']
                dx, dy, dw, dh = d['box']
                dist = np.hypot((ox+ow/2)-(dx+dw/2), (oy+oh/2)-(dy+dh/2))
                if dist < min_dist and dist < 80:
                    min_dist = dist
                    nearest = o
            ratings = nearest['ratings'] if nearest else []
            norm_label = normalize_component_name(label)
            if not norm_label:
                continue
            if norm_label not in summary:
                summary[norm_label] = {"qty": 0, "conf": [], "ratings": []}
            summary[norm_label]["qty"] += 1
            summary[norm_label]["conf"].append(conf)
            summary[norm_label]["ratings"].extend(ratings)
            all_items.append({"type": norm_label, "conf": conf, "box": d['box'], "ratings": ratings, "page": page_idx+1})
    # Confidence averaging and dedup ratings
    for k, v in summary.items():
        v["confidence"] = float(np.mean(v["conf"])) if v["conf"] else 0.0
        v["ratings"] = list(set(v["ratings"]))
        del v["conf"]
    return {"summary": summary, "items": all_items}
