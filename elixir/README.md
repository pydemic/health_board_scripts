# Health Board Scripts - Elixir

## Playbooks

### Generate Dashboards CSVs from YAML files

```bash
mix run -e 'HBS.Dashboards.YAMLToCSV.run(input_path: "</path/to/health_board_meta>/data/<release_name>/dashboards")'
```
