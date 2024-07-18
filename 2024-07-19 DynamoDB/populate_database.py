#!/usr/bin/env python3

import boto3

discographies = [
    {'name': 'Michael Jackson', 'albums': [
        {'title': 'Thriller', 'year': 1982, 'songs': [
            {'trackNumber': 1, 'title': 'Wanna Be Startin\' Somethin\''},
            {'trackNumber': 2, 'title': 'Baby Be Mine'},
            {'trackNumber': 3, 'title': 'The Girl Is Mine'},
            {'trackNumber': 4, 'title': 'Thriller'},
            {'trackNumber': 5, 'title': 'Beat It'},
            {'trackNumber': 6, 'title': 'Billie Jean'},
            {'trackNumber': 7, 'title': 'Human Nature'},
            {'trackNumber': 8, 'title': 'P.Y.T. (Pretty Young Thing)'},
            {'trackNumber': 9, 'title': 'The Lady in My Life'},
        ]},
        {'title': 'Bad', 'year': 1987, 'songs': [
            {'trackNumber': 1, 'title': 'Bad'},
            {'trackNumber': 2, 'title': 'The Way You Make Me Feel'},
            {'trackNumber': 3, 'title': 'Speed Demon'},
            {'trackNumber': 4, 'title': 'Liberian Girl'},
            {'trackNumber': 5, 'title': 'Just Good Friends'},
            {'trackNumber': 6, 'title': 'Another Part of Me'},
            {'trackNumber': 7, 'title': 'Man in the Mirror'},
            {'trackNumber': 8, 'title': 'I Just Can\'t Stop Loving You'},
            {'trackNumber': 9, 'title': 'Dirty Diana'},
            {'trackNumber': 10, 'title': 'Smooth Criminal'},
            {'trackNumber': 11, 'title': 'Leave Me Alone'},
        ]}
    ]},
]

table_name = 'music-database'
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

# delete all items from table
with table.batch_writer() as batch:
    for item in table.scan()['Items']:
        batch.delete_item(Key={'PK': item['PK'], 'SK': item['SK']})

artist_id = 0
album_id = 0
song_id = 0

for discography in discographies:
    # add artist metadata
    artist_id += 1
    artistName = discography['name']
    table.put_item(Item={
        'PK': f'ARTIST#Artist{artist_id}',
        'SK': f'#METADATA#Artist{artist_id}',
        'Name': artistName
    })

    for album in discography['albums']:
        album_id += 1
        album_title = album['title']

        # add album metadata
        table.put_item(Item={
            'PK': f'ALBUM#Album{artist_id}',
            'SK': f'#METADATA#Album{album_id}',
            'Title': album_title,
            'Year': album['year'],
        })

        # add album relationship
        table.put_item(Item={
            'PK': f'ARTIST#Artist{artist_id}',
            'SK': f'ALBUM#Album{album_id}',
        })

        for song in album['songs']:
            # add song metadata
            song_id += 1
            song_title = song['title']
            table.put_item(
                Item={
                    'PK': f'SONG#Song{song_id}',
                    'SK': f'#METADATA#Song{song_id}',
                    'title': song_id,
                    'trackNumber': song['trackNumber']
                })

            # add song relationship
            table.put_item(
                Item={
                    'PK': f'ARTIST#Artist{artist_id}',
                    'SK': f'SONG#Song{song_id}',
                })
            table.put_item(
                Item={
                    'PK': f'ALBUM#Album{album_id}',
                    'SK': f'SONG#Song{song_id}',
                })
            table.put_item(
                Item={
                    'PK': f'SONG#Song{song_id}',
                    'SK': f'ALBUM#Album{album_id}',
                })
            table.put_item(
                Item={
                    'PK': f'SONG#Song{song_id}',
                    'SK': f'ARTIST#Artist{artist_id}',
                })
