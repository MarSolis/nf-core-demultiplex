import pandas as pd

class GenerateOut:

    def generate_demultiplexed_runs_qc(self, flowcell_summary,interop_totals):
        demultiplexed_runs_qc = flowcell_summary
        sequencing_runs_qc = pd.DataFrame()
        demultiplexed_runs_qc.rename(columns={"Clusters (Raw)": "rawClusters", "Clusters(PF)":"pfClusters","Yield (MBases)":"yieldDemultiplex"}, inplace=True)
        demultiplexed_runs_qc["yieldInterop"] = interop_totals["Yield"].tolist()[0]
        demultiplexed_runs_qc["averagePctQ30"] = interop_totals["%>=Q30"].tolist()[0]
        demultiplexed_runs_qc["pctPfClusters"] = (demultiplexed_runs_qc["pfClusters"].tolist()[0]/demultiplexed_runs_qc["rawClusters"].tolist()[0])*100
        sequencing_runs_qc["pctOccupation"]= interop_totals["% Occupied"].tolist()[0]
        sequencing_runs_qc["pctAligned"] = interop_totals["Aligned"].tolist()[0]
        sequencing_runs_qc["errorRate"] = interop_totals["Error Rate"].tolist()[0]

        return demultiplexed_runs_qc,sequencing_runs_qc

    def generate_demultiplexed_sample_qc(self,lane_summary,qc_data):
        Samples = lane_summary["Sample"].tolist()
        Samples.remove('Undetermined')
        df = pd.DataFrame()

        for Sample in Samples:
            print("Sample",Sample)
            # for x in qc_data.columns.values.tolist():
            #     print(x)
            df_qc = qc_data.loc[qc_data['sample'].isin([Sample])]
            df_sample= lane_summary.loc[lane_summary['Sample'].isin([Sample])]
            df.loc[Sample,"sample"] = Sample
            df.loc[Sample, "runId"] = df_sample["runId"].tolist()[0]
            df.loc[Sample, "pfClusters"] = df_sample["PF Clusters"].sum()
            df.loc[Sample, "pfReads"] = (df_sample["PF Clusters"].sum())*2   # TODO DEPENDENCIA DE PAIRED END FIX PLS
            df.loc[Sample, "barcodeI7"] = df_sample["Barcode sequence"].tolist()[0]
            df.loc[Sample, "pctOfLane"] = df_sample["% of the lane"].mean()
            df.loc[Sample, "pctPerfectBarcode"] = df_sample["% Perfect barcode"].mean()
            df.loc[Sample, "pctOneMismatch"] = df_sample["% One mismatch barcode"].mean()
            df.loc[Sample, "yieldDemultiplex"] = df_sample["Yield (Mbases)"].sum()
            df.loc[Sample, "pctPfClusters"] = df_sample["% PF Clusters"].mean()
            df.loc[Sample, "pctQ30"] = df_sample["% >= Q30 bases"].mean()
            df.loc[Sample, "meanQualityScore"] = df_sample["Mean Quality Score"].mean()
            #df.loc[Sample, "yieldFastQC"] = df_qc["yieldFastqc"].tolist()[0]
            df.loc[Sample, "pctDupReads"] = df_qc["pctDupReads"].tolist()[0]
            df.loc[Sample, "averageSequenceLength"] = df_qc["averageSequenceLength"].tolist()[0]
            df.loc[Sample, "medianSequenceLength"] = df_qc["medianSequenceLength"].tolist()[0]
            df.loc[Sample, "adapterContentStatus"] = df_qc["adapterContentStatus"].tolist()[0]

        return df

    def generate_unknown_barcodes(self, unknown_barcodes):
            df = pd.DataFrame()
            barcodes = unknown_barcodes["Sequence"].tolist()

            for BC in barcodes:
                df_bc = unknown_barcodes.loc[unknown_barcodes['Sequence'].isin([BC])]
                df.loc[BC, "unknown_barcode_code"] = BC
                df.loc[BC, "clusters"] = df_bc["Count"].sum()
                df = df.dropna()

            return df


