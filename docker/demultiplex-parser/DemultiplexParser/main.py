from DemultiplexParserUtils import ParseReportFiles
from QCParserUtils import ParseQCFiles
from InteropParserUtils import ParseInteropFiles, interop_summary_parser
from JsonOutUtils import GenerateOut
import argparse
import os
import json

parser = argparse.ArgumentParser(prog="Demultiplex_Parser", description='This script parse Demultiples and QC data.')

parser.add_argument('--input_dir', type=str, help='Path to the input files.', required=True)
parser.add_argument('--multiqc_file', type=str, help='Path to the multiQC file.', required=True)
parser.add_argument('--output_dir', type=str, help='Path to output directory.', required=True)

args = parser.parse_args()

if not os.path.isdir(args.input_dir):
    parser.error("The path to the input directory is incorrect. Please, check it the path and re-run the script.")


if __name__ == '__main__':
    #Inicializar la clase
    parser_report = ParseReportFiles(args.input_dir)
    interop_parser = ParseInteropFiles(args.output_dir)
    qc_parser = ParseQCFiles(args.multiqc_file)
    generate_out = GenerateOut()

    #Parsing Data
    flowcell_summary,lane_summary,unknown_barcodes = parser_report.parse_demultiplex_data()
    interop_totals, interop_lanes = interop_parser.parse_data()
    qc_data = qc_parser.parse_data()


    #Generating Output JSONs
    demultiplexed_sample_qc = generate_out.generate_demultiplexed_sample_qc(lane_summary,qc_data)
    demultiplexed_runs_qc,sequencing_runs_qc = generate_out.generate_demultiplexed_runs_qc(flowcell_summary,interop_totals)
    unknown_barcodes = generate_out.generate_unknown_barcodes(unknown_barcodes)

    demultiplexed_sample_qc.to_json(os.path.join(args.output_dir, "demultiplexed_sample_qc.json"),orient="records")
    demultiplexed_runs_qc.to_json(os.path.join(args.output_dir, "demultiplexed_run_qc.json"),orient="records")
    sequencing_runs_qc.to_json(os.path.join(args.output_dir, "sequencing_runs_qc.json"),orient="records")
    unknown_barcodes.to_json(os.path.join(args.output_dir, "unknown_barcodes.json"),orient="records")
    #interop_lanes.to_json(os.path.join(args.output_dir, "lanes_table_definition.json"), orient="records")
    json_read_lane = interop_summary_parser(os.path.join(args.output_dir, "QC", "interop_summary.csv"))

    with open(os.path.join(args.output_dir, "read_lane.json"), 'w') as fo_read_lane:
        json.dump(json_read_lane, fo_read_lane, indent=2)