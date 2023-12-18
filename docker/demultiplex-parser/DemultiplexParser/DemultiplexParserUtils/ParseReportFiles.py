import os
import pandas as pd

class ParseReportFiles:

    def __init__(self, input_dir):
        self.input_dir = input_dir

    def get_report_files(self):
        paths_report = []

        for path, subdirs, files in os.walk(self.input_dir):
            for name in files:
                file_path = path + "/" + name
                if "all/all/all/laneBarcode.html" in file_path:
                        paths_report.append(file_path)

        return paths_report



    def parse_demultiplex_data(self):
        paths_report = self.get_report_files()
        flowcell_summary = None
        lane_summary = None
        unknown_barcodes = None

        for path in paths_report:
            file = pd.read_html(path)

            n = 0
            for table in file:

                if n == 0:
                    run_id = table[0].tolist()[0].split("/")[0]
                elif n==1:
                    flowcell_summary = table
                    flowcell_summary["runId"] = run_id

                elif n == 2:
                    lane_summary = table
                    lane_summary["runId"] = run_id
                elif n == 3:
                    unknown_barcodes = table
                    unknown_barcodes["runId"] = run_id

                n += 1

        return flowcell_summary,lane_summary,unknown_barcodes
