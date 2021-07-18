import json
import requests
import codecs
from tqdm import tqdm

cookies = dict(
    # COOKIE
)

params = {
    'season_version':   '-1',
    'area':             '-1',
    'is_finish':        '-1',
    'copyright':        '-1',
    'season_status':    '-1',
    'season_month':     '-1',
    'year':             '-1',
    'style_id':         '-1',
    'order':            '5',
    'st':               '1',
    'sort':             '0',
    'page':             1,
    'season_type':      '1',
    'pagesize':         '4000',
    'type':             '1'
}

headers = {
    'accept': 'application/json, text/plain, */*',
    # 'accept-encoding': 'gzip, deflate, br',
    'accept-language': 'en-CA,en;q=0.9,zh-CN;q=0.8,zh;q=0.7,ja-JP;q=0.6,ja;q=0.5,en-GB;q=0.4,en-US;q=0.3',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'referer': 'https://www.bilibili.com/',
    'origin': 'https://www.bilibili.com',
    'dnt': '1',
    'sec-ch-ua': '" Not;A Brand";v="99", "Google Chrome";v="91", "Chromium";v="91"',
    'sec-ch-ua-mobile': '?0',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-site',
}

anime_list = []
has_next = 1
while (has_next == 1):
    r = requests.get('https://api.bilibili.com/pgc/season/index/result', params=params, headers=headers, cookies=cookies)
    data = json.loads(r.content)
    has_next = data['data']['has_next']

    print('status code: %s, page: %d, has next: %d, data size: %d' %(r.status_code, params['page'], has_next, len(data['data']['list'])))
    anime_list.extend(data['data']['list'])
    print('database size: %d'%(len(anime_list)))
    params['page'] += 1

print('merging database...')
with codecs.open('../assets/anime.json', 'r+', encoding='utf-8') as old_db:
    old_list = json.load(old_db)
    for anime_old in tqdm(old_list):
        exist = False
        for anime in anime_list:
            if (anime['media_id'] == anime_old['media_id']):
                exist = True
                break
        if (not exist):
            anime_list.append(anime_old)
    
    print('merged database size: %d'%(len(anime_list)))


with codecs.open('../assets/anime.json', 'w+', encoding='utf-8') as db:
    json.dump(anime_list, db, indent=4, ensure_ascii=False)
