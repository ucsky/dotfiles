#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import unittest
from pathlib import Path
import importlib.util

try:
    import nbformat
    from nbformat.v4 import new_code_cell, new_notebook
except ImportError:
    print("Skipping test: nbformat module not found. Install it with: pip install nbformat")
    sys.exit(0)

REPO_ROOT = Path(__file__).resolve().parents[3]
scripts_dir = REPO_ROOT / "scripts" / "python3"

# The script filename contains hyphens, so it cannot be imported as a normal module.
_script_path = scripts_dir / "d51_nb-check-params.py"
_spec = importlib.util.spec_from_file_location("d51_nb_check_params", _script_path)
assert _spec and _spec.loader, f"Unable to load module from {_script_path}"
_mod = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_mod)  # type: ignore[union-attr]

count_parameters_tags = _mod.count_parameters_tags  # noqa: E305


class TestCheckNbParams(unittest.TestCase):
    def setUp(self):
        """
        Create sample notebooks for testing.
        """
        self.notebook_with_one_tag = new_notebook(
            cells=[
                new_code_cell(
                    source="print('Hello World')", metadata={"tags": ["parameters"]}
                ),
                new_code_cell(source="print('Another cell')"),
            ]
        )
        self.notebook_with_multiple_tags = new_notebook(
            cells=[
                new_code_cell(source="print('Cell 1')", metadata={"tags": ["parameters"]}),
                new_code_cell(source="print('Cell 2')", metadata={"tags": ["parameters"]}),
                new_code_cell(source="print('Cell 3')", metadata={"tags": ["parameters"]}),
            ]
        )
        self.notebook_without_tag = new_notebook(
            cells=[
                new_code_cell(source="print('Hello World')"),
                new_code_cell(source="print('Another cell')"),
            ]
        )

        self.path_with_one_tag = Path("test_with_one_tag.ipynb")
        self.path_with_multiple_tags = Path("test_with_multiple_tags.ipynb")
        self.path_without_tag = Path("test_without_tag.ipynb")

        with self.path_with_one_tag.open("w", encoding="utf-8") as f:
            nbformat.write(self.notebook_with_one_tag, f)
        with self.path_with_multiple_tags.open("w", encoding="utf-8") as f:
            nbformat.write(self.notebook_with_multiple_tags, f)
        with self.path_without_tag.open("w", encoding="utf-8") as f:
            nbformat.write(self.notebook_without_tag, f)

    def tearDown(self):
        """
        Clean up any files created during the tests.
        """
        self.path_with_one_tag.unlink(missing_ok=True)
        self.path_with_multiple_tags.unlink(missing_ok=True)
        self.path_without_tag.unlink(missing_ok=True)

    def test_notebook_with_one_parameters_tag(self):
        result = count_parameters_tags(self.path_with_one_tag)
        self.assertEqual(result, 1)

    def test_notebook_with_multiple_parameters_tags(self):
        result = count_parameters_tags(self.path_with_multiple_tags)
        self.assertEqual(result, 3)

    def test_notebook_without_parameters_tag(self):
        result = count_parameters_tags(self.path_without_tag)
        self.assertEqual(result, 0)


if __name__ == "__main__":
    unittest.main()

