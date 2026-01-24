#!/usr/bin/env python3
"""
Convert a CSV file to YAML.
"""

import pandas as pd
import typer
import yaml

app = typer.Typer(add_completion=False)


@app.command()
def convert(
    csv_file: str,
    yaml_file: str,
    delimiter: str = typer.Option(
        ",", "--delimiter", "-d", help="CSV delimiter (e.g. ',', ';', '\\t')"
    ),
):
    """
    Convert a CSV file to YAML format.
    """
    df = pd.read_csv(csv_file, delimiter=delimiter)
    data = df.to_dict(orient="records")
    with open(yaml_file, "w", encoding="utf-8") as f:
        yaml.dump(data, f, default_flow_style=False, allow_unicode=True)
    typer.echo(f"Conversion successful. YAML saved at: {yaml_file}")


if __name__ == "__main__":
    app()
