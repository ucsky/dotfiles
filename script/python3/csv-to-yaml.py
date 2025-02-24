#!/usr/bin/env python3
import pandas as pd
import typer
import yaml

app = typer.Typer()


@app.command()
def convert(
    csv_file: str,
    yaml_file: str,
    delimiter: str = typer.Option(
        ",", "--delimiter", "-d", help="CSV file delimiter (e.g., ',', ';', '\\t')"
    ),
):
    """
    Converts a CSV file to YAML format, allowing a custom delimiter.

    Args:
        csv_file (str): Path to the input CSV file.
        yaml_file (str): Path to the output YAML file.
        delimiter (str, optional): Delimiter used in the CSV file. Default is ','.
    """
    try:
        # Read the CSV file with the specified delimiter
        df = pd.read_csv(csv_file, delimiter=delimiter)

        # Convert DataFrame to a list of dictionaries
        data = df.to_dict(orient="records")

        # Write the data to a YAML file
        with open(yaml_file, "w", encoding="utf-8") as f:
            yaml.dump(data, f, default_flow_style=False, allow_unicode=True)

        typer.echo(f"✅ Conversion successful! YAML file saved at: {yaml_file}")

    except Exception as e:
        typer.echo(f"❌ Error: {e}", err=True)


if __name__ == "__main__":
    app()
