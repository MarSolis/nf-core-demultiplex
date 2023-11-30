import csv
import pandas as pd

class ParseInteropFiles:

    def __init__(self, output_dir):
        self.output_dir = output_dir

    def parse_data(self):
        df = pd.DataFrame()
        with open(self.output_dir+"/QC/interop_summary.csv", newline='') as csvfile:
            spamreader = csv.reader(csvfile, delimiter=',')
            for row in spamreader:
                if "Level" in row:
                    head = row
                elif "Total" in row:
                    for h,value in zip(head,row):
                        df.loc["total",h] = value
        return df
