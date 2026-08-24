# Security

This template is intended for local Windows-first Python tools. Project forks may process private files, network paths, cloud folders, documents, media, archives, or API-backed workflows.

## Do Not Commit Secrets

Common secret patterns:

- `.env`
- `.env.*`
- `api_key*.txt`
- `*.key`
- `*.pem`
- exported environment dumps
- logs that contain credentials or access tokens

Use environment variables, local ignored files, or your organization's secret manager.

## Data Handling

The template itself does not require external API calls for project business logic.

Generated projects may call external providers, cloud remotes, sync engines, OCR services, LLM APIs, or internal network services. Process only data you are authorized to send to those systems.

## Portable Runtime Note

The portable runtime removes the requirement for a system Python installation. It does not remove the need to protect local config files, path histories, credentials, logs, and generated reports.

## Path History

If a project stores recent source/target paths, treat `config\path_history.json` as local user state. Do not publish private network paths, customer folders, or machine-specific drive layouts.
