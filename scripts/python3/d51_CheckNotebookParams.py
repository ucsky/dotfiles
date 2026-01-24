#!/usr/bin/env python3
"""
Check Jupyter notebooks for `parameters`-tagged cells.
"""

from pathlib import Path

import nbformat
import typer
from tabulate import tabulate

app = typer.Typer(add_completion=False)


def count_parameters_tags(notebook_path: Path) -> int:
    """
    Count the number of code cells with the 'parameters' tag in a Jupyter notebook.
    """
    with notebook_path.open(encoding="utf-8") as f:
        nb = nbformat.read(f, as_version=4)

    count = 0
    for cell in nb.cells:
        if cell.cell_type == "code" and "parameters" in cell.metadata.get("tags", []):
            count += 1
    return count


@app.command()
def check_directory(directory: Path):
    """
    Check all Jupyter notebooks in a directory for the 'parameters' tag and print a table.
    """
    if not directory.is_dir():
        typer.echo(f"Error: {directory} is not a valid directory.", err=True)
        raise typer.Exit(code=1)

    notebooks = list(directory.glob("*.ipynb"))
    if not notebooks:
        typer.echo(f"No Jupyter notebooks found in {directory}.")
        raise typer.Exit(code=0)

    table_data = []
    for notebook in notebooks:
        count = count_parameters_tags(notebook)
        table_data.append([notebook.name, count])

    typer.echo(
        tabulate(
            table_data,
            headers=["Notebook", "Number of 'parameters' Tags"],
            tablefmt="grid",
        )
    )


if __name__ == "__main__":
    app()
