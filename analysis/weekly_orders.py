"""Step 1 of the traffic check: how much does weekly order volume vary?

If the peak season has several times more orders per week than a normal week,
a count-based density threshold (sigma purchases per window) may flag itemsets
as dense only because total traffic is high.

Usage:
    python analysis/weekly_orders.py data/online_retail_II.xlsx

Data: UCI Online Retail II, https://archive.ics.uci.edu/dataset/502/online+retail+ii
Outputs: analysis/out/weekly_orders.csv, analysis/out/weekly_orders.png
"""
import sys
from pathlib import Path

import pandas as pd

OUT = Path(__file__).parent / "out"


def load(path: str) -> pd.DataFrame:
    """Read both yearly sheets and keep product rows of non-cancelled invoices."""
    sheets = pd.read_excel(path, sheet_name=None, dtype={"Invoice": str, "StockCode": str})
    df = pd.concat(sheets.values(), ignore_index=True).drop_duplicates()
    n_raw = len(df)
    df = df[~df["Invoice"].str.startswith("C", na=False)]       # cancellations
    df = df[df["Description"].notna() & (df["Quantity"] > 0)]   # no description / returns
    df = df[df["StockCode"].str.match(r"^\d{5}", na=False)]     # drop POST, M, DOT, ...
    print(f"rows: {n_raw:,} raw -> {len(df):,} kept")
    return df


def main(path: str) -> None:
    df = load(path)
    invoices = df.groupby("Invoice")["InvoiceDate"].min()
    weekly = invoices.dt.to_period("W").value_counts().sort_index()
    weekly = weekly.iloc[1:-1]  # first and last weeks are partial
    weekly.index = weekly.index.start_time
    weekly.name = "orders"

    median = weekly.median()
    # Peak season: weeks starting in November, or in December before the shop's Christmas break.
    peak = weekly[(weekly.index.month == 11) | ((weekly.index.month == 12) & (weekly.index.day <= 14))]
    rest = weekly.drop(peak.index)

    print(f"invoices: {len(invoices):,}   weeks: {len(weekly)}")
    print(f"orders per week: median {median:.0f}, min {weekly.min()}, max {weekly.max()}")
    print(f"max / median = {weekly.max() / median:.2f}")
    print(f"peak season (Nov to mid-Dec) mean {peak.mean():.0f} vs other weeks mean {rest.mean():.0f}"
          f" -> ratio {peak.mean() / rest.mean():.2f}")
    print("top 5 weeks:")
    print(weekly.sort_values(ascending=False).head(5).to_string())

    OUT.mkdir(exist_ok=True)
    weekly.to_csv(OUT / "weekly_orders.csv", index_label="week_start")

    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(figsize=(10, 3.5))
    ax.bar(weekly.index, weekly.values, width=6, color="#c3d5e6")
    ax.bar(peak.index, peak.values, width=6, color="#c0567a", label="Nov to mid-Dec")
    ax.axhline(median, color="#2a5078", linestyle="--", linewidth=1, label=f"median = {median:.0f}")
    ax.set_ylabel("orders per week")
    ax.set_title("Online Retail II: weekly order volume")
    ax.legend(frameon=False)
    fig.tight_layout()
    fig.savefig(OUT / "weekly_orders.png", dpi=150)


if __name__ == "__main__":
    main(sys.argv[1])
