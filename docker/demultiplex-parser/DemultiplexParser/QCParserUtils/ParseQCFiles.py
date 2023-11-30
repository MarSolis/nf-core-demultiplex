import numpy as np
import pandas as pd

class ParseQCFiles:

    def __init__(self, input_file):
        self.input_file = input_file

    def parse_data(self):
        multiqc_df = pd.read_csv(self.input_file, sep='\t')
        samples = multiqc_df.Sample
        sample_ids = []

        for sample in samples:
            sample_ids.append(sample.split("_")[0])

        sample_ids = set(sample_ids)
        adapters = []
        median_sequences = []
        average_sequences = []
        all_bases = []
        gc_contents = []
        all_duplicate_reads = []

        for id in sample_ids:
            adapter_content_status = "pass"
            median_sequence_length = None
            average_sequence_length = []
            total_bases = []
            gc_content = []
            duplicate_reads = []
            filtered_df = multiqc_df[multiqc_df['Sample'].str.contains(fr'\b{id}*', case=False, regex=True)]
            for i in range(0, filtered_df.shape[0]):
                median_sequence_length = filtered_df.iloc[i]["median_sequence_length"]
                average_sequence_length.append(filtered_df.iloc[i]["avg_sequence_length"])
                gc_content.append(filtered_df.iloc[i]["%GC"])
                duplicate_reads.append(100.0 - filtered_df.iloc[i]["total_deduplicated_percentage"])

                if ((filtered_df.iloc[i]["adapter_content"] == "fail") or (
                        filtered_df.iloc[i]["adapter_content"] == "warn")):
                    adapter_content_status = filtered_df.iloc[i]["adapter_content"]

                # bases = filtered_df.iloc[i]["Total Bases"]
                # if (bases.split(" ")[1] == "Mbp"):
                #     total_bases.append(float(bases.split(" ")[0]))
                # elif (bases.split(" ")[1] == "Gbp"):
                #     total_bases.append(float(bases.split(" ")[0]) * 1000)

            avg_sequence_length = np.mean(average_sequence_length)
            pct_GC = np.mean(gc_content)
            pct_dup_reads = np.mean(duplicate_reads)
            # yield_fastqc = np.sum(total_bases)

            adapters.append(adapter_content_status)
            median_sequences.append(median_sequence_length)
            average_sequences.append(avg_sequence_length)
            # all_bases.append(yield_fastqc)
            gc_contents.append(pct_GC)
            all_duplicate_reads.append(pct_dup_reads)

        data = {'sample': list(sample_ids),
                # 'yieldFastqc': all_bases,
                'pctDupReads': all_duplicate_reads,
                'pctGC': gc_contents,
                'averageSequenceLength': average_sequences,
                'medianSequenceLength': median_sequences,
                'adapterContentStatus': adapters}

        return pd.DataFrame(data)

