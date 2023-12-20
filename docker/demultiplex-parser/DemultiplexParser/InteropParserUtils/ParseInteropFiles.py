import os
import csv
import pandas as pd
import json

def interop_summary_parser(interop_summary):
    tmp_reads = []
    reads = []
    lanes = {}
    with open(interop_summary, 'r') as f_interop:
        lines = f_interop.readlines()
        header_flag = 0
        for i in range(0, len(lines)):
            line = lines[i].strip()
            if line.startswith('Level'):
                header_flag = 1
                summary_header = line.split(',')
                for j in range(i+1, len(lines)):
                    aux_reads = {}
                    if lines[j].startswith('Total') or lines[j].startswith('Non-indexed'):
                        break
                    if not lines[j].strip().split(',')[0].endswith('(I)'):
                        if lines[j].strip().split(',')[0] == 'Read 1': aux_reads['readLevel'] = 1
                        if lines[j].strip().split(',')[0] == 'Read 3' or lines[j].strip().split(',')[0] == 'Read 4': aux_reads['readLevel'] = 2
                        aux_reads['yieldTotal'] = None if lines[j].strip().split(',')[1] == 'nan' else lines[j].strip().split(',')[1]
                        aux_reads['projectedYield'] = None if lines[j].strip().split(',')[2] == 'nan' else lines[j].strip().split(',')[2]
                        aux_reads['aligned'] = None if lines[j].strip().split(',')[3] == 'nan' else lines[j].strip().split(',')[3]
                        aux_reads['errorRate'] = None if lines[j].strip().split(',')[4] == 'nan' else lines[j].strip().split(',')[4]
                        aux_reads['intensityCycle_1'] = None if lines[j].strip().split(',')[5] == 'nan' else lines[j].strip().split(',')[5]
                        #aux_reads['pct_intensity_cycle_1'] =
                        aux_reads['pctQ30'] = None if lines[j].strip().split(',')[6] == 'nan' else lines[j].strip().split(',')[6]
                        aux_reads['pctOccupation'] = None if lines[j].strip().split(',')[7] == 'nan' else lines[j].strip().split(',')[7]
                        aux_reads['lanes'] = []
                        tmp_reads.append(aux_reads)

            if line.startswith('Total') and header_flag == 1:
                header_flag = 0

            if line.startswith('Read') and header_flag == 0 and not line.endswith('(I)'):
                if line.split(' ')[-1] == '1': read_level = 1
                elif line.split(' ')[-1] == '3' or '4': read_level = 2
                lanes[read_level] = []
                lane_header = lines[i+1].split(',')
                for j in range(i+2, len(lines)):
                    aux_lane = {}
                    if lines[j].startswith('Read') or lines[j].startswith('Extracted'):
                        break
                    if lines[j].strip().split(',')[1] == '-':
                        aux_lane['lane'] = lines[j].strip().split(',')[0]
                        aux_lane['tiles'] = lines[j].strip().split(',')[2]
                        aux_lane['density'] = lines[j].strip().split(',')[3]
                        aux_lane['pctPf'] = lines[j].strip().split(',')[4]
                        aux_lane['legacyPhasingPrephasingRate'] = lines[j].strip().split(',')[5]
                        aux_lane['phasingSlopeOffset'] = lines[j].strip().split(',')[6]
                        aux_lane['prephasingSlopeOffset'] = lines[j].strip().split(',')[7]
                        aux_lane['reads'] = lines[j].strip().split(',')[8]
                        aux_lane['readsPf'] = lines[j].strip().split(',')[9]
                        aux_lane['pctQ30'] = lines[j].strip().split(',')[10]
                        aux_lane['yield'] = lines[j].strip().split(',')[11]
                        aux_lane['cycleErrorRate'] = lines[j].strip().split(',')[12]
                        aux_lane['pctAligned'] = lines[j].strip().split(',')[13]
                        aux_lane['errorRate'] = lines[j].strip().split(',')[14]
                        aux_lane['pctErrorRate35'] = lines[j].strip().split(',')[15]
                        #aux_lane['pct_error_rate_50'] = lines[j].strip().split(',')[0]
                        aux_lane['pctErrorRate75'] = lines[j].strip().split(',')[16]
                        aux_lane['pctErrorRate100'] = lines[j].strip().split(',')[17]
                        aux_lane['pctOccupation'] = lines[j].strip().split(',')[18]
                        aux_lane['intensityCycle1'] = lines[j].strip().split(',')[19]
                        lanes[read_level].append(aux_lane)

    # Build final array of reads and lanes
    for d in tmp_reads:
        read_level = d['readLevel']
        d['lanes'] = lanes[read_level]
        reads.append(d)

    # Return JSON
    return(reads)


class ParseInteropFiles:

    def __init__(self, output_dir):
        self.output_dir = output_dir

    def build_df(self, index, row):
        df_op = pd.DataFrame()
        df_op.loc[index, "tiles"] = row[2]
        df_op.loc[index, "density"] = row[3]
        df_op.loc[index, "pctPf"] = row[4]
        df_op.loc[index, "legacyPhasingPrephasingRate"] = row[5]
        df_op.loc[index, "reads"] = row[8]
        df_op.loc[index, "readsPf"] = row[9]
        df_op.loc[index, "pctQ30"] = row[10]
        df_op.loc[index, "yield"] = row[11]
        df_op.loc[index, "cycleErrorRate"] = row[12]
        df_op.loc[index, "aligned_A"] = row[13].split(" +/-")[0]
        df_op.loc[index, "aligned_B"] = row[13].split("+/- ")[1]
        df_op.loc[index, "Error_A"] = row[14].split("+/-")[0]
        df_op.loc[index, "Error_B"] = row[14].split("+/-")[1]
        df_op.loc[index, "Error_35_A"] = row[15].split("+/-")[0]
        df_op.loc[index, "Error_35_B"] = row[15].split("+/-")[1]
        df_op.loc[index, "Error_75_A"] = row[16].split("+/-")[0]
        df_op.loc[index, "Error_75_B"] = row[16].split("+/-")[1]
        df_op.loc[index, "Error_100_A"] = row[17].split("+/-")[0]
        df_op.loc[index, "Error_100_B"] = row[17].split("+/-")[1]
        df_op.loc[index, "occupied_A"] = row[18].split("+/-")[0]
        df_op.loc[index, "occupied_B"] = row[18].split("+/-")[1]
        df_op.loc[index, "intensity_A"] = row[19].split("+/-")[0]
        df_op.loc[index, "intensity_B"] = row[19].split("+/-")[1]
        df_op.loc[index, "phasing_A"] = row[6].split("/")[0]
        df_op.loc[index, "phasing_B"] = row[6].split("/")[1]
        df_op.loc[index, "prephasing_A"] = row[7].split("/")[0]
        df_op.loc[index, "prephasing_B"] = row[7].split("/")[1]
        return (df_op)

    def average(self, lst):
        return sum(lst) / len(lst)

    def parse_data(self):
        df_pr = pd.DataFrame()
        df = pd.DataFrame()
        r1 = 0
        with open(os.path.join(self.output_dir, "QC", "interop_summary.csv"), newline='') as csvfile:
            reader = csv.reader(csvfile, delimiter=',')
            for row in reader:
                if "Level" in row:
                    head = row
                elif "Total" in row:
                    for h,value in zip(head,row):
                        df_pr.loc["total",h] = value
                elif r1 >= 2:
                    if "Lane" in row:
                        head = row
                    for h, value in zip(head, row):
                        df.loc[r1, h] = value
                    r1 += 1
                elif "Read 1" in row:
                    r1 += 1

        df = df.loc[df['Surface'] == "-"]
        df.reset_index(drop=True, inplace=True)
        df.drop(df.index[[1]], inplace=True)
        df_lane1 = pd.DataFrame()
        df_lane2 = pd.DataFrame()

        for index, row in df.iterrows():
            row = df.loc[index, :].values.flatten().tolist()
            lane_index = row[0]
            if lane_index == "1":
                df_lane1 = self.build_df(index, row)

            elif lane_index == "2":
                df_lane2 = self.build_df(index, row)

        df_results = pd.DataFrame()
        for df, n in zip((df_lane1, df_lane2), (1, 2)):
            lane = n
            for index in df.columns:
                col_list = list(df[index])
                try:
                    col_l = list(map(int, col_list))
                    df_results.loc[lane, "lane"] = lane
                    if index in (
                    "tiles", "density", "pctPf", "legacyPhasingPrephasingRate", "reads", "readsPf", "pctQ30", "yield",
                    "cycleErrorRate",
                    "aligned_A", "Error_A", "Error_35_A", "Error_75_A", "Error_100_A", "occupied_A", "intensity_A",
                    "phasing_A", "prephasing_A"):
                        df_results.loc[lane, index] = str(self.average(col_l))
                    if index in (
                    "aligned_B", "Error_B", "Error_35_B", "Error_75_B", "Error_100_B", "occupied_B", "intensity_B",
                    "phasing_B", "prephasing_B"):
                        df_results.loc[lane, index] = str(col_l[0])


                except:
                    df_results.loc[lane, index] = col_list[0]

        df_results["pctAligned"] = df_results["aligned_A"] + "+/-" + df_results["aligned_B"]
        df_results["errorRate"] = df_results["Error_A"] + "+/-" + df_results["Error_B"]
        df_results["pctErrorRate35"] = df_results["Error_35_A"] + "+/-" + df_results["Error_35_B"]
        df_results["pctErrorRate75"] = df_results["Error_75_A"] + "+/-" + df_results["Error_75_B"]
        df_results["pctErrorRate100"] = df_results["Error_100_A"] + "+/-" + df_results["Error_100_B"]
        df_results["intensityCycle1"] = df_results["intensity_A"] + "+/-" + df_results["intensity_B"]
        df_results["phasingSlopeOffset"] = df_results["phasing_A"] + "+/-" + df_results["phasing_B"]
        df_results["prephasingSlopeOffset"] = df_results["phasing_A"] + "+/-" + df_results["phasing_B"]

        out = df_results.filter(
            ["lane", "tiles", "density", "pctPf", "legacyPhasingPrephasingRate", "reads", "readsPf", "pctQ30",
             "yield", "cycleErrorRate", "pctAligned", "errorRate", "pctErrorRate35", "pctErrorRate75",
             "pctErrorRate100", "intensityCycle1", "phasingSlopeOffset", "prephasingSlopeOffset"], axis=1)

        return df_pr,out
