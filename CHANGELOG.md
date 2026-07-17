# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Use this section to track upcoming changes, to let people see what changes they might expect in
upcoming relases.

At release time, move the entries from here to a new release section.

### Additions

- Added `additional_resource_customisations` variable to allow merging extra resource customisations with the defaults.

### Fixes

### Changes

### Removals

## [1.3.0] - 2026-03-31

### Added

- Added Pod Disruption Budgets (PDBs) for core ArgoCD components: `applicationSet`, `controller`, `server`, and `repoServer`.
- Configured HA-aware Pod Disruption Budgets for the `redis-ha` subchart (Sentinels/Redis nodes) and its HAProxy load balancer to ensure quorum is maintained during maintenance.
- Added documentation comment for the Application Controller component in `values.yaml`.

## [1.2.0] - 2026-02-13

### Added

- Parameterised the `gitopsRef` for the ArgoCD application using a Terraform variable.

## [1.1.0] - 2026-01-08

### Added

- Added `priorityClassName: system-cluster-critical`

## [1.0.0] - 2025-11-20

### Added

- Initial revision

### Changed

### Fixed

### Removed
