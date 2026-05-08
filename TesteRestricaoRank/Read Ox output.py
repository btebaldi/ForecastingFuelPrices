import re
import sys
import pathlib
import datetime
import pandas as pd


def parse_file(filepath: str) -> pd.DataFrame:
    """
    Parse a file line by line, extracting:
      - Region number from:  Região: <number>
      - Bootstrap test info from:  Bootstrap test             : <stat> [<pvalue>]

    Each time the region changes (or EOF is reached), the collected
    records are flushed into the results table.

    Returns a pandas DataFrame with columns:
        region, test_statistic, p_value
    """

    region_pattern     = re.compile(r"Regi[aã]o\s*:\s*(\d+)")
    rank_pattern     = re.compile(r"Rank\s*:*\s*(\d+)")
    bootstrap_pattern  = re.compile(r"Bootstrap\s+test\s*:\s*([\d.]+(?:e[+-]?\d+)?)\s+\[([\d.]+(?:e[+-]?\d+)?)\]", re.IGNORECASE)
    region_pattern2 = re.compile("Ratio Alcool - Gasolina - Brent")
    region_pattern3 = re.compile("Região:")

    records: list[dict] = []

    current_region: int | None = None
    current_rank: int | None = None
    pending_tests:  list[dict] = []   # bootstrap rows collected for the current region

    def flush(region, rank, tests):
        """Commit all pending bootstrap rows for the given region."""
        if region is None:
            return
        
        if rank is None:
            rank = -1

        if tests:
            for t in tests:
                records.append({"region": region, "rank" : rank, **t})
        else:
            # Region found but no bootstrap tests — store a placeholder row
            records.append({"region": region,  "rank" : rank, "test_statistic": None, "p_value": None})

    with open(filepath, "r", encoding="utf-8") as fh:
        if filepath.stem in ['TesteRestricaoRank02b', 'TesteRestricaoRank02c', 'TesteRestricaoRank02e'] :
            current_region = 0

        for line in fh:
            # ── Check for a new region header ──────────────────────────────
            region_match = region_pattern.search(line)
            rank_match = rank_pattern.search(line)
            
            if filepath.stem  in ['TesteRestricaoRank02b', 'TesteRestricaoRank02c'] :
                region_match2 = region_pattern2.search(line)
                if region_match2 :
                    current_region = current_region + 1
                    pending_tests  = []
            
            if filepath.stem  in ['TesteRestricaoRank02e'] :
                region_match2 = region_pattern3.search(line)
                if region_match2 :
                    current_region = current_region + 1
                    pending_tests  = []

            if region_match:
                # Flush whatever we accumulated for the previous region
                current_region = int(region_match.group(1))
                pending_tests  = []
                continue

            if rank_match:
                # Flush whatever we accumulated for the previous region
                current_rank = int(rank_match.group(1))
                continue

            
            # ── Check for a bootstrap test result ──────────────────────────
            bootstrap_match = bootstrap_pattern.search(line)
            if bootstrap_match:
                pending_tests.append({
                    "test_statistic": float(bootstrap_match.group(1)),
                    "p_value":        float(bootstrap_match.group(2)),
                })
                flush(current_region, current_rank, pending_tests)

    # Flush the last region after EOF
    # flush(current_region, current_rank, pending_tests)

    df = pd.DataFrame(records, columns=["region", "rank", "test_statistic", "p_value"])
    return df


def main():

    while True:
        list_input_file = pathlib.Path(input("Dir Path with *.out files: "))

        if not list_input_file.is_dir():
            print(f"Directory not found: {list_input_file}, please try again.")
            continue

        if not any(list_input_file.glob("*.out")):
            print(f"No .out files found in: {list_input_file}, please try again.")
            continue

        break

    # c:\Users\bteba\Downloads\TesteRestricaoRank\TesteRestricaoRank01.out

    # input_file  = sys.argv[1]
    # output_file = sys.argv[2] if len(sys.argv) > 2 else "results.csv"

    for input_file in list_input_file.glob("*.out") :
        print(f"Parsing: {input_file}")

        output_file = f"results_{input_file.stem}_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"

        df = parse_file(input_file)

        print(f"\n{'='*50}")
        print("Parsed results:")
        print(f"{'='*50}")
        print(df.to_string(index=False))
        print(f"\nTotal rows: {len(df)}")

        df.to_csv(output_file, index=False)
        print(f"\nSaved to: {output_file}")

if __name__ == "__main__":
    main()