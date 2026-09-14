---
name: excel-toolkit
description: "Read, edit, analyze, and create Microsoft Excel files (.xlsx, .xls, .xlsm, .csv, .tsv). Use when a user asks to: (1) Open/read/inspect an Excel file, (2) Edit or modify spreadsheet data, formulas, or formatting, (3) Analyze spreadsheet data and provide insights, statistics, or trends, (4) Create new Excel files with data, formulas, charts, or formatting, (5) Convert between CSV/TSV and Excel formats, (6) Build financial models or dashboards in Excel."
---

# Excel Toolkit

## Setup (First Use)

Run the dependency installer before any Excel operation:
```bash
python3 scripts/setup_deps.py
```
Installs: openpyxl, pandas, xlsxwriter, matplotlib. Skip if already installed.

## Workflow Selection

1. **Inspect a file** → Run `scripts/inspect_excel.py`
2. **Analyze data / get insights** → Run `scripts/analyze_excel.py`
3. **Read data for processing** → Use pandas in inline Python
4. **Edit existing file** → Use openpyxl (preserves formulas/formatting)
5. **Create new file** → Use openpyxl (formulas/formatting) or pandas (data export)
6. **Recalculate formulas** → Run `scripts/recalc.py`

## Quick-Start Scripts

### Inspect File Structure
```bash
python3 scripts/inspect_excel.py data.xlsx                    # Structure only
python3 scripts/inspect_excel.py data.xlsx --data              # With data preview
python3 scripts/inspect_excel.py data.xlsx --sheet "Sales"     # Specific sheet
python3 scripts/inspect_excel.py data.xlsx --data --rows 50    # More preview rows
```
Returns JSON: sheet names, dimensions, headers, column types, optional data preview.

### Analyze Data
```bash
python3 scripts/analyze_excel.py data.xlsx                         # Basic stats
python3 scripts/analyze_excel.py data.xlsx --correlations          # With correlations
python3 scripts/analyze_excel.py data.xlsx --sheet "Revenue"       # Specific sheet
```
Returns JSON: shape, dtypes, missing values, numeric stats, categorical summaries, duplicates, date ranges.

### Recalculate Formulas
```bash
python3 scripts/recalc.py output.xlsx [timeout_seconds]
```
Requires LibreOffice. Returns JSON with formula errors and locations.

## Reading Data

```python
import pandas as pd

df = pd.read_excel('file.xlsx')                          # First sheet
df = pd.read_excel('file.xlsx', sheet_name='Sales')      # Named sheet
all_sheets = pd.read_excel('file.xlsx', sheet_name=None) # All sheets as dict
df = pd.read_excel('file.xlsx', dtype={'id': str})       # Force types
```

## Creating / Editing

### Create New
```python
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment

wb = Workbook()
ws = wb.active
ws.title = "Data"
ws['A1'] = 'Category'
ws['A1'].font = Font(bold=True)
ws.append(['Sales', 1500])
ws['B3'] = '=SUM(B2:B2)'
ws.column_dimensions['A'].width = 18
wb.save('output.xlsx')
```

### Edit Existing
```python
from openpyxl import load_workbook

wb = load_workbook('existing.xlsx')  # preserves formulas
ws = wb['Sheet1']
ws['A1'] = 'Updated'
ws.insert_rows(2)
wb.save('modified.xlsx')
```

## Critical Rules

1. **Use Excel formulas, not hardcoded calculations**
   - ❌ `ws['B10'] = df['Sales'].sum()`
   - ✅ `ws['B10'] = '=SUM(B2:B9)'`

2. **Recalculate after writing formulas** — openpyxl writes formula strings but doesn't evaluate:
   ```bash
   python3 scripts/recalc.py output.xlsx
   ```

3. **Never save workbooks opened with `data_only=True`** — destroys all formulas permanently.

4. **Preserve existing formatting** — use `load_workbook()` and match existing conventions.

## Providing Insights

When analyzing data:

1. Run `scripts/inspect_excel.py` to understand structure
2. Run `scripts/analyze_excel.py --correlations` for numeric data
3. Present findings:
   - **Overview**: rows, columns, data types
   - **Key Statistics**: means, medians, ranges
   - **Data Quality**: missing values, duplicates, anomalies
   - **Patterns**: correlations, trends, distributions
   - **Actionable Insights**: what stands out, recommendations

## Building Dashboards & Insights Sheets

When creating dashboard/insights sheets with tables and charts, you **MUST** follow the layout rules in `references/advanced-patterns.md` → "Dashboard Layout & Spacing":

1. **Use a running ROW counter** — never hardcode row positions for sections/charts
2. **Reserve 17-20 rows** after each chart anchor for chart height
3. **Leave 2 blank rows** between tables and charts
4. **Set chart dimensions explicitly** — use the sizing guide for each chart type
5. **Apply consistent styling** — title/section/header fonts, zebra striping, thin borders
6. **Use the standard color palette** — BLUE for primary, ORANGE for secondary, RED for warnings
7. **Set column widths** — use the defaults table for readable layouts

## Advanced Features

For charts, conditional formatting, pivot tables, data validation, CSV conversion, dashboard layout, and large file handling → see `references/advanced-patterns.md`.
