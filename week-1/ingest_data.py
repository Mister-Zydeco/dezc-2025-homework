#! /usr/bin/env python

import argparse
import os
import pandas as pd
import pyarrow.parquet as pq
import sqlalchemy

def alts(st: str):
    return [f'--{st}', f'-{st}']

class C:
    pass

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog='uploader',
        description='Ingest Parquet file into Postgres'
    )
    parser.add_argument(*alts('user'),
        help='postgres username', required=True)
    parser.add_argument(*alts('password'),
        help='postgres password', required=True)
    parser.add_argument(*alts('host'),
        help='postgres host', required=True)
    parser.add_argument(*alts('port'),
        help='postgres port', required=True)
    parser.add_argument(*alts('db'),
        help='postgres database name', required=True)
    parser.add_argument(*alts('table_name'),
        help='database table name', required=True)
    parser.add_argument(*alts('input_url'),
        help='url for input parquet or csv file', required=True)
    parser.add_argument(*alts('chunksize'), type=int,
        help='number of rows of data to load at once', required=True)
    parser.add_argument(*alts('datetime_columns'), 
        help='comma-separated list of columns to coerce to datetime')
    c = C()
    parser.parse_args(namespace=c)

    os.system(f'curl -L {c.input_url} -o datafile')
    print('Downloaded input data file...')

    if c.input_url.endswith('.parquet'):
        table = pq.read_table('datafile')
        table_df = table.to_pandas()
    elif c.input_url.endswith('.csv'):
        table_df = pd.read_csv('datafile')
    elif c.input_url.endswith('.csv.gz'):
        table_df = pd.read_csv('datafile', compression='gzip')
    else:
        raise ValueError(f'Do not know how to handle input {c.input_url}')

    if c.datetime_columns:
        datetime_fields = c.datetime_columns.split(',')
        for field in datetime_fields:
            table_df[field] = pd.to_datetime(
                table_df[field], errors='coerce')
            print(f'Coerced dataframe column "{field}" to datetime')
                            
    engine = sqlalchemy.create_engine(
        f'postgresql://{c.user}:{c.password}@{c.host}:{c.port}/{c.db}')
    #engine.connect()

    nrows = table_df.shape[0]
    append_or_replace, row0 =  'replace', 0
    
    print('Beginning ingestion...')
    while row0 < nrows:
        chunk = table_df.iloc[row0: row0 + c.chunksize]
        chunk.to_sql(name=c.table_name, con=engine,
                        if_exists=append_or_replace)
        row0 = min(row0 + c.chunksize, nrows)
        print(f'Inserted {row0} rows')
        append_or_replace = 'append'
        
