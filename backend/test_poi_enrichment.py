#!/usr/bin/env python
"""Test POI service Foursquare enrichment directly"""

import sys
sys.path.insert(0, '.')

from app.services.ai_poi_service import get_pois_for_destination
import json

print('Fetching POIs for Al Khobar with Foursquare enrichment...')
pois = get_pois_for_destination('Al Khobar', limit=5)

print(f"\nFound {len(pois)} POIs\n")

for poi in pois:
    print(f"Place: {poi.get('name')}")
    photo_url = poi.get('photo_url', 'NONE')
    if photo_url and photo_url != 'NONE':
        print(f"  Photo: {photo_url[:90]}...")
    else:
        print(f"  Photo: NONE")  
    print(f"  FSQ ID: {poi.get('fsq_id', 'NONE')}")
    print()
