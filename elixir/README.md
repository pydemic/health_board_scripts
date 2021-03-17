# Health Board Scripts - Elixir

## Playbooks

### Generate Dashboards CSVs from YAML files

```bash
mix run -e 'HBS.Dashboards.YAMLToCSV.run(input_path: "</path/to/health_board_meta>/data/<release_name>/dashboards")'

# Example

mix run -e 'HBS.Dashboards.YAMLToCSV.run(input_path: "/health_board_meta/data/health_board_covid/dashboards")'
```
